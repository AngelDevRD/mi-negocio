// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registro_auditoria.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegistroAuditoria {

 String get id; String get usuarioId; String get usuarioNombre; String get accion; String get modulo; String? get entidadId; Map<String, Object?>? get datosAntes; Map<String, Object?>? get datosDespues; DateTime get fecha;
/// Create a copy of RegistroAuditoria
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistroAuditoriaCopyWith<RegistroAuditoria> get copyWith => _$RegistroAuditoriaCopyWithImpl<RegistroAuditoria>(this as RegistroAuditoria, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistroAuditoria&&(identical(other.id, id) || other.id == id)&&(identical(other.usuarioId, usuarioId) || other.usuarioId == usuarioId)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre)&&(identical(other.accion, accion) || other.accion == accion)&&(identical(other.modulo, modulo) || other.modulo == modulo)&&(identical(other.entidadId, entidadId) || other.entidadId == entidadId)&&const DeepCollectionEquality().equals(other.datosAntes, datosAntes)&&const DeepCollectionEquality().equals(other.datosDespues, datosDespues)&&(identical(other.fecha, fecha) || other.fecha == fecha));
}


@override
int get hashCode => Object.hash(runtimeType,id,usuarioId,usuarioNombre,accion,modulo,entidadId,const DeepCollectionEquality().hash(datosAntes),const DeepCollectionEquality().hash(datosDespues),fecha);

@override
String toString() {
  return 'RegistroAuditoria(id: $id, usuarioId: $usuarioId, usuarioNombre: $usuarioNombre, accion: $accion, modulo: $modulo, entidadId: $entidadId, datosAntes: $datosAntes, datosDespues: $datosDespues, fecha: $fecha)';
}


}

/// @nodoc
abstract mixin class $RegistroAuditoriaCopyWith<$Res>  {
  factory $RegistroAuditoriaCopyWith(RegistroAuditoria value, $Res Function(RegistroAuditoria) _then) = _$RegistroAuditoriaCopyWithImpl;
@useResult
$Res call({
 String id, String usuarioId, String usuarioNombre, String accion, String modulo, String? entidadId, Map<String, Object?>? datosAntes, Map<String, Object?>? datosDespues, DateTime fecha
});




}
/// @nodoc
class _$RegistroAuditoriaCopyWithImpl<$Res>
    implements $RegistroAuditoriaCopyWith<$Res> {
  _$RegistroAuditoriaCopyWithImpl(this._self, this._then);

  final RegistroAuditoria _self;
  final $Res Function(RegistroAuditoria) _then;

/// Create a copy of RegistroAuditoria
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? usuarioId = null,Object? usuarioNombre = null,Object? accion = null,Object? modulo = null,Object? entidadId = freezed,Object? datosAntes = freezed,Object? datosDespues = freezed,Object? fecha = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,usuarioId: null == usuarioId ? _self.usuarioId : usuarioId // ignore: cast_nullable_to_non_nullable
as String,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,accion: null == accion ? _self.accion : accion // ignore: cast_nullable_to_non_nullable
as String,modulo: null == modulo ? _self.modulo : modulo // ignore: cast_nullable_to_non_nullable
as String,entidadId: freezed == entidadId ? _self.entidadId : entidadId // ignore: cast_nullable_to_non_nullable
as String?,datosAntes: freezed == datosAntes ? _self.datosAntes : datosAntes // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,datosDespues: freezed == datosDespues ? _self.datosDespues : datosDespues // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RegistroAuditoria].
extension RegistroAuditoriaPatterns on RegistroAuditoria {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RegistroAuditoria value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RegistroAuditoria() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RegistroAuditoria value)  $default,){
final _that = this;
switch (_that) {
case _RegistroAuditoria():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RegistroAuditoria value)?  $default,){
final _that = this;
switch (_that) {
case _RegistroAuditoria() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String usuarioId,  String usuarioNombre,  String accion,  String modulo,  String? entidadId,  Map<String, Object?>? datosAntes,  Map<String, Object?>? datosDespues,  DateTime fecha)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RegistroAuditoria() when $default != null:
return $default(_that.id,_that.usuarioId,_that.usuarioNombre,_that.accion,_that.modulo,_that.entidadId,_that.datosAntes,_that.datosDespues,_that.fecha);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String usuarioId,  String usuarioNombre,  String accion,  String modulo,  String? entidadId,  Map<String, Object?>? datosAntes,  Map<String, Object?>? datosDespues,  DateTime fecha)  $default,) {final _that = this;
switch (_that) {
case _RegistroAuditoria():
return $default(_that.id,_that.usuarioId,_that.usuarioNombre,_that.accion,_that.modulo,_that.entidadId,_that.datosAntes,_that.datosDespues,_that.fecha);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String usuarioId,  String usuarioNombre,  String accion,  String modulo,  String? entidadId,  Map<String, Object?>? datosAntes,  Map<String, Object?>? datosDespues,  DateTime fecha)?  $default,) {final _that = this;
switch (_that) {
case _RegistroAuditoria() when $default != null:
return $default(_that.id,_that.usuarioId,_that.usuarioNombre,_that.accion,_that.modulo,_that.entidadId,_that.datosAntes,_that.datosDespues,_that.fecha);case _:
  return null;

}
}

}

