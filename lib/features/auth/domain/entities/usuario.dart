import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/database/enums.dart';

part 'usuario.freezed.dart';

/// Usuario local del negocio (RF-AUTH). La contraseña nunca se expone aquí:
/// solo vive como hash+salt en la tabla `usuarios`.
@freezed
abstract class Usuario with _$Usuario {
  const factory Usuario({
    required String id,
    required String negocioId,
    required String nombre,
    required String username,
    required RolUsuario rol,
    required bool activo,
  }) = _Usuario;

  const Usuario._();

  bool get esAdministrador => rol == RolUsuario.administrador;
}
