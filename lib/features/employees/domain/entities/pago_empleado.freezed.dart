// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pago_empleado.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PagoEmpleado {

 String get id; DateTime get fecha; Money get monto; String? get periodo; bool get saleDeCaja; String get usuarioNombre;
/// Create a copy of PagoEmpleado
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagoEmpleadoCopyWith<PagoEmpleado> get copyWith => _$PagoEmpleadoCopyWithImpl<PagoEmpleado>(this as PagoEmpleado, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagoEmpleado&&(identical(other.id, id) || other.id == id)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.periodo, periodo) || other.periodo == periodo)&&(identical(other.saleDeCaja, saleDeCaja) || other.saleDeCaja == saleDeCaja)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,fecha,monto,periodo,saleDeCaja,usuarioNombre);

@override
String toString() {
  return 'PagoEmpleado(id: $id, fecha: $fecha, monto: $monto, periodo: $periodo, saleDeCaja: $saleDeCaja, usuarioNombre: $usuarioNombre)';
}


}

/// @nodoc
abstract mixin class $PagoEmpleadoCopyWith<$Res>  {
  factory $PagoEmpleadoCopyWith(PagoEmpleado value, $Res Function(PagoEmpleado) _then) = _$PagoEmpleadoCopyWithImpl;
@useResult
$Res call({
 String id, DateTime fecha, Money monto, String? periodo, bool saleDeCaja, String usuarioNombre
});




}
/// @nodoc
class _$PagoEmpleadoCopyWithImpl<$Res>
    implements $PagoEmpleadoCopyWith<$Res> {
  _$PagoEmpleadoCopyWithImpl(this._self, this._then);

  final PagoEmpleado _self;
  final $Res Function(PagoEmpleado) _then;

/// Create a copy of PagoEmpleado
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fecha = null,Object? monto = null,Object? periodo = freezed,Object? saleDeCaja = null,Object? usuarioNombre = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,periodo: freezed == periodo ? _self.periodo : periodo // ignore: cast_nullable_to_non_nullable
as String?,saleDeCaja: null == saleDeCaja ? _self.saleDeCaja : saleDeCaja // ignore: cast_nullable_to_non_nullable
as bool,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PagoEmpleado].
extension PagoEmpleadoPatterns on PagoEmpleado {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagoEmpleado value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagoEmpleado() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagoEmpleado value)  $default,){
final _that = this;
switch (_that) {
case _PagoEmpleado():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagoEmpleado value)?  $default,){
final _that = this;
switch (_that) {
case _PagoEmpleado() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime fecha,  Money monto,  String? periodo,  bool saleDeCaja,  String usuarioNombre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagoEmpleado() when $default != null:
return $default(_that.id,_that.fecha,_that.monto,_that.periodo,_that.saleDeCaja,_that.usuarioNombre);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime fecha,  Money monto,  String? periodo,  bool saleDeCaja,  String usuarioNombre)  $default,) {final _that = this;
switch (_that) {
case _PagoEmpleado():
return $default(_that.id,_that.fecha,_that.monto,_that.periodo,_that.saleDeCaja,_that.usuarioNombre);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime fecha,  Money monto,  String? periodo,  bool saleDeCaja,  String usuarioNombre)?  $default,) {final _that = this;
switch (_that) {
case _PagoEmpleado() when $default != null:
return $default(_that.id,_that.fecha,_that.monto,_that.periodo,_that.saleDeCaja,_that.usuarioNombre);case _:
  return null;

}
}

}

/// @nodoc


class _PagoEmpleado implements PagoEmpleado {
  const _PagoEmpleado({required this.id, required this.fecha, required this.monto, this.periodo, required this.saleDeCaja, required this.usuarioNombre});
  

@override final  String id;
@override final  DateTime fecha;
@override final  Money monto;
@override final  String? periodo;
@override final  bool saleDeCaja;
@override final  String usuarioNombre;

/// Create a copy of PagoEmpleado
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagoEmpleadoCopyWith<_PagoEmpleado> get copyWith => __$PagoEmpleadoCopyWithImpl<_PagoEmpleado>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagoEmpleado&&(identical(other.id, id) || other.id == id)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.periodo, periodo) || other.periodo == periodo)&&(identical(other.saleDeCaja, saleDeCaja) || other.saleDeCaja == saleDeCaja)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,fecha,monto,periodo,saleDeCaja,usuarioNombre);

@override
String toString() {
  return 'PagoEmpleado(id: $id, fecha: $fecha, monto: $monto, periodo: $periodo, saleDeCaja: $saleDeCaja, usuarioNombre: $usuarioNombre)';
}


}

/// @nodoc
abstract mixin class _$PagoEmpleadoCopyWith<$Res> implements $PagoEmpleadoCopyWith<$Res> {
  factory _$PagoEmpleadoCopyWith(_PagoEmpleado value, $Res Function(_PagoEmpleado) _then) = __$PagoEmpleadoCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime fecha, Money monto, String? periodo, bool saleDeCaja, String usuarioNombre
});




}
/// @nodoc
class __$PagoEmpleadoCopyWithImpl<$Res>
    implements _$PagoEmpleadoCopyWith<$Res> {
  __$PagoEmpleadoCopyWithImpl(this._self, this._then);

  final _PagoEmpleado _self;
  final $Res Function(_PagoEmpleado) _then;

/// Create a copy of PagoEmpleado
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fecha = null,Object? monto = null,Object? periodo = freezed,Object? saleDeCaja = null,Object? usuarioNombre = null,}) {
  return _then(_PagoEmpleado(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,periodo: freezed == periodo ? _self.periodo : periodo // ignore: cast_nullable_to_non_nullable
as String?,saleDeCaja: null == saleDeCaja ? _self.saleDeCaja : saleDeCaja // ignore: cast_nullable_to_non_nullable
as bool,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
