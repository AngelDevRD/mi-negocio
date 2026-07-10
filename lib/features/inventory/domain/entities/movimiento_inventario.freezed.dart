// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movimiento_inventario.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MovimientoInventario {

 String get id; TipoMovimientoInventario get tipo;/// Con signo: positiva = entrada, negativa = salida.
 double get cantidad; double get stockResultante;/// Obligatorio en ajustes manuales (RN-19).
 String? get motivo;/// Venta, compra o anulación que originó el movimiento.
 String? get referenciaId; String get usuarioNombre; DateTime get fecha;
/// Create a copy of MovimientoInventario
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovimientoInventarioCopyWith<MovimientoInventario> get copyWith => _$MovimientoInventarioCopyWithImpl<MovimientoInventario>(this as MovimientoInventario, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovimientoInventario&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.stockResultante, stockResultante) || other.stockResultante == stockResultante)&&(identical(other.motivo, motivo) || other.motivo == motivo)&&(identical(other.referenciaId, referenciaId) || other.referenciaId == referenciaId)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre)&&(identical(other.fecha, fecha) || other.fecha == fecha));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,cantidad,stockResultante,motivo,referenciaId,usuarioNombre,fecha);

@override
String toString() {
  return 'MovimientoInventario(id: $id, tipo: $tipo, cantidad: $cantidad, stockResultante: $stockResultante, motivo: $motivo, referenciaId: $referenciaId, usuarioNombre: $usuarioNombre, fecha: $fecha)';
}


}

/// @nodoc
abstract mixin class $MovimientoInventarioCopyWith<$Res>  {
  factory $MovimientoInventarioCopyWith(MovimientoInventario value, $Res Function(MovimientoInventario) _then) = _$MovimientoInventarioCopyWithImpl;
@useResult
$Res call({
 String id, TipoMovimientoInventario tipo, double cantidad, double stockResultante, String? motivo, String? referenciaId, String usuarioNombre, DateTime fecha
});




}
/// @nodoc
class _$MovimientoInventarioCopyWithImpl<$Res>
    implements $MovimientoInventarioCopyWith<$Res> {
  _$MovimientoInventarioCopyWithImpl(this._self, this._then);

  final MovimientoInventario _self;
  final $Res Function(MovimientoInventario) _then;

/// Create a copy of MovimientoInventario
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tipo = null,Object? cantidad = null,Object? stockResultante = null,Object? motivo = freezed,Object? referenciaId = freezed,Object? usuarioNombre = null,Object? fecha = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoMovimientoInventario,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,stockResultante: null == stockResultante ? _self.stockResultante : stockResultante // ignore: cast_nullable_to_non_nullable
as double,motivo: freezed == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String?,referenciaId: freezed == referenciaId ? _self.referenciaId : referenciaId // ignore: cast_nullable_to_non_nullable
as String?,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MovimientoInventario].
extension MovimientoInventarioPatterns on MovimientoInventario {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovimientoInventario value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovimientoInventario() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovimientoInventario value)  $default,){
final _that = this;
switch (_that) {
case _MovimientoInventario():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovimientoInventario value)?  $default,){
final _that = this;
switch (_that) {
case _MovimientoInventario() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TipoMovimientoInventario tipo,  double cantidad,  double stockResultante,  String? motivo,  String? referenciaId,  String usuarioNombre,  DateTime fecha)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovimientoInventario() when $default != null:
return $default(_that.id,_that.tipo,_that.cantidad,_that.stockResultante,_that.motivo,_that.referenciaId,_that.usuarioNombre,_that.fecha);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TipoMovimientoInventario tipo,  double cantidad,  double stockResultante,  String? motivo,  String? referenciaId,  String usuarioNombre,  DateTime fecha)  $default,) {final _that = this;
switch (_that) {
case _MovimientoInventario():
return $default(_that.id,_that.tipo,_that.cantidad,_that.stockResultante,_that.motivo,_that.referenciaId,_that.usuarioNombre,_that.fecha);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TipoMovimientoInventario tipo,  double cantidad,  double stockResultante,  String? motivo,  String? referenciaId,  String usuarioNombre,  DateTime fecha)?  $default,) {final _that = this;
switch (_that) {
case _MovimientoInventario() when $default != null:
return $default(_that.id,_that.tipo,_that.cantidad,_that.stockResultante,_that.motivo,_that.referenciaId,_that.usuarioNombre,_that.fecha);case _:
  return null;

}
}

}

/// @nodoc


class _MovimientoInventario implements MovimientoInventario {
  const _MovimientoInventario({required this.id, required this.tipo, required this.cantidad, required this.stockResultante, this.motivo, this.referenciaId, required this.usuarioNombre, required this.fecha});
  

@override final  String id;
@override final  TipoMovimientoInventario tipo;
/// Con signo: positiva = entrada, negativa = salida.
@override final  double cantidad;
@override final  double stockResultante;
/// Obligatorio en ajustes manuales (RN-19).
@override final  String? motivo;
/// Venta, compra o anulación que originó el movimiento.
@override final  String? referenciaId;
@override final  String usuarioNombre;
@override final  DateTime fecha;

/// Create a copy of MovimientoInventario
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovimientoInventarioCopyWith<_MovimientoInventario> get copyWith => __$MovimientoInventarioCopyWithImpl<_MovimientoInventario>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovimientoInventario&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.stockResultante, stockResultante) || other.stockResultante == stockResultante)&&(identical(other.motivo, motivo) || other.motivo == motivo)&&(identical(other.referenciaId, referenciaId) || other.referenciaId == referenciaId)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre)&&(identical(other.fecha, fecha) || other.fecha == fecha));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,cantidad,stockResultante,motivo,referenciaId,usuarioNombre,fecha);

@override
String toString() {
  return 'MovimientoInventario(id: $id, tipo: $tipo, cantidad: $cantidad, stockResultante: $stockResultante, motivo: $motivo, referenciaId: $referenciaId, usuarioNombre: $usuarioNombre, fecha: $fecha)';
}


}

/// @nodoc
abstract mixin class _$MovimientoInventarioCopyWith<$Res> implements $MovimientoInventarioCopyWith<$Res> {
  factory _$MovimientoInventarioCopyWith(_MovimientoInventario value, $Res Function(_MovimientoInventario) _then) = __$MovimientoInventarioCopyWithImpl;
@override @useResult
$Res call({
 String id, TipoMovimientoInventario tipo, double cantidad, double stockResultante, String? motivo, String? referenciaId, String usuarioNombre, DateTime fecha
});




}
/// @nodoc
class __$MovimientoInventarioCopyWithImpl<$Res>
    implements _$MovimientoInventarioCopyWith<$Res> {
  __$MovimientoInventarioCopyWithImpl(this._self, this._then);

  final _MovimientoInventario _self;
  final $Res Function(_MovimientoInventario) _then;

/// Create a copy of MovimientoInventario
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tipo = null,Object? cantidad = null,Object? stockResultante = null,Object? motivo = freezed,Object? referenciaId = freezed,Object? usuarioNombre = null,Object? fecha = null,}) {
  return _then(_MovimientoInventario(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoMovimientoInventario,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,stockResultante: null == stockResultante ? _self.stockResultante : stockResultante // ignore: cast_nullable_to_non_nullable
as double,motivo: freezed == motivo ? _self.motivo : motivo // ignore: cast_nullable_to_non_nullable
as String?,referenciaId: freezed == referenciaId ? _self.referenciaId : referenciaId // ignore: cast_nullable_to_non_nullable
as String?,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
