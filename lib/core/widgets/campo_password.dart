import 'package:flutter/material.dart';

/// Campo de contraseña con botón mostrar/ocultar (con tooltip). El texto vive
/// solo en el [controller]: nunca se registra ni se muestra fuera del campo.
///
/// Uso: `CampoPassword(controller: c, label: 'Contraseña', onEnviar: entrar)`.
/// Con [accion] `done` (por defecto) Enter llama a [onEnviar].
class CampoPassword extends StatefulWidget {
  const CampoPassword({
    super.key,
    required this.controller,
    this.label = 'Contraseña',
    this.onEnviar,
    this.accion = TextInputAction.done,
    this.autofocus = false,
    this.enabled = true,
    this.helperText,
    this.validator,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback? onEnviar;
  final TextInputAction accion;
  final bool autofocus;
  final bool enabled;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;

  @override
  State<CampoPassword> createState() => _CampoPasswordState();
}

class _CampoPasswordState extends State<CampoPassword> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      obscureText: _oculta,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.accion,
      onFieldSubmitted: (_) {
        if (widget.accion == TextInputAction.done) widget.onEnviar?.call();
      },
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        suffixIcon: IconButton(
          tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
          icon: Icon(
            _oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
      validator: widget.validator,
    );
  }
}
