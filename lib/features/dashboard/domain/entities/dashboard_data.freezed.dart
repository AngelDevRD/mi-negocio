// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CajaActual {

 String get sesionId; DateTime get fechaApertura; Money get montoApertura; Money get montoActual;
/// Create a copy of CajaActual
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CajaActualCopyWith<CajaActual> get copyWith => _$CajaActualCopyWithImpl<CajaActual>(this as CajaActual, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CajaActual&&(identical(other.sesionId, sesionId) || other.sesionId == sesionId)&&(identical(other.fechaApertura, fechaApertura) || other.fechaApertura == fechaApertura)&&(identical(other.montoApertura, montoApertura) || other.montoApertura == montoApertura)&&(identical(other.montoActual, montoActual) || other.montoActual == montoActual));
}


@override
int get hashCode => Object.hash(runtimeType,sesionId,fechaApertura,montoApertura,montoActual);

@override
String toString() {
  return 'CajaActual(sesionId: $sesionId, fechaApertura: $fechaApertura, montoApertura: $montoApertura, montoActual: $montoActual)';
}


}

/// @nodoc
abstract mixin class $CajaActualCopyWith<$Res>  {
  factory $CajaActualCopyWith(CajaActual value, $Res Function(CajaActual) _then) = _$CajaActualCopyWithImpl;
@useResult
$Res call({
 String sesionId, DateTime fechaApertura, Money montoApertura, Money montoActual
});




}
/// @nodoc
class _$CajaActualCopyWithImpl<$Res>
    implements $CajaActualCopyWith<$Res> {
  _$CajaActualCopyWithImpl(this._self, this._then);

  final CajaActual _self;
  final $Res Function(CajaActual) _then;

/// Create a copy of CajaActual
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sesionId = null,Object? fechaApertura = null,Object? montoApertura = null,Object? montoActual = null,}) {
  return _then(_self.copyWith(
sesionId: null == sesionId ? _self.sesionId : sesionId // ignore: cast_nullable_to_non_nullable
as String,fechaApertura: null == fechaApertura ? _self.fechaApertura : fechaApertura // ignore: cast_nullable_to_non_nullable
as DateTime,montoApertura: null == montoApertura ? _self.montoApertura : montoApertura // ignore: cast_nullable_to_non_nullable
as Money,montoActual: null == montoActual ? _self.montoActual : montoActual // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [CajaActual].
extension CajaActualPatterns on CajaActual {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CajaActual value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CajaActual() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CajaActual value)  $default,){
final _that = this;
switch (_that) {
case _CajaActual():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CajaActual value)?  $default,){
final _that = this;
switch (_that) {
case _CajaActual() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sesionId,  DateTime fechaApertura,  Money montoApertura,  Money montoActual)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CajaActual() when $default != null:
return $default(_that.sesionId,_that.fechaApertura,_that.montoApertura,_that.montoActual);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sesionId,  DateTime fechaApertura,  Money montoApertura,  Money montoActual)  $default,) {final _that = this;
switch (_that) {
case _CajaActual():
return $default(_that.sesionId,_that.fechaApertura,_that.montoApertura,_that.montoActual);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sesionId,  DateTime fechaApertura,  Money montoApertura,  Money montoActual)?  $default,) {final _that = this;
switch (_that) {
case _CajaActual() when $default != null:
return $default(_that.sesionId,_that.fechaApertura,_that.montoApertura,_that.montoActual);case _:
  return null;

}
}

}

/// @nodoc


class _CajaActual implements CajaActual {
  const _CajaActual({required this.sesionId, required this.fechaApertura, required this.montoApertura, required this.montoActual});
  

@override final  String sesionId;
@override final  DateTime fechaApertura;
@override final  Money montoApertura;
@override final  Money montoActual;

/// Create a copy of CajaActual
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CajaActualCopyWith<_CajaActual> get copyWith => __$CajaActualCopyWithImpl<_CajaActual>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CajaActual&&(identical(other.sesionId, sesionId) || other.sesionId == sesionId)&&(identical(other.fechaApertura, fechaApertura) || other.fechaApertura == fechaApertura)&&(identical(other.montoApertura, montoApertura) || other.montoApertura == montoApertura)&&(identical(other.montoActual, montoActual) || other.montoActual == montoActual));
}


@override
int get hashCode => Object.hash(runtimeType,sesionId,fechaApertura,montoApertura,montoActual);

@override
String toString() {
  return 'CajaActual(sesionId: $sesionId, fechaApertura: $fechaApertura, montoApertura: $montoApertura, montoActual: $montoActual)';
}


}

