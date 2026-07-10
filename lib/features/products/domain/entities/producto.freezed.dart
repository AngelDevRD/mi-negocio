// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'producto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Categoria {

 String get id; String get nombre;
/// Create a copy of Categoria
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoriaCopyWith<Categoria> get copyWith => _$CategoriaCopyWithImpl<Categoria>(this as Categoria, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Categoria&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre);

@override
String toString() {
  return 'Categoria(id: $id, nombre: $nombre)';
}


}

/// @nodoc
abstract mixin class $CategoriaCopyWith<$Res>  {
  factory $CategoriaCopyWith(Categoria value, $Res Function(Categoria) _then) = _$CategoriaCopyWithImpl;
@useResult
$Res call({
 String id, String nombre
});




}
/// @nodoc
class _$CategoriaCopyWithImpl<$Res>
    implements $CategoriaCopyWith<$Res> {
  _$CategoriaCopyWithImpl(this._self, this._then);

  final Categoria _self;
  final $Res Function(Categoria) _then;

/// Create a copy of Categoria
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Categoria].
extension CategoriaPatterns on Categoria {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Categoria value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Categoria() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Categoria value)  $default,){
final _that = this;
switch (_that) {
case _Categoria():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Categoria value)?  $default,){
final _that = this;
switch (_that) {
case _Categoria() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Categoria() when $default != null:
return $default(_that.id,_that.nombre);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre)  $default,) {final _that = this;
switch (_that) {
case _Categoria():
return $default(_that.id,_that.nombre);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre)?  $default,) {final _that = this;
switch (_that) {
case _Categoria() when $default != null:
return $default(_that.id,_that.nombre);case _:
  return null;

}
}

}

/// @nodoc


class _Categoria implements Categoria {
  const _Categoria({required this.id, required this.nombre});
  

@override final  String id;
@override final  String nombre;

/// Create a copy of Categoria
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoriaCopyWith<_Categoria> get copyWith => __$CategoriaCopyWithImpl<_Categoria>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Categoria&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre);

@override
String toString() {
  return 'Categoria(id: $id, nombre: $nombre)';
}


}

