// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'empleado.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Empleado {

 String get id; TipoEmpleado get tipo; String? get fotoPath; String get nombre; String? get cedula; String? get direccion; String? get telefono; DateTime get fechaIngreso; bool get activo; Money? get salario; String? get frecuenciaPago;
/// Create a copy of Empleado
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmpleadoCopyWith<Empleado> get copyWith => _$EmpleadoCopyWithImpl<Empleado>(this as Empleado, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Empleado&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.fotoPath, fotoPath) || other.fotoPath == fotoPath)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.cedula, cedula) || other.cedula == cedula)&&(identical(other.direccion, direccion) || other.direccion == direccion)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.fechaIngreso, fechaIngreso) || other.fechaIngreso == fechaIngreso)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.salario, salario) || other.salario == salario)&&(identical(other.frecuenciaPago, frecuenciaPago) || other.frecuenciaPago == frecuenciaPago));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,fotoPath,nombre,cedula,direccion,telefono,fechaIngreso,activo,salario,frecuenciaPago);

@override
String toString() {
  return 'Empleado(id: $id, tipo: $tipo, fotoPath: $fotoPath, nombre: $nombre, cedula: $cedula, direccion: $direccion, telefono: $telefono, fechaIngreso: $fechaIngreso, activo: $activo, salario: $salario, frecuenciaPago: $frecuenciaPago)';
}


}

/// @nodoc
abstract mixin class $EmpleadoCopyWith<$Res>  {
  factory $EmpleadoCopyWith(Empleado value, $Res Function(Empleado) _then) = _$EmpleadoCopyWithImpl;
@useResult
$Res call({
 String id, TipoEmpleado tipo, String? fotoPath, String nombre, String? cedula, String? direccion, String? telefono, DateTime fechaIngreso, bool activo, Money? salario, String? frecuenciaPago
});




}
/// @nodoc
class _$EmpleadoCopyWithImpl<$Res>
    implements $EmpleadoCopyWith<$Res> {
  _$EmpleadoCopyWithImpl(this._self, this._then);

  final Empleado _self;
  final $Res Function(Empleado) _then;

/// Create a copy of Empleado
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tipo = null,Object? fotoPath = freezed,Object? nombre = null,Object? cedula = freezed,Object? direccion = freezed,Object? telefono = freezed,Object? fechaIngreso = null,Object? activo = null,Object? salario = freezed,Object? frecuenciaPago = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoEmpleado,fotoPath: freezed == fotoPath ? _self.fotoPath : fotoPath // ignore: cast_nullable_to_non_nullable
as String?,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,cedula: freezed == cedula ? _self.cedula : cedula // ignore: cast_nullable_to_non_nullable
as String?,direccion: freezed == direccion ? _self.direccion : direccion // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,fechaIngreso: null == fechaIngreso ? _self.fechaIngreso : fechaIngreso // ignore: cast_nullable_to_non_nullable
as DateTime,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,salario: freezed == salario ? _self.salario : salario // ignore: cast_nullable_to_non_nullable
as Money?,frecuenciaPago: freezed == frecuenciaPago ? _self.frecuenciaPago : frecuenciaPago // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Empleado].
extension EmpleadoPatterns on Empleado {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Empleado value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Empleado() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Empleado value)  $default,){
final _that = this;
switch (_that) {
case _Empleado():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Empleado value)?  $default,){
final _that = this;
switch (_that) {
case _Empleado() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TipoEmpleado tipo,  String? fotoPath,  String nombre,  String? cedula,  String? direccion,  String? telefono,  DateTime fechaIngreso,  bool activo,  Money? salario,  String? frecuenciaPago)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Empleado() when $default != null:
return $default(_that.id,_that.tipo,_that.fotoPath,_that.nombre,_that.cedula,_that.direccion,_that.telefono,_that.fechaIngreso,_that.activo,_that.salario,_that.frecuenciaPago);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TipoEmpleado tipo,  String? fotoPath,  String nombre,  String? cedula,  String? direccion,  String? telefono,  DateTime fechaIngreso,  bool activo,  Money? salario,  String? frecuenciaPago)  $default,) {final _that = this;
switch (_that) {
case _Empleado():
return $default(_that.id,_that.tipo,_that.fotoPath,_that.nombre,_that.cedula,_that.direccion,_that.telefono,_that.fechaIngreso,_that.activo,_that.salario,_that.frecuenciaPago);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TipoEmpleado tipo,  String? fotoPath,  String nombre,  String? cedula,  String? direccion,  String? telefono,  DateTime fechaIngreso,  bool activo,  Money? salario,  String? frecuenciaPago)?  $default,) {final _that = this;
switch (_that) {
case _Empleado() when $default != null:
return $default(_that.id,_that.tipo,_that.fotoPath,_that.nombre,_that.cedula,_that.direccion,_that.telefono,_that.fechaIngreso,_that.activo,_that.salario,_that.frecuenciaPago);case _:
  return null;

}
}

}