/// @nodoc
abstract mixin class _$CajaActualCopyWith<$Res> implements $CajaActualCopyWith<$Res> {
  factory _$CajaActualCopyWith(_CajaActual value, $Res Function(_CajaActual) _then) = __$CajaActualCopyWithImpl;
@override @useResult
$Res call({
 String sesionId, DateTime fechaApertura, Money montoApertura, Money montoActual
});




}
/// @nodoc
class __$CajaActualCopyWithImpl<$Res>
    implements _$CajaActualCopyWith<$Res> {
  __$CajaActualCopyWithImpl(this._self, this._then);

  final _CajaActual _self;
  final $Res Function(_CajaActual) _then;

/// Create a copy of CajaActual
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sesionId = null,Object? fechaApertura = null,Object? montoApertura = null,Object? montoActual = null,}) {
  return _then(_CajaActual(
sesionId: null == sesionId ? _self.sesionId : sesionId // ignore: cast_nullable_to_non_nullable
as String,fechaApertura: null == fechaApertura ? _self.fechaApertura : fechaApertura // ignore: cast_nullable_to_non_nullable
as DateTime,montoApertura: null == montoApertura ? _self.montoApertura : montoApertura // ignore: cast_nullable_to_non_nullable
as Money,montoActual: null == montoActual ? _self.montoActual : montoActual // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$MovimientoReciente {

 String get id; TipoMovimientoReciente get tipo; DateTime get fecha; Money get monto;
/// Create a copy of MovimientoReciente
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovimientoRecienteCopyWith<MovimientoReciente> get copyWith => _$MovimientoRecienteCopyWithImpl<MovimientoReciente>(this as MovimientoReciente, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovimientoReciente&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.monto, monto) || other.monto == monto));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,fecha,monto);

@override
String toString() {
  return 'MovimientoReciente(id: $id, tipo: $tipo, fecha: $fecha, monto: $monto)';
}


}

/// @nodoc
abstract mixin class $MovimientoRecienteCopyWith<$Res>  {
  factory $MovimientoRecienteCopyWith(MovimientoReciente value, $Res Function(MovimientoReciente) _then) = _$MovimientoRecienteCopyWithImpl;
@useResult
$Res call({
 String id, TipoMovimientoReciente tipo, DateTime fecha, Money monto
});




}
/// @nodoc
class _$MovimientoRecienteCopyWithImpl<$Res>
    implements $MovimientoRecienteCopyWith<$Res> {
  _$MovimientoRecienteCopyWithImpl(this._self, this._then);

  final MovimientoReciente _self;
  final $Res Function(MovimientoReciente) _then;

/// Create a copy of MovimientoReciente
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tipo = null,Object? fecha = null,Object? monto = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoMovimientoReciente,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [MovimientoReciente].
extension MovimientoRecientePatterns on MovimientoReciente {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovimientoReciente value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovimientoReciente() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovimientoReciente value)  $default,){
final _that = this;
switch (_that) {
case _MovimientoReciente():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovimientoReciente value)?  $default,){
final _that = this;
switch (_that) {
case _MovimientoReciente() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TipoMovimientoReciente tipo,  DateTime fecha,  Money monto)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovimientoReciente() when $default != null:
return $default(_that.id,_that.tipo,_that.fecha,_that.monto);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TipoMovimientoReciente tipo,  DateTime fecha,  Money monto)  $default,) {final _that = this;
switch (_that) {
case _MovimientoReciente():
return $default(_that.id,_that.tipo,_that.fecha,_that.monto);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TipoMovimientoReciente tipo,  DateTime fecha,  Money monto)?  $default,) {final _that = this;
switch (_that) {
case _MovimientoReciente() when $default != null:
return $default(_that.id,_that.tipo,_that.fecha,_that.monto);case _:
  return null;

}
}

}

/// @nodoc


class _MovimientoReciente implements MovimientoReciente {
  const _MovimientoReciente({required this.id, required this.tipo, required this.fecha, required this.monto});
  

@override final  String id;
@override final  TipoMovimientoReciente tipo;
@override final  DateTime fecha;
@override final  Money monto;

/// Create a copy of MovimientoReciente
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovimientoRecienteCopyWith<_MovimientoReciente> get copyWith => __$MovimientoRecienteCopyWithImpl<_MovimientoReciente>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovimientoReciente&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.monto, monto) || other.monto == monto));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,fecha,monto);

@override
String toString() {
  return 'MovimientoReciente(id: $id, tipo: $tipo, fecha: $fecha, monto: $monto)';
}


}

