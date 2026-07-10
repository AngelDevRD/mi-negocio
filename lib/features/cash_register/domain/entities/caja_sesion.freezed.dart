// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caja_sesion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CajaMovimiento {

 String get id; TipoCajaMovimiento get tipo; Money get monto; String? get motivo; String? get referenciaId; DateTime get fecha;
/// Create a copy of CajaMovimiento
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CajaMovimientoCopyWith<CajaMovimiento> get copyWith => _$CajaMovimientoCopyWithImpl<CajaMovimiento>(this as CajaMovimiento, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CajaMovimiento&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.motivo, motivo) || other.motivo == motivo)&&(identical(other.referenciaId, referenciaId) || other.referenciaId == referenciaId)&&(identical(other.fecha, fecha) || other.fecha == fecha));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,monto,motivo,referenciaId,fecha);

@override
String toString() {
  return 'CajaMovimiento(id: $id, tipo: $tipo, monto: $monto, motivo: $motivo, referenciaId: $referenciaId, fecha: $fecha)';
}


}

/// @nodoc
abstract mixin class $CajaMovimientoCopyWith<$Res>  {
  factory $CajaMovimientoCopyWith(CajaMovimiento value, $Res Function(CajaMovimiento) _then) = _$CajaMovimientoCopyWithImpl;
@useResult
$Res call({
 String id, TipoCajaMovimiento tipo, Money monto, String? motivo, String? referenciaId, DateTime fecha
});




}
/// @nodoc
class _$CajaMovimientoCopyWithImpl<$Res>
    implements $CajaMovimientoCopyWith<$Res> {
  _$CajaMovimientoCopyWithImpl(this._self, this._then);

  final CajaMovimiento _self;
  final $Res Function(CajaMovimiento) _then;

/// Create a copy of CajaMovimiento
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tipo = null,Object? monto = null,Object? motivo = freezed,Object? referenciaId = freezed,Object? fecha = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoCajaMovimiento,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,motivo: freezed == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String?,referenciaId: freezed == referenciaId ? _self.referenciaId : referenciaId // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CajaMovimiento].
extension CajaMovimientoPatterns on CajaMovimiento {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CajaMovimiento value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CajaMovimiento() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CajaMovimiento value)  $default,){
final _that = this;
switch (_that) {
case _CajaMovimiento():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CajaMovimiento value)?  $default,){
final _that = this;
switch (_that) {
case _CajaMovimiento() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TipoCajaMovimiento tipo,  Money monto,  String? motivo,  String? referenciaId,  DateTime fecha)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CajaMovimiento() when $default != null:
return $default(_that.id,_that.tipo,_that.monto,_that.motivo,_that.referenciaId,_that.fecha);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TipoCajaMovimiento tipo,  Money monto,  String? motivo,  String? referenciaId,  DateTime fecha)  $default,) {final _that = this;
switch (_that) {
case _CajaMovimiento():
return $default(_that.id,_that.tipo,_that.monto,_that.motivo,_that.referenciaId,_that.fecha);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TipoCajaMovimiento tipo,  Money monto,  String? motivo,  String? referenciaId,  DateTime fecha)?  $default,) {final _that = this;
switch (_that) {
case _CajaMovimiento() when $default != null:
return $default(_that.id,_that.tipo,_that.monto,_that.motivo,_that.referenciaId,_that.fecha);case _:
  return null;

}
}

}

/// @nodoc


class _CajaMovimiento implements CajaMovimiento {
  const _CajaMovimiento({required this.id, required this.tipo, required this.monto, this.motivo, this.referenciaId, required this.fecha});
  

@override final  String id;
@override final  TipoCajaMovimiento tipo;
@override final  Money monto;
@override final  String? motivo;
@override final  String? referenciaId;
@override final  DateTime fecha;

/// Create a copy of CajaMovimiento
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CajaMovimientoCopyWith<_CajaMovimiento> get copyWith => __$CajaMovimientoCopyWithImpl<_CajaMovimiento>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CajaMovimiento&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.motivo, motivo) || other.motivo == motivo)&&(identical(other.referenciaId, referenciaId) || other.referenciaId == referenciaId)&&(identical(other.fecha, fecha) || other.fecha == fecha));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,monto,motivo,referenciaId,fecha);