/// @nodoc
abstract mixin class _$CategoriaCopyWith<$Res> implements $CategoriaCopyWith<$Res> {
  factory _$CategoriaCopyWith(_Categoria value, $Res Function(_Categoria) _then) = __$CategoriaCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre
});




}
/// @nodoc
class __$CategoriaCopyWithImpl<$Res>
    implements _$CategoriaCopyWith<$Res> {
  __$CategoriaCopyWithImpl(this._self, this._then);

  final _Categoria _self;
  final $Res Function(_Categoria) _then;

/// Create a copy of Categoria
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,}) {
  return _then(_Categoria(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Producto {

 String get id; String get nombre; String? get categoriaId; String? get categoriaNombre; String get unidad; Money get precioCompra; Money get precioVenta; double get stockActual; double get stockMinimo; bool get activo;
/// Create a copy of Producto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductoCopyWith<Producto> get copyWith => _$ProductoCopyWithImpl<Producto>(this as Producto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Producto&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.categoriaId, categoriaId) || other.categoriaId == categoriaId)&&(identical(other.categoriaNombre, categoriaNombre) || other.categoriaNombre == categoriaNombre)&&(identical(other.unidad, unidad) || other.unidad == unidad)&&(identical(other.precioCompra, precioCompra) || other.precioCompra == precioCompra)&&(identical(other.precioVenta, precioVenta) || other.precioVenta == precioVenta)&&(identical(other.stockActual, stockActual) || other.stockActual == stockActual)&&(identical(other.stockMinimo, stockMinimo) || other.stockMinimo == stockMinimo)&&(identical(other.activo, activo) || other.activo == activo));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,categoriaId,categoriaNombre,unidad,precioCompra,precioVenta,stockActual,stockMinimo,activo);

@override
String toString() {
  return 'Producto(id: $id, nombre: $nombre, categoriaId: $categoriaId, categoriaNombre: $categoriaNombre, unidad: $unidad, precioCompra: $precioCompra, precioVenta: $precioVenta, stockActual: $stockActual, stockMinimo: $stockMinimo, activo: $activo)';
}


}

/// @nodoc
abstract mixin class $ProductoCopyWith<$Res>  {
  factory $ProductoCopyWith(Producto value, $Res Function(Producto) _then) = _$ProductoCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, String? categoriaId, String? categoriaNombre, String unidad, Money precioCompra, Money precioVenta, double stockActual, double stockMinimo, bool activo
});




}
/// @nodoc
class _$ProductoCopyWithImpl<$Res>
    implements $ProductoCopyWith<$Res> {
  _$ProductoCopyWithImpl(this._self, this._then);

  final Producto _self;
  final $Res Function(Producto) _then;

/// Create a copy of Producto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? categoriaId = freezed,Object? categoriaNombre = freezed,Object? unidad = null,Object? precioCompra = null,Object? precioVenta = null,Object? stockActual = null,Object? stockMinimo = null,Object? activo = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,categoriaId: freezed == categoriaId ? _self.categoriaId : categoriaId // ignore: cast_nullable_to_non_nullable
as String?,categoriaNombre: freezed == categoriaNombre ? _self.categoriaNombre : categoriaNombre // ignore: cast_nullable_to_non_nullable
as String?,unidad: null == unidad ? _self.unidad : unidad // ignore: cast_nullable_to_non_nullable
as String,precioCompra: null == precioCompra ? _self.precioCompra : precioCompra // ignore: cast_nullable_to_non_nullable
as Money,precioVenta: null == precioVenta ? _self.precioVenta : precioVenta // ignore: cast_nullable_to_non_nullable
as Money,stockActual: null == stockActual ? _self.stockActual : stockActual // ignore: cast_nullable_to_non_nullable
as double,stockMinimo: null == stockMinimo ? _self.stockMinimo : stockMinimo // ignore: cast_nullable_to_non_nullable
as double,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Producto].
extension ProductoPatterns on Producto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Producto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Producto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Producto value)  $default,){
final _that = this;
switch (_that) {
case _Producto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Producto value)?  $default,){
final _that = this;
switch (_that) {
case _Producto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  String? categoriaId,  String? categoriaNombre,  String unidad,  Money precioCompra,  Money precioVenta,  double stockActual,  double stockMinimo,  bool activo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Producto() when $default != null:
return $default(_that.id,_that.nombre,_that.categoriaId,_that.categoriaNombre,_that.unidad,_that.precioCompra,_that.precioVenta,_that.stockActual,_that.stockMinimo,_that.activo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  String? categoriaId,  String? categoriaNombre,  String unidad,  Money precioCompra,  Money precioVenta,  double stockActual,  double stockMinimo,  bool activo)  $default,) {final _that = this;
switch (_that) {
case _Producto():
return $default(_that.id,_that.nombre,_that.categoriaId,_that.categoriaNombre,_that.unidad,_that.precioCompra,_that.precioVenta,_that.stockActual,_that.stockMinimo,_that.activo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  String? categoriaId,  String? categoriaNombre,  String unidad,  Money precioCompra,  Money precioVenta,  double stockActual,  double stockMinimo,  bool activo)?  $default,) {final _that = this;
switch (_that) {
case _Producto() when $default != null:
return $default(_that.id,_that.nombre,_that.categoriaId,_that.categoriaNombre,_that.unidad,_that.precioCompra,_that.precioVenta,_that.stockActual,_that.stockMinimo,_that.activo);case _:
  return null;

}
}

}

/// @nodoc


class _Producto extends Producto {
  const _Producto({required this.id, required this.nombre, this.categoriaId, this.categoriaNombre, required this.unidad, required this.precioCompra, required this.precioVenta, required this.stockActual, required this.stockMinimo, required this.activo}): super._();
  

@override final  String id;
@override final  String nombre;
@override final  String? categoriaId;
@override final  String? categoriaNombre;
@override final  String unidad;
@override final  Money precioCompra;
@override final  Money precioVenta;
@override final  double stockActual;
@override final  double stockMinimo;
@override final  bool activo;

/// Create a copy of Producto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductoCopyWith<_Producto> get copyWith => __$ProductoCopyWithImpl<_Producto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Producto&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.categoriaId, categoriaId) || other.categoriaId == categoriaId)&&(identical(other.categoriaNombre, categoriaNombre) || other.categoriaNombre == categoriaNombre)&&(identical(other.unidad, unidad) || other.unidad == unidad)&&(identical(other.precioCompra, precioCompra) || other.precioCompra == precioCompra)&&(identical(other.precioVenta, precioVenta) || other.precioVenta == precioVenta)&&(identical(other.stockActual, stockActual) || other.stockActual == stockActual)&&(identical(other.stockMinimo, stockMinimo) || other.stockMinimo == stockMinimo)&&(identical(other.activo, activo) || other.activo == activo));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,categoriaId,categoriaNombre,unidad,precioCompra,precioVenta,stockActual,stockMinimo,activo);

@override
String toString() {
  return 'Producto(id: $id, nombre: $nombre, categoriaId: $categoriaId, categoriaNombre: $categoriaNombre, unidad: $unidad, precioCompra: $precioCompra, precioVenta: $precioVenta, stockActual: $stockActual, stockMinimo: $stockMinimo, activo: $activo)';
}


}

/// @nodoc
abstract mixin class _$ProductoCopyWith<$Res> implements $ProductoCopyWith<$Res> {
  factory _$ProductoCopyWith(_Producto value, $Res Function(_Producto) _then) = __$ProductoCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, String? categoriaId, String? categoriaNombre, String unidad, Money precioCompra, Money precioVenta, double stockActual, double stockMinimo, bool activo
});




}
/// @nodoc
class __$ProductoCopyWithImpl<$Res>
    implements _$ProductoCopyWith<$Res> {
  __$ProductoCopyWithImpl(this._self, this._then);

  final _Producto _self;
  final $Res Function(_Producto) _then;

/// Create a copy of Producto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? categoriaId = freezed,Object? categoriaNombre = freezed,Object? unidad = null,Object? precioCompra = null,Object? precioVenta = null,Object? stockActual = null,Object? stockMinimo = null,Object? activo = null,}) {
  return _then(_Producto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,categoriaId: freezed == categoriaId ? _self.categoriaId : categoriaId // ignore: cast_nullable_to_non_nullable
as String?,categoriaNombre: freezed == categoriaNombre ? _self.categoriaNombre : categoriaNombre // ignore: cast_nullable_to_non_nullable
as String?,unidad: null == unidad ? _self.unidad : unidad // ignore: cast_nullable_to_non_nullable
as String,precioCompra: null == precioCompra ? _self.precioCompra : precioCompra // ignore: cast_nullable_to_non_nullable
as Money,precioVenta: null == precioVenta ? _self.precioVenta : precioVenta // ignore: cast_nullable_to_non_nullable
as Money,stockActual: null == stockActual ? _self.stockActual : stockActual // ignore: cast_nullable_to_non_nullable
as double,stockMinimo: null == stockMinimo ? _self.stockMinimo : stockMinimo // ignore: cast_nullable_to_non_nullable
as double,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$HistorialPrecio {

 String get id; TipoPrecio get tipo; Money get precioAnterior; Money get precioNuevo; DateTime get fecha; String get usuarioNombre;
/// Create a copy of HistorialPrecio
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistorialPrecioCopyWith<HistorialPrecio> get copyWith => _$HistorialPrecioCopyWithImpl<HistorialPrecio>(this as HistorialPrecio, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistorialPrecio&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.precioAnterior, precioAnterior) || other.precioAnterior == precioAnterior)&&(identical(other.precioNuevo, precioNuevo) || other.precioNuevo == precioNuevo)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,precioAnterior,precioNuevo,fecha,usuarioNombre);

@override
String toString() {
  return 'HistorialPrecio(id: $id, tipo: $tipo, precioAnterior: $precioAnterior, precioNuevo: $precioNuevo, fecha: $fecha, usuarioNombre: $usuarioNombre)';
}


}

