// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'licencia.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Licencia {

 TipoLicencia get tipo; EstadoLicencia get estado; String get deviceId; DateTime get fechaActivacion; DateTime get ultimaValidacion; String? get clave; DateTime? get fechaVencimiento; String? get motivoSuspension;
/// Create a copy of Licencia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LicenciaCopyWith<Licencia> get copyWith => _$LicenciaCopyWithImpl<Licencia>(this as Licencia, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Licencia&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.fechaActivacion, fechaActivacion) || other.fechaActivacion == fechaActivacion)&&(identical(other.ultimaValidacion, ultimaValidacion) || other.ultimaValidacion == ultimaValidacion)&&(identical(other.clave, clave) || other.clave == clave)&&(identical(other.fechaVencimiento, fechaVencimiento) || other.fechaVencimiento == fechaVencimiento)&&(identical(other.motivoSuspension, motivoSuspension) || other.motivoSuspension == motivoSuspension));
}


@override
int get hashCode => Object.hash(runtimeType,tipo,estado,deviceId,fechaActivacion,ultimaValidacion,clave,fechaVencimiento,motivoSuspension);

@override
String toString() {
  return 'Licencia(tipo: $tipo, estado: $estado, deviceId: $deviceId, fechaActivacion: $fechaActivacion, ultimaValidacion: $ultimaValidacion, clave: $clave, fechaVencimiento: $fechaVencimiento, motivoSuspension: $motivoSuspension)';
}


}

/// @nodoc
abstract mixin class $LicenciaCopyWith<$Res>  {
  factory $LicenciaCopyWith(Licencia value, $Res Function(Licencia) _then) = _$LicenciaCopyWithImpl;
@useResult
$Res call({
 TipoLicencia tipo, EstadoLicencia estado, String deviceId, DateTime fechaActivacion, DateTime ultimaValidacion, String? clave, DateTime? fechaVencimiento, String? motivoSuspension
});




}
/// @nodoc
class _$LicenciaCopyWithImpl<$Res>
    implements $LicenciaCopyWith<$Res> {
  _$LicenciaCopyWithImpl(this._self, this._then);

  final Licencia _self;
  final $Res Function(Licencia) _then;

/// Create a copy of Licencia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tipo = null,Object? estado = null,Object? deviceId = null,Object? fechaActivacion = null,Object? ultimaValidacion = null,Object? clave = freezed,Object? fechaVencimiento = freezed,Object? motivoSuspension = freezed,}) {
  return _then(_self.copyWith(
tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoLicencia,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoLicencia,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,fechaActivacion: null == fechaActivacion ? _self.fechaActivacion : fechaActivacion // ignore: cast_nullable_to_non_nullable
as DateTime,ultimaValidacion: null == ultimaValidacion ? _self.ultimaValidacion : ultimaValidacion // ignore: cast_nullable_to_non_nullable
as DateTime,clave: freezed == clave ? _self.clave : clave // ignore: cast_nullable_to_non_nullable
as String?,fechaVencimiento: freezed == fechaVencimiento ? _self.fechaVencimiento : fechaVencimiento // ignore: cast_nullable_to_non_nullable
as DateTime?,motivoSuspension: freezed == motivoSuspension ? _self.motivoSuspension : motivoSuspension // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Licencia].
extension LicenciaPatterns on Licencia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Licencia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Licencia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Licencia value)  $default,){
final _that = this;
switch (_that) {
case _Licencia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Licencia value)?  $default,){
final _that = this;
switch (_that) {
case _Licencia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TipoLicencia tipo,  EstadoLicencia estado,  String deviceId,  DateTime fechaActivacion,  DateTime ultimaValidacion,  String? clave,  DateTime? fechaVencimiento,  String? motivoSuspension)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Licencia() when $default != null:
return $default(_that.tipo,_that.estado,_that.deviceId,_that.fechaActivacion,_that.ultimaValidacion,_that.clave,_that.fechaVencimiento,_that.motivoSuspension);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TipoLicencia tipo,  EstadoLicencia estado,  String deviceId,  DateTime fechaActivacion,  DateTime ultimaValidacion,  String? clave,  DateTime? fechaVencimiento,  String? motivoSuspension)  $default,) {final _that = this;
switch (_that) {
case _Licencia():
return $default(_that.tipo,_that.estado,_that.deviceId,_that.fechaActivacion,_that.ultimaValidacion,_that.clave,_that.fechaVencimiento,_that.motivoSuspension);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TipoLicencia tipo,  EstadoLicencia estado,  String deviceId,  DateTime fechaActivacion,  DateTime ultimaValidacion,  String? clave,  DateTime? fechaVencimiento,  String? motivoSuspension)?  $default,) {final _that = this;
switch (_that) {
case _Licencia() when $default != null:
return $default(_that.tipo,_that.estado,_that.deviceId,_that.fechaActivacion,_that.ultimaValidacion,_that.clave,_that.fechaVencimiento,_that.motivoSuspension);case _:
  return null;

}
}

}