@override
String toString() {
  return 'CajaMovimiento(id: $id, tipo: $tipo, monto: $monto, motivo: $motivo, referenciaId: $referenciaId, fecha: $fecha)';
}


}

/// @nodoc
abstract mixin class _$CajaMovimientoCopyWith<$Res> implements $CajaMovimientoCopyWith<$Res> {
  factory _$CajaMovimientoCopyWith(_CajaMovimiento value, $Res Function(_CajaMovimiento) _then) = __$CajaMovimientoCopyWithImpl;
@override @useResult
$Res call({
 String id, TipoCajaMovimiento tipo, Money monto, String? motivo, String? referenciaId, DateTime fecha
});




}
/// @nodoc
class __$CajaMovimientoCopyWithImpl<$Res>
    implements _$CajaMovimientoCopyWith<$Res> {
  __$CajaMovimientoCopyWithImpl(this._self, this._then);

  final _CajaMovimiento _self;
  final $Res Function(_CajaMovimiento) _then;

/// Create a copy of CajaMovimiento
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tipo = null,Object? monto = null,Object? motivo = freezed,Object? referenciaId = freezed,Object? fecha = null,}) {
  return _then(_CajaMovimiento(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoCajaMovimiento,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,motivo: freezed == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String?,referenciaId: freezed == referenciaId ? _self.referenciaId : referenciaId // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$CajaSesion {

 String get id; DateTime get fechaApertura; Money get montoApertura; DateTime? get fechaCierre; Money? get montoEsperado; Money? get montoContado; Money? get diferencia; Money? get montoDejadoSiguiente; String get usuarioAperturaNombre; String? get usuarioCierreNombre; EstadoCajaSesion get estado; List<CajaMovimiento> get movimientos;
/// Create a copy of CajaSesion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CajaSesionCopyWith<CajaSesion> get copyWith => _$CajaSesionCopyWithImpl<CajaSesion>(this as CajaSesion, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CajaSesion&&(identical(other.id, id) || other.id == id)&&(identical(other.fechaApertura, fechaApertura) || other.fechaApertura == fechaApertura)&&(identical(other.montoApertura, montoApertura) || other.montoApertura == montoApertura)&&(identical(other.fechaCierre, fechaCierre) || other.fechaCierre == fechaCierre)&&(identical(other.montoEsperado, montoEsperado) || other.montoEsperado == montoEsperado)&&(identical(other.montoContado, montoContado) || other.montoContado == montoContado)&&(identical(other.diferencia, diferencia) || other.diferencia == diferencia)&&(identical(other.montoDejadoSiguiente, montoDejadoSiguiente) || other.montoDejadoSiguiente == montoDejadoSiguiente)&&(identical(other.usuarioAperturaNombre, usuarioAperturaNombre) || other.usuarioAperturaNombre == usuarioAperturaNombre)&&(identical(other.usuarioCierreNombre, usuarioCierreNombre) || other.usuarioCierreNombre == usuarioCierreNombre)&&(identical(other.estado, estado) || other.estado == estado)&&const DeepCollectionEquality().equals(other.movimientos, movimientos));
}


@override
int get hashCode => Object.hash(runtimeType,id,fechaApertura,montoApertura,fechaCierre,montoEsperado,montoContado,diferencia,montoDejadoSiguiente,usuarioAperturaNombre,usuarioCierreNombre,estado,const DeepCollectionEquality().hash(movimientos));

@override
String toString() {
  return 'CajaSesion(id: $id, fechaApertura: $fechaApertura, montoApertura: $montoApertura, fechaCierre: $fechaCierre, montoEsperado: $montoEsperado, montoContado: $montoContado, diferencia: $diferencia, montoDejadoSiguiente: $montoDejadoSiguiente, usuarioAperturaNombre: $usuarioAperturaNombre, usuarioCierreNombre: $usuarioCierreNombre, estado: $estado, movimientos: $movimientos)';
}


}

/// @nodoc
abstract mixin class $CajaSesionCopyWith<$Res>  {
  factory $CajaSesionCopyWith(CajaSesion value, $Res Function(CajaSesion) _then) = _$CajaSesionCopyWithImpl;
@useResult
$Res call({
 String id, DateTime fechaApertura, Money montoApertura, DateTime? fechaCierre, Money? montoEsperado, Money? montoContado, Money? diferencia, Money? montoDejadoSiguiente, String usuarioAperturaNombre, String? usuarioCierreNombre, EstadoCajaSesion estado, List<CajaMovimiento> movimientos
});




}
/// @nodoc
class _$CajaSesionCopyWithImpl<$Res>
    implements $CajaSesionCopyWith<$Res> {
  _$CajaSesionCopyWithImpl(this._self, this._then);

  final CajaSesion _self;
  final $Res Function(CajaSesion) _then;

/// Create a copy of CajaSesion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fechaApertura = null,Object? montoApertura = null,Object? fechaCierre = freezed,Object? montoEsperado = freezed,Object? montoContado = freezed,Object? diferencia = freezed,Object? montoDejadoSiguiente = freezed,Object? usuarioAperturaNombre = null,Object? usuarioCierreNombre = freezed,Object? estado = null,Object? movimientos = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fechaApertura: null == fechaApertura ? _self.fechaApertura : fechaApertura // ignore: cast_nullable_to_non_nullable
as DateTime,montoApertura: null == montoApertura ? _self.montoApertura : montoApertura // ignore: cast_nullable_to_non_nullable
as Money,fechaCierre: freezed == fechaCierre ? _self.fechaCierre : fechaCierre // ignore: cast_nullable_to_non_nullable
as DateTime?,montoEsperado: freezed == montoEsperado ? _self.montoEsperado : montoEsperado // ignore: cast_nullable_to_non_nullable
as Money?,montoContado: freezed == montoContado ? _self.montoContado : montoContado // ignore: cast_nullable_to_non_nullable
as Money?,diferencia: freezed == diferencia ? _self.diferencia : diferencia // ignore: cast_nullable_to_non_nullable
as Money?,montoDejadoSiguiente: freezed == montoDejadoSiguiente ? _self.montoDejadoSiguiente : montoDejadoSiguiente // ignore: cast_nullable_to_non_nullable
as Money?,usuarioAperturaNombre: null == usuarioAperturaNombre ? _self.usuarioAperturaNombre : usuarioAperturaNombre // ignore: cast_nullable_to_non_nullable
as String,usuarioCierreNombre: freezed == usuarioCierreNombre ? _self.usuarioCierreNombre : usuarioCierreNombre // ignore: cast_nullable_to_non_nullable
as String?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoCajaSesion,movimientos: null == movimientos ? _self.movimientos : movimientos // ignore: cast_nullable_to_non_nullable
as List<CajaMovimiento>,
  ));
}

}