/// @nodoc
abstract mixin class $HistorialPrecioCopyWith<$Res>  {
  factory $HistorialPrecioCopyWith(HistorialPrecio value, $Res Function(HistorialPrecio) _then) = _$HistorialPrecioCopyWithImpl;
@useResult
$Res call({
 String id, TipoPrecio tipo, Money precioAnterior, Money precioNuevo, DateTime fecha, String usuarioNombre
});




}
/// @nodoc
class _$HistorialPrecioCopyWithImpl<$Res>
    implements $HistorialPrecioCopyWith<$Res> {
  _$HistorialPrecioCopyWithImpl(this._self, this._then);

  final HistorialPrecio _self;
  final $Res Function(HistorialPrecio) _then;

/// Create a copy of HistorialPrecio
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tipo = null,Object? precioAnterior = null,Object? precioNuevo = null,Object? fecha = null,Object? usuarioNombre = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPrecio,precioAnterior: null == precioAnterior ? _self.precioAnterior : precioAnterior // ignore: cast_nullable_to_non_nullable
as Money,precioNuevo: null == precioNuevo ? _self.precioNuevo : precioNuevo // ignore: cast_nullable_to_non_nullable
as Money,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HistorialPrecio].
extension HistorialPrecioPatterns on HistorialPrecio {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistorialPrecio value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistorialPrecio() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistorialPrecio value)  $default,){
final _that = this;
switch (_that) {
case _HistorialPrecio():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistorialPrecio value)?  $default,){
final _that = this;
switch (_that) {
case _HistorialPrecio() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TipoPrecio tipo,  Money precioAnterior,  Money precioNuevo,  DateTime fecha,  String usuarioNombre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistorialPrecio() when $default != null:
return $default(_that.id,_that.tipo,_that.precioAnterior,_that.precioNuevo,_that.fecha,_that.usuarioNombre);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TipoPrecio tipo,  Money precioAnterior,  Money precioNuevo,  DateTime fecha,  String usuarioNombre)  $default,) {final _that = this;
switch (_that) {
case _HistorialPrecio():
return $default(_that.id,_that.tipo,_that.precioAnterior,_that.precioNuevo,_that.fecha,_that.usuarioNombre);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TipoPrecio tipo,  Money precioAnterior,  Money precioNuevo,  DateTime fecha,  String usuarioNombre)?  $default,) {final _that = this;
switch (_that) {
case _HistorialPrecio() when $default != null:
return $default(_that.id,_that.tipo,_that.precioAnterior,_that.precioNuevo,_that.fecha,_that.usuarioNombre);case _:
  return null;

}
}

}

