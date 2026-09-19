import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/money_text.dart';
import '../../domain/entities/cliente.dart';
import '../providers/customers_providers.dart';
import '../widgets/saldo_widgets.dart';

/// Clientes con fiado: total por cobrar, búsqueda por nombre/teléfono y filtro
/// "Con deuda" (por defecto) | "Todos".
class ClientesListScreen extends ConsumerStatefulWidget {
  const ClientesListScreen({super.key});

  @override
  ConsumerState<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends ConsumerState<ClientesListScreen> {
  final _busquedaController = TextEditingController();
  String _texto = '';
  bool _soloConDeuda = true;

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientes = ref.watch(clientesBusquedaProvider(_texto.trim()));
    final porCobrar = ref.watch(totalPorCobrarProvider).value ?? const Money(0);
    final sinClientes = clientes.maybeWhen(
      data: (todos) => todos.isEmpty && _texto.trim().isEmpty,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Clientes y fiado')),
      // Con la lista vacía la acción principal es la del estado vacío: el FAB
      // se oculta para no duplicarla.
      floatingActionButton: sinClientes
          ? null
          : FloatingActionButton.extended(
              // Sin Hero: varias pantallas con FAB pueden estar montadas a la
              // vez.
              heroTag: null,
              onPressed: () => context.push(AppRoutes.clientesNuevo),
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Nuevo cliente'),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _TotalPorCobrar(total: porCobrar),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: TextField(
                  controller: _busquedaController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre o teléfono',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _texto.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Borrar búsqueda',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _busquedaController.clear();
                              setState(() => _texto = '');
                            },
                          ),
                  ),
                  onChanged: (v) => setState(() => _texto = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Con deuda'),
                      selected: _soloConDeuda,
                      onSelected: (_) => setState(() => _soloConDeuda = true),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: !_soloConDeuda,
                      onSelected: (_) => setState(() => _soloConDeuda = false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: clientes.when(
                  loading: () => const LoadingView(),
                  error: (error, stackTrace) => ErrorState(
                    mensaje: 'No se pudieron cargar los clientes.',
                    error: error,
                    stackTrace: stackTrace,
                    onReintentar: () =>
                        ref.invalidate(clientesBusquedaProvider(_texto.trim())),
                  ),
                  data: _construirLista,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirLista(List<Cliente> todos) {
    if (todos.isEmpty && _texto.trim().isEmpty) {
      return EmptyState(
        icono: Icons.groups_outlined,
        titulo: 'Aún no tienes clientes',
        descripcion:
            'Agrega a los clientes a quienes les fías para llevar '
            'la cuenta de lo que te deben.',
        accionLabel: 'Agregar cliente',
        onAccion: () => context.push(AppRoutes.clientesNuevo),
      );
    }
    final visibles = _soloConDeuda
        ? todos.where((c) => c.saldo.cents > 0).toList()
        : todos;
    if (visibles.isEmpty) {
      if (_texto.trim().isNotEmpty) {
        return const EmptyState(
          icono: Icons.search_off_outlined,
          titulo: 'Sin resultados',
          descripcion: 'Prueba con otro nombre o teléfono, o mira "Todos".',
        );
      }
      return const EmptyState(
        icono: Icons.check_circle_outline,
        titulo: 'Nadie te debe',
        descripcion: 'Todos tus clientes están al día.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: visibles.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = visibles[i];
        return ListTile(
          title: Text(c.nombre),
          subtitle: _subtitulo(c),
          trailing: EtiquetaSaldo(saldo: c.saldo),
          onTap: () => context.push('/clientes/${c.id}'),
        );
      },
    );
  }

  Widget? _subtitulo(Cliente c) {
    final partes = [
      if (c.telefono != null) c.telefono!,
      if (!c.activo) 'Inactivo',
    ];
    return partes.isEmpty ? null : Text(partes.join(' · '));
  }
}

/// Cabecera con el total por cobrar (suma de saldos positivos).
class _TotalPorCobrar extends StatelessWidget {
  const _TotalPorCobrar({required this.total});

  final Money total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Card(
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: scheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text('Total por cobrar', style: textTheme.titleMedium),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: MoneyText(
                  total,
                  textAlign: TextAlign.right,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