/// Adds pattern-matching-related methods to [CajaSesion].
extension CajaSesionPatterns on CajaSesion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CajaSesion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CajaSesion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CajaSesion value)  $default,){
final _that = this;
switch (_that) {
case _CajaSesion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CajaSesion value)?  $default,){
final _that = this;
switch (_that) {
case _CajaSesion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime fechaApertura,  Money montoApertura,  DateTime? fechaCierre,  Money? montoEsperado,  Money? montoContado,  Money? diferencia,  Money? montoDejadoSiguiente,  String usuarioAperturaNombre,  String? usuarioCierreNombre,  EstadoCajaSesion estado,  List<CajaMovimiento> movimientos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CajaSesion() when $default != null:
return $default(_that.id,_that.fechaApertura,_that.montoApertura,_that.fechaCierre,_that.montoEsperado,_that.montoContado,_that.diferencia,_that.montoDejadoSiguiente,_that.usuarioAperturaNombre,_that.usuarioCierreNombre,_that.estado,_that.movimientos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime fechaApertura,  Money montoApertura,  DateTime? fechaCierre,  Money? montoEsperado,  Money? montoContado,  Money? diferencia,  Money? montoDejadoSiguiente,  String usuarioAperturaNombre,  String? usuarioCierreNombre,  EstadoCajaSesion estado,  List<CajaMovimiento> movimientos)  $default,) {final _that = this;
switch (_that) {
case _CajaSesion():
return $default(_that.id,_that.fechaApertura,_that.montoApertura,_that.fechaCierre,_that.montoEsperado,_that.montoContado,_that.diferencia,_that.montoDejadoSiguiente,_that.usuarioAperturaNombre,_that.usuarioCierreNombre,_that.estado,_that.movimientos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime fechaApertura,  Money montoApertura,  DateTime? fechaCierre,  Money? montoEsperado,  Money? montoContado,  Money? diferencia,  Money? montoDejadoSiguiente,  String usuarioAperturaNombre,  String? usuarioCierreNombre,  EstadoCajaSesion estado,  List<CajaMovimiento> movimientos)?  $default,) {final _that = this;
switch (_that) {
case _CajaSesion() when $default != null:
return $default(_that.id,_that.fechaApertura,_that.montoApertura,_that.fechaCierre,_that.montoEsperado,_that.montoContado,_that.diferencia,_that.montoDejadoSiguiente,_that.usuarioAperturaNombre,_that.usuarioCierreNombre,_that.estado,_that.movimientos);case _:
  return null;

}
}

}

/// @nodoc


class _CajaSesion extends CajaSesion {
  const _CajaSesion({required this.id, required this.fechaApertura, required this.montoApertura, this.fechaCierre, this.montoEsperado, this.montoContado, this.diferencia, this.montoDejadoSiguiente, required this.usuarioAperturaNombre, this.usuarioCierreNombre, required this.estado, final  List<CajaMovimiento> movimientos = const []}): _movimientos = movimientos,super._();
  

@override final  String id;
@override final  DateTime fechaApertura;
@override final  Money montoApertura;
@override final  DateTime? fechaCierre;
@override final  Money? montoEsperado;
@override final  Money? montoContado;
@override final  Money? diferencia;
@override final  Money? montoDejadoSiguiente;
@override final  String usuarioAperturaNombre;
@override final  String? usuarioCierreNombre;
@override final  EstadoCajaSesion estado;
 final  List<CajaMovimiento> _movimientos;
@override@JsonKey() List<CajaMovimiento> get movimientos {
  if (_movimientos is EqualUnmodifiableListView) return _movimientos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_movimientos);
}


/// Create a copy of CajaSesion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CajaSesionCopyWith<_CajaSesion> get copyWith => __$CajaSesionCopyWithImpl<_CajaSesion>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CajaSesion&&(identical(other.id, id) || other.id == id)&&(identical(other.fechaApertura, fechaApertura) || other.fechaApertura == fechaApertura)&&(identical(other.montoApertura, montoApertura) || other.montoApertura == montoApertura)&&(identical(other.fechaCierre, fechaCierre) || other.fechaCierre == fechaCierre)&&(identical(other.montoEsperado, montoEsperado) || other.montoEsperado == montoEsperado)&&(identical(other.montoContado, montoContado) || other.montoContado == montoContado)&&(identical(other.diferencia, diferencia) || other.diferencia == diferencia)&&(identical(other.montoDejadoSiguiente, montoDejadoSiguiente) || other.montoDejadoSiguiente == montoDejadoSiguiente)&&(identical(other.usuarioAperturaNombre, usuarioAperturaNombre) || other.usuarioAperturaNombre == usuarioAperturaNombre)&&(identical(other.usuarioCierreNombre, usuarioCierreNombre) || other.usuarioCierreNombre == usuarioCierreNombre)&&(identical(other.estado, estado) || other.estado == estado)&&const DeepCollectionEquality().equals(other._movimientos, _movimientos));
}