/// @nodoc


class _HistorialPrecio implements HistorialPrecio {
  const _HistorialPrecio({required this.id, required this.tipo, required this.precioAnterior, required this.precioNuevo, required this.fecha, required this.usuarioNombre});
  

@override final  String id;
@override final  TipoPrecio tipo;
@override final  Money precioAnterior;
@override final  Money precioNuevo;
@override final  DateTime fecha;
@override final  String usuarioNombre;

/// Create a copy of HistorialPrecio
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistorialPrecioCopyWith<_HistorialPrecio> get copyWith => __$HistorialPrecioCopyWithImpl<_HistorialPrecio>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistorialPrecio&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.precioAnterior, precioAnterior) || other.precioAnterior == precioAnterior)&&(identical(other.precioNuevo, precioNuevo) || other.precioNuevo == precioNuevo)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,precioAnterior,precioNuevo,fecha,usuarioNombre);

@override
String toString() {
  return 'HistorialPrecio(id: $id, tipo: $tipo, precioAnterior: $precioAnterior, precioNuevo: $precioNuevo, fecha: $fecha, usuarioNombre: $usuarioNombre)';
}


}

/// @nodoc
abstract mixin class _$HistorialPrecioCopyWith<$Res> implements $HistorialPrecioCopyWith<$Res> {
  factory _$HistorialPrecioCopyWith(_HistorialPrecio value, $Res Function(_HistorialPrecio) _then) = __$HistorialPrecioCopyWithImpl;
@override @useResult
$Res call({
 String id, TipoPrecio tipo, Money precioAnterior, Money precioNuevo, DateTime fecha, String usuarioNombre
});




}
/// @nodoc
class __$HistorialPrecioCopyWithImpl<$Res>
    implements _$HistorialPrecioCopyWith<$Res> {
  __$HistorialPrecioCopyWithImpl(this._self, this._then);

  final _HistorialPrecio _self;
  final $Res Function(_HistorialPrecio) _then;

/// Create a copy of HistorialPrecio
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tipo = null,Object? precioAnterior = null,Object? precioNuevo = null,Object? fecha = null,Object? usuarioNombre = null,}) {
  return _then(_HistorialPrecio(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPrecio,precioAnterior: null == precioAnterior ? _self.precioAnterior : precioAnterior // ignore: cast_nullable_to_non_nullable
as Money,precioNuevo: null == precioNuevo ? _self.precioNuevo : precioNuevo // ignore: cast_nullable_to_non_nullable
as Money,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