/// @nodoc
abstract mixin class _$MovimientoRecienteCopyWith<$Res> implements $MovimientoRecienteCopyWith<$Res> {
  factory _$MovimientoRecienteCopyWith(_MovimientoReciente value, $Res Function(_MovimientoReciente) _then) = __$MovimientoRecienteCopyWithImpl;
@override @useResult
$Res call({
 String id, TipoMovimientoReciente tipo, DateTime fecha, Money monto
});




}
/// @nodoc
class __$MovimientoRecienteCopyWithImpl<$Res>
    implements _$MovimientoRecienteCopyWith<$Res> {
  __$MovimientoRecienteCopyWithImpl(this._self, this._then);

  final _MovimientoReciente _self;
  final $Res Function(_MovimientoReciente) _then;

/// Create a copy of MovimientoReciente
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tipo = null,Object? fecha = null,Object? monto = null,}) {
  return _then(_MovimientoReciente(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoMovimientoReciente,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$ProductoBajoStock {

 String get id; String get nombre; double get stockActual; double get stockMinimo; String get unidad;
/// Create a copy of ProductoBajoStock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductoBajoStockCopyWith<ProductoBajoStock> get copyWith => _$ProductoBajoStockCopyWithImpl<ProductoBajoStock>(this as ProductoBajoStock, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductoBajoStock&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.stockActual, stockActual) || other.stockActual == stockActual)&&(identical(other.stockMinimo, stockMinimo) || other.stockMinimo == stockMinimo)&&(identical(other.unidad, unidad) || other.unidad == unidad));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,stockActual,stockMinimo,unidad);

@override
String toString() {
  return 'ProductoBajoStock(id: $id, nombre: $nombre, stockActual: $stockActual, stockMinimo: $stockMinimo, unidad: $unidad)';
}


}

/// @nodoc
abstract mixin class $ProductoBajoStockCopyWith<$Res>  {
  factory $ProductoBajoStockCopyWith(ProductoBajoStock value, $Res Function(ProductoBajoStock) _then) = _$ProductoBajoStockCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, double stockActual, double stockMinimo, String unidad
});




}
/// @nodoc
class _$ProductoBajoStockCopyWithImpl<$Res>
    implements $ProductoBajoStockCopyWith<$Res> {
  _$ProductoBajoStockCopyWithImpl(this._self, this._then);

  final ProductoBajoStock _self;
  final $Res Function(ProductoBajoStock) _then;

/// Create a copy of ProductoBajoStock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? stockActual = null,Object? stockMinimo = null,Object? unidad = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,stockActual: null == stockActual ? _self.stockActual : stockActual // ignore: cast_nullable_to_non_nullable
as double,stockMinimo: null == stockMinimo ? _self.stockMinimo : stockMinimo // ignore: cast_nullable_to_non_nullable
as double,unidad: null == unidad ? _self.unidad : unidad // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductoBajoStock].
extension ProductoBajoStockPatterns on ProductoBajoStock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductoBajoStock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductoBajoStock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductoBajoStock value)  $default,){
final _that = this;
switch (_that) {
case _ProductoBajoStock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductoBajoStock value)?  $default,){
final _that = this;
switch (_that) {
case _ProductoBajoStock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  double stockActual,  double stockMinimo,  String unidad)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductoBajoStock() when $default != null:
return $default(_that.id,_that.nombre,_that.stockActual,_that.stockMinimo,_that.unidad);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  double stockActual,  double stockMinimo,  String unidad)  $default,) {final _that = this;
switch (_that) {
case _ProductoBajoStock():
return $default(_that.id,_that.nombre,_that.stockActual,_that.stockMinimo,_that.unidad);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  double stockActual,  double stockMinimo,  String unidad)?  $default,) {final _that = this;
switch (_that) {
case _ProductoBajoStock() when $default != null:
return $default(_that.id,_that.nombre,_that.stockActual,_that.stockMinimo,_that.unidad);case _:
  return null;

}
}

}

/// @nodoc


class _ProductoBajoStock implements ProductoBajoStock {
  const _ProductoBajoStock({required this.id, required this.nombre, required this.stockActual, required this.stockMinimo, required this.unidad});
  

@override final  String id;
@override final  String nombre;
@override final  double stockActual;
@override final  double stockMinimo;
@override final  String unidad;

/// Create a copy of ProductoBajoStock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductoBajoStockCopyWith<_ProductoBajoStock> get copyWith => __$ProductoBajoStockCopyWithImpl<_ProductoBajoStock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductoBajoStock&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.stockActual, stockActual) || other.stockActual == stockActual)&&(identical(other.stockMinimo, stockMinimo) || other.stockMinimo == stockMinimo)&&(identical(other.unidad, unidad) || other.unidad == unidad));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,stockActual,stockMinimo,unidad);

@override
String toString() {
  return 'ProductoBajoStock(id: $id, nombre: $nombre, stockActual: $stockActual, stockMinimo: $stockMinimo, unidad: $unidad)';
}


}

/// @nodoc
abstract mixin class _$ProductoBajoStockCopyWith<$Res> implements $ProductoBajoStockCopyWith<$Res> {
  factory _$ProductoBajoStockCopyWith(_ProductoBajoStock value, $Res Function(_ProductoBajoStock) _then) = __$ProductoBajoStockCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, double stockActual, double stockMinimo, String unidad
});




}
/// @nodoc
class __$ProductoBajoStockCopyWithImpl<$Res>
    implements _$ProductoBajoStockCopyWith<$Res> {
  __$ProductoBajoStockCopyWithImpl(this._self, this._then);

  final _ProductoBajoStock _self;
  final $Res Function(_ProductoBajoStock) _then;

/// Create a copy of ProductoBajoStock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? stockActual = null,Object? stockMinimo = null,Object? unidad = null,}) {
  return _then(_ProductoBajoStock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,stockActual: null == stockActual ? _self.stockActual : stockActual // ignore: cast_nullable_to_non_nullable
as double,stockMinimo: null == stockMinimo ? _self.stockMinimo : stockMinimo // ignore: cast_nullable_to_non_nullable
as double,unidad: null == unidad ? _self.unidad : unidad // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
