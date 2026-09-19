import 'package:app_gestion/core/database/app_database.dart';
import 'package:app_gestion/core/database/tables/base.dart';
import 'package:app_gestion/core/errors/result.dart';
import 'package:app_gestion/core/utils/money.dart';
import 'package:app_gestion/features/customers/data/datasources/customers_local_datasource.dart';
import 'package:app_gestion/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:app_gestion/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:app_gestion/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:app_gestion/features/sales/domain/entities/venta.dart';
import 'package:app_gestion/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:drift/drift.dart'
    show ApplyInterceptor, QueryInterceptor, Value;
import 'package:drift/native.dart';

/// Base en memoria con negocio, administrador y un producto (Salami, stock
/// 100, RD$ 150 = 15000 centavos), más los repositorios de ventas y clientes.
class FiadoFixture {
  FiadoFixture._(this.db, this.usuarioId, this.productoId)
    : ventas = SalesRepositoryImpl(
        SalesLocalDatasource(db),
        SettingsLocalDatasource(db),
      ),
      clientes = CustomersRepositoryImpl(CustomersLocalDatasource(db));

  final AppDatabase db;
  final String usuarioId;
  final String productoId;
  final SalesRepositoryImpl ventas;
  final CustomersRepositoryImpl clientes;

  /// Con [interceptor] se observan las consultas que llegan a la base (p. ej.
  /// para contarlas).
  static Future<FiadoFixture> crear({QueryInterceptor? interceptor}) async {
    final db = AppDatabase.forTesting(
      interceptor == null
          ? NativeDatabase.memory()
          : NativeDatabase.memory().interceptWith(interceptor),
    );
    final negocioId = generateUuidV4();
    await db
        .into(db.negocios)
        .insert(
          NegociosCompanion.insert(
            id: Value(negocioId),
            nombre: 'Colmado Test',
          ),
        );
    final usuarioId = generateUuidV4();
    await db
        .into(db.usuarios)
        .insert(
          UsuariosCompanion.insert(
            id: Value(usuarioId),
            negocioId: negocioId,
            nombre: 'Admin',
            username: 'admin',
            passwordHash: 'hash',
            salt: 'salt',
            rol: RolUsuario.administrador,
          ),
        );
    final productoId = generateUuidV4();
    await db
        .into(db.productos)
        .insert(
          ProductosCompanion.insert(
            id: Value(productoId),
            nombre: 'Salami',
            unidad: const Value('libra'),
            precioCompra: const Value(10000),
            precioVenta: const Value(15000),
            stockActual: const Value(100),
            stockMinimo: const Value(2),
          ),
        );
    return FiadoFixture._(db, usuarioId, productoId);
  }

  Future<void> cerrar() => db.close();

  Future<void> abrirCaja([Money apertura = const Money(100000)]) async {
    final r = await ventas.abrirCaja(
      montoApertura: apertura,
      usuarioId: usuarioId,
    );
    assert(r.isOk);
  }

  /// Crea un cliente y devuelve su id.
  Future<String> nuevoCliente({
    String nombre = 'Doña Rosa',
    String? telefono,
    Money? limite,
  }) async {
    final r = await clientes.crearCliente(
      nombre: nombre,
      telefono: telefono,
      limiteCredito: limite,
      usuarioId: usuarioId,
    );
    return r.valueOrNull!;
  }

  /// Vende [cantidad] libras (RD$ 150 c/u) con el método indicado.
  Future<Result<String>> vender({
    double cantidad = 2,
    MetodoPago metodo = MetodoPago.efectivo,
    String? clienteId,
  }) {
    return ventas.registrarVenta(
      tipo: TipoVenta.rapida,
      items: [
        ItemVentaInput(
          productoId: productoId,
          productoNombre: 'Salami',
          cantidad: cantidad,
          precioUnitario: const Money(15000),
        ),
      ],
      usuarioId: usuarioId,
      metodoPago: metodo,
      clienteId: clienteId,
    );
  }

  Future<int> saldo(String clienteId) => saldoDeCliente(db, clienteId);

  Future<int> cantidadEn(String tabla) async {
    final r = await db
        .customSelect('SELECT COUNT(*) AS n FROM $tabla')
        .getSingle();
    return r.read<int>('n');
  }

  Future<double> stock() async => (await (db.select(
    db.productos,
  )..where((t) => t.id.equals(productoId))).getSingle()).stockActual;
}