/// @nodoc


class _Licencia extends Licencia {
  const _Licencia({required this.tipo, required this.estado, required this.deviceId, required this.fechaActivacion, required this.ultimaValidacion, this.clave, this.fechaVencimiento, this.motivoSuspension}): super._();
  

@override final  TipoLicencia tipo;
@override final  EstadoLicencia estado;
@override final  String deviceId;
@override final  DateTime fechaActivacion;
@override final  DateTime ultimaValidacion;
@override final  String? clave;
@override final  DateTime? fechaVencimiento;
@override final  String? motivoSuspension;

/// Create a copy of Licencia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LicenciaCopyWith<_Licencia> get copyWith => __$LicenciaCopyWithImpl<_Licencia>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Licencia&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.fechaActivacion, fechaActivacion) || other.fechaActivacion == fechaActivacion)&&(identical(other.ultimaValidacion, ultimaValidacion) || other.ultimaValidacion == ultimaValidacion)&&(identical(other.clave, clave) || other.clave == clave)&&(identical(other.fechaVencimiento, fechaVencimiento) || other.fechaVencimiento == fechaVencimiento)&&(identical(other.motivoSuspension, motivoSuspension) || other.motivoSuspension == motivoSuspension));
}


@override
int get hashCode => Object.hash(runtimeType,tipo,estado,deviceId,fechaActivacion,ultimaValidacion,clave,fechaVencimiento,motivoSuspension);

@override
String toString() {
  return 'Licencia(tipo: $tipo, estado: $estado, deviceId: $deviceId, fechaActivacion: $fechaActivacion, ultimaValidacion: $ultimaValidacion, clave: $clave, fechaVencimiento: $fechaVencimiento, motivoSuspension: $motivoSuspension)';
}


}

/// @nodoc
abstract mixin class _$LicenciaCopyWith<$Res> implements $LicenciaCopyWith<$Res> {
  factory _$LicenciaCopyWith(_Licencia value, $Res Function(_Licencia) _then) = __$LicenciaCopyWithImpl;
@override @useResult
$Res call({
 TipoLicencia tipo, EstadoLicencia estado, String deviceId, DateTime fechaActivacion, DateTime ultimaValidacion, String? clave, DateTime? fechaVencimiento, String? motivoSuspension
});




}
/// @nodoc
class __$LicenciaCopyWithImpl<$Res>
    implements _$LicenciaCopyWith<$Res> {
  __$LicenciaCopyWithImpl(this._self, this._then);

  final _Licencia _self;
  final $Res Function(_Licencia) _then;

/// Create a copy of Licencia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tipo = null,Object? estado = null,Object? deviceId = null,Object? fechaActivacion = null,Object? ultimaValidacion = null,Object? clave = freezed,Object? fechaVencimiento = freezed,Object? motivoSuspension = freezed,}) {
  return _then(_Licencia(
tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoLicencia,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoLicencia,deviceId: null == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as String,fechaActivacion: null == fechaActivacion ? _self.fechaActivacion : fechaActivacion // ignore: cast_nullable_to_non_nullable
as DateTime,ultimaValidacion: null == ultimaValidacion ? _self.ultimaValidacion : ultimaValidacion // ignore: cast_nullable_to_non_nullable
as DateTime,clave: freezed == clave ? _self.clave : clave // ignore: cast_nullable_to_non_nullable
as String?,fechaVencimiento: freezed == fechaVencimiento ? _self.fechaVencimiento : fechaVencimiento // ignore: cast_nullable_to_non_nullable
as DateTime?,motivoSuspension: freezed == motivoSuspension ? _self.motivoSuspension : motivoSuspension // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