@override
int get hashCode => Object.hash(runtimeType,id,fechaApertura,montoApertura,fechaCierre,montoEsperado,montoContado,diferencia,montoDejadoSiguiente,usuarioAperturaNombre,usuarioCierreNombre,estado,const DeepCollectionEquality().hash(_movimientos));

@override
String toString() {
  return 'CajaSesion(id: $id, fechaApertura: $fechaApertura, montoApertura: $montoApertura, fechaCierre: $fechaCierre, montoEsperado: $montoEsperado, montoContado: $montoContado, diferencia: $diferencia, montoDejadoSiguiente: $montoDejadoSiguiente, usuarioAperturaNombre: $usuarioAperturaNombre, usuarioCierreNombre: $usuarioCierreNombre, estado: $estado, movimientos: $movimientos)';
}


}

/// @nodoc
abstract mixin class _$CajaSesionCopyWith<$Res> implements $CajaSesionCopyWith<$Res> {
  factory _$CajaSesionCopyWith(_CajaSesion value, $Res Function(_CajaSesion) _then) = __$CajaSesionCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime fechaApertura, Money montoApertura, DateTime? fechaCierre, Money? montoEsperado, Money? montoContado, Money? diferencia, Money? montoDejadoSiguiente, String usuarioAperturaNombre, String? usuarioCierreNombre, EstadoCajaSesion estado, List<CajaMovimiento> movimientos
});




}
/// @nodoc
class __$CajaSesionCopyWithImpl<$Res>
    implements _$CajaSesionCopyWith<$Res> {
  __$CajaSesionCopyWithImpl(this._self, this._then);

  final _CajaSesion _self;
  final $Res Function(_CajaSesion) _then;

/// Create a copy of CajaSesion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fechaApertura = null,Object? montoApertura = null,Object? fechaCierre = freezed,Object? montoEsperado = freezed,Object? montoContado = freezed,Object? diferencia = freezed,Object? montoDejadoSiguiente = freezed,Object? usuarioAperturaNombre = null,Object? usuarioCierreNombre = freezed,Object? estado = null,Object? movimientos = null,}) {
  return _then(_CajaSesion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fechaApertura: null == fechaApertura ? _self.fechaApertura : fechaApertura // ignore: cast_nullable_to_non_nullable
as DateTime,montoApertura: null == montoApertura ? _self.montoApertura : montoApertura // ignore: cast_nullable_to_non_nullable
as Money,fechaCierre: freezed == fechaCierre ? _self.fechaCierre : fechaCierre // ignore: cast_nullable_to_non_nullable
as DateTime?,montoEsperado: freezed == montoEsperado ? _self.montoEsperado : montoEsperado // ignore: cast_nullable_to_non_nullable
as Money?,montoContado: freezed == montoContado ? _self.montoContado : montoContado // ignore: cast_nullable_to_non_nullable
as Money?,diferencia: freezed == diferencia ? _self.diferencia : diferencia // ignore: cast_nullable_to_non_nullable
as Money?,montoDejadoSiguiente: freezed == montoDejadoSiguiente ? _self.montoDejadoSiguiente : montoDejadoSiguiente // ignore: cast_nullable_to_non_nullable
as Money?,usuarioAperturaNombre: null == usuarioAperturaNombre ? _self.usuarioAperturaNombre : usuarioAperturaNombre // ignore: cast_nullable_to_non_nullable
as String,usuarioCierreNombre: freezed == usuarioCierreNombre ? _self.usuarioCierreNombre : usuarioCierreNombre // ignore: cast_nullable_to_non_nullable
as String?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoCajaSesion,movimientos: null == movimientos ? _self._movimientos : movimientos // ignore: cast_nullable_to_non_nullable
as List<CajaMovimiento>,
  ));
}


}

// dart format on