/// @nodoc


class _Empleado extends Empleado {
  const _Empleado({required this.id, required this.tipo, this.fotoPath, required this.nombre, this.cedula, this.direccion, this.telefono, required this.fechaIngreso, required this.activo, this.salario, this.frecuenciaPago}): super._();
  

@override final  String id;
@override final  TipoEmpleado tipo;
@override final  String? fotoPath;
@override final  String nombre;
@override final  String? cedula;
@override final  String? direccion;
@override final  String? telefono;
@override final  DateTime fechaIngreso;
@override final  bool activo;
@override final  Money? salario;
@override final  String? frecuenciaPago;

/// Create a copy of Empleado
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmpleadoCopyWith<_Empleado> get copyWith => __$EmpleadoCopyWithImpl<_Empleado>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Empleado&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.fotoPath, fotoPath) || other.fotoPath == fotoPath)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.cedula, cedula) || other.cedula == cedula)&&(identical(other.direccion, direccion) || other.direccion == direccion)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.fechaIngreso, fechaIngreso) || other.fechaIngreso == fechaIngreso)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.salario, salario) || other.salario == salario)&&(identical(other.frecuenciaPago, frecuenciaPago) || other.frecuenciaPago == frecuenciaPago));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,fotoPath,nombre,cedula,direccion,telefono,fechaIngreso,activo,salario,frecuenciaPago);

@override
String toString() {
  return 'Empleado(id: $id, tipo: $tipo, fotoPath: $fotoPath, nombre: $nombre, cedula: $cedula, direccion: $direccion, telefono: $telefono, fechaIngreso: $fechaIngreso, activo: $activo, salario: $salario, frecuenciaPago: $frecuenciaPago)';
}


}

/// @nodoc
abstract mixin class _$EmpleadoCopyWith<$Res> implements $EmpleadoCopyWith<$Res> {
  factory _$EmpleadoCopyWith(_Empleado value, $Res Function(_Empleado) _then) = __$EmpleadoCopyWithImpl;
@override @useResult
$Res call({
 String id, TipoEmpleado tipo, String? fotoPath, String nombre, String? cedula, String? direccion, String? telefono, DateTime fechaIngreso, bool activo, Money? salario, String? frecuenciaPago
});




}
/// @nodoc
class __$EmpleadoCopyWithImpl<$Res>
    implements _$EmpleadoCopyWith<$Res> {
  __$EmpleadoCopyWithImpl(this._self, this._then);

  final _Empleado _self;
  final $Res Function(_Empleado) _then;

/// Create a copy of Empleado
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tipo = null,Object? fotoPath = freezed,Object? nombre = null,Object? cedula = freezed,Object? direccion = freezed,Object? telefono = freezed,Object? fechaIngreso = null,Object? activo = null,Object? salario = freezed,Object? frecuenciaPago = freezed,}) {
  return _then(_Empleado(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoEmpleado,fotoPath: freezed == fotoPath ? _self.fotoPath : fotoPath // ignore: cast_nullable_to_non_nullable
as String?,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,cedula: freezed == cedula ? _self.cedula : cedula // ignore: cast_nullable_to_non_nullable
as String?,direccion: freezed == direccion ? _self.direccion : direccion // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,fechaIngreso: null == fechaIngreso ? _self.fechaIngreso : fechaIngreso // ignore: cast_nullable_to_non_nullable
as DateTime,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,salario: freezed == salario ? _self.salario : salario // ignore: cast_nullable_to_non_nullable
as Money?,frecuenciaPago: freezed == frecuenciaPago ? _self.frecuenciaPago : frecuenciaPago // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