/// @nodoc


class _RegistroAuditoria implements RegistroAuditoria {
  const _RegistroAuditoria({required this.id, required this.usuarioId, required this.usuarioNombre, required this.accion, required this.modulo, this.entidadId, final  Map<String, Object?>? datosAntes, final  Map<String, Object?>? datosDespues, required this.fecha}): _datosAntes = datosAntes,_datosDespues = datosDespues;
  

@override final  String id;
@override final  String usuarioId;
@override final  String usuarioNombre;
@override final  String accion;
@override final  String modulo;
@override final  String? entidadId;
 final  Map<String, Object?>? _datosAntes;
@override Map<String, Object?>? get datosAntes {
  final value = _datosAntes;
  if (value == null) return null;
  if (_datosAntes is EqualUnmodifiableMapView) return _datosAntes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, Object?>? _datosDespues;
@override Map<String, Object?>? get datosDespues {
  final value = _datosDespues;
  if (value == null) return null;
  if (_datosDespues is EqualUnmodifiableMapView) return _datosDespues;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime fecha;

/// Create a copy of RegistroAuditoria
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegistroAuditoriaCopyWith<_RegistroAuditoria> get copyWith => __$RegistroAuditoriaCopyWithImpl<_RegistroAuditoria>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RegistroAuditoria&&(identical(other.id, id) || other.id == id)&&(identical(other.usuarioId, usuarioId) || other.usuarioId == usuarioId)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre)&&(identical(other.accion, accion) || other.accion == accion)&&(identical(other.modulo, modulo) || other.modulo == modulo)&&(identical(other.entidadId, entidadId) || other.entidadId == entidadId)&&const DeepCollectionEquality().equals(other._datosAntes, _datosAntes)&&const DeepCollectionEquality().equals(other._datosDespues, _datosDespues)&&(identical(other.fecha, fecha) || other.fecha == fecha));
}


@override
int get hashCode => Object.hash(runtimeType,id,usuarioId,usuarioNombre,accion,modulo,entidadId,const DeepCollectionEquality().hash(_datosAntes),const DeepCollectionEquality().hash(_datosDespues),fecha);

@override
String toString() {
  return 'RegistroAuditoria(id: $id, usuarioId: $usuarioId, usuarioNombre: $usuarioNombre, accion: $accion, modulo: $modulo, entidadId: $entidadId, datosAntes: $datosAntes, datosDespues: $datosDespues, fecha: $fecha)';
}


}

/// @nodoc
abstract mixin class _$RegistroAuditoriaCopyWith<$Res> implements $RegistroAuditoriaCopyWith<$Res> {
  factory _$RegistroAuditoriaCopyWith(_RegistroAuditoria value, $Res Function(_RegistroAuditoria) _then) = __$RegistroAuditoriaCopyWithImpl;
@override @useResult
$Res call({
 String id, String usuarioId, String usuarioNombre, String accion, String modulo, String? entidadId, Map<String, Object?>? datosAntes, Map<String, Object?>? datosDespues, DateTime fecha
});




}
/// @nodoc
class __$RegistroAuditoriaCopyWithImpl<$Res>
    implements _$RegistroAuditoriaCopyWith<$Res> {
  __$RegistroAuditoriaCopyWithImpl(this._self, this._then);

  final _RegistroAuditoria _self;
  final $Res Function(_RegistroAuditoria) _then;

/// Create a copy of RegistroAuditoria
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? usuarioId = null,Object? usuarioNombre = null,Object? accion = null,Object? modulo = null,Object? entidadId = freezed,Object? datosAntes = freezed,Object? datosDespues = freezed,Object? fecha = null,}) {
  return _then(_RegistroAuditoria(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,usuarioId: null == usuarioId ? _self.usuarioId : usuarioId // ignore: cast_nullable_to_non_nullable
as String,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,accion: null == accion ? _self.accion : accion // ignore: cast_nullable_to_non_nullable
as String,modulo: null == modulo ? _self.modulo : modulo // ignore: cast_nullable_to_non_nullable
as String,entidadId: freezed == entidadId ? _self.entidadId : entidadId // ignore: cast_nullable_to_non_nullable
as String?,datosAntes: freezed == datosAntes ? _self._datosAntes : datosAntes // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,datosDespues: freezed == datosDespues ? _self._datosDespues : datosDespues // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
