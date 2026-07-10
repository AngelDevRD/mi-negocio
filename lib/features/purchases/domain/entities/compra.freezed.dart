// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'compra.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompraItem {

 String get productoId; String get productoNombre; double get cantidad; Money get costoUnitario;
/// Create a copy of CompraItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompraItemCopyWith<CompraItem> get copyWith => _$CompraItemCopyWithImpl<CompraItem>(this as CompraItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompraItem&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.productoNombre, productoNombre) || other.productoNombre == productoNombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.costoUnitario, costoUnitario) || other.costoUnitario == costoUnitario));
}


@override
int get hashCode => Object.hash(runtimeType,productoId,productoNombre,cantidad,costoUnitario);

@override
String toString() {
  return 'CompraItem(productoId: $productoId, productoNombre: $productoNombre, cantidad: $cantidad, costoUnitario: $costoUnitario)';
}


}

/// @nodoc
abstract mixin class $CompraItemCopyWith<$Res>  {
  factory $CompraItemCopyWith(CompraItem value, $Res Function(CompraItem) _then) = _$CompraItemCopyWithImpl;
@useResult
$Res call({
 String productoId, String productoNombre, double cantidad, Money costoUnitario
});




}
/// @nodoc
class _$CompraItemCopyWithImpl<$Res>
    implements $CompraItemCopyWith<$Res> {
  _$CompraItemCopyWithImpl(this._self, this._then);

  final CompraItem _self;
  final $Res Function(CompraItem) _then;

/// Create a copy of CompraItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productoId = null,Object? productoNombre = null,Object? cantidad = null,Object? costoUnitario = null,}) {
  return _then(_self.copyWith(
productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,productoNombre: null == productoNombre ? _self.productoNombre : productoNombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,costoUnitario: null == costoUnitario ? _self.costoUnitario : costoUnitario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [CompraItem].
extension CompraItemPatterns on CompraItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompraItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompraItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompraItem value)  $default,){
final _that = this;
switch (_that) {
case _CompraItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompraItem value)?  $default,){
final _that = this;
switch (_that) {
case _CompraItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productoId,  String productoNombre,  double cantidad,  Money costoUnitario)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompraItem() when $default != null:
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.costoUnitario);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productoId,  String productoNombre,  double cantidad,  Money costoUnitario)  $default,) {final _that = this;
switch (_that) {
case _CompraItem():
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.costoUnitario);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productoId,  String productoNombre,  double cantidad,  Money costoUnitario)?  $default,) {final _that = this;
switch (_that) {
case _CompraItem() when $default != null:
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.costoUnitario);case _:
  return null;

}
}

}

/// @nodoc


class _CompraItem extends CompraItem {
  const _CompraItem({required this.productoId, required this.productoNombre, required this.cantidad, required this.costoUnitario}): super._();
  

@override final  String productoId;
@override final  String productoNombre;
@override final  double cantidad;
@override final  Money costoUnitario;

/// Create a copy of CompraItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompraItemCopyWith<_CompraItem> get copyWith => __$CompraItemCopyWithImpl<_CompraItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompraItem&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.productoNombre, productoNombre) || other.productoNombre == productoNombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.costoUnitario, costoUnitario) || other.costoUnitario == costoUnitario));
}


@override
int get hashCode => Object.hash(runtimeType,productoId,productoNombre,cantidad,costoUnitario);

@override
String toString() {
  return 'CompraItem(productoId: $productoId, productoNombre: $productoNombre, cantidad: $cantidad, costoUnitario: $costoUnitario)';
}


}

/// @nodoc
abstract mixin class _$CompraItemCopyWith<$Res> implements $CompraItemCopyWith<$Res> {
  factory _$CompraItemCopyWith(_CompraItem value, $Res Function(_CompraItem) _then) = __$CompraItemCopyWithImpl;
@override @useResult
$Res call({
 String productoId, String productoNombre, double cantidad, Money costoUnitario
});




}
/// @nodoc
class __$CompraItemCopyWithImpl<$Res>
    implements _$CompraItemCopyWith<$Res> {
  __$CompraItemCopyWithImpl(this._self, this._then);

  final _CompraItem _self;
  final $Res Function(_CompraItem) _then;

/// Create a copy of CompraItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productoId = null,Object? productoNombre = null,Object? cantidad = null,Object? costoUnitario = null,}) {
  return _then(_CompraItem(
productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,productoNombre: null == productoNombre ? _self.productoNombre : productoNombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,costoUnitario: null == costoUnitario ? _self.costoUnitario : costoUnitario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$Compra {

 String get id; String? get proveedorId; String? get proveedorNombre; String? get numeroFactura; String? get fotoFacturaPath; Money get total; bool get pagadaDeCaja; EstadoCompra get estado; String get usuarioNombre; DateTime get fecha; List<CompraItem> get items;
/// Create a copy of Compra
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompraCopyWith<Compra> get copyWith => _$CompraCopyWithImpl<Compra>(this as Compra, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Compra&&(identical(other.id, id) || other.id == id)&&(identical(other.proveedorId, proveedorId) || other.proveedorId == proveedorId)&&(identical(other.proveedorNombre, proveedorNombre) || other.proveedorNombre == proveedorNombre)&&(identical(other.numeroFactura, numeroFactura) || other.numeroFactura == numeroFactura)&&(identical(other.fotoFacturaPath, fotoFacturaPath) || other.fotoFacturaPath == fotoFacturaPath)&&(identical(other.total, total) || other.total == total)&&(identical(other.pagadaDeCaja, pagadaDeCaja) || other.pagadaDeCaja == pagadaDeCaja)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,id,proveedorId,proveedorNombre,numeroFactura,fotoFacturaPath,total,pagadaDeCaja,estado,usuarioNombre,fecha,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Compra(id: $id, proveedorId: $proveedorId, proveedorNombre: $proveedorNombre, numeroFactura: $numeroFactura, fotoFacturaPath: $fotoFacturaPath, total: $total, pagadaDeCaja: $pagadaDeCaja, estado: $estado, usuarioNombre: $usuarioNombre, fecha: $fecha, items: $items)';
}


}

/// @nodoc
abstract mixin class $CompraCopyWith<$Res>  {
  factory $CompraCopyWith(Compra value, $Res Function(Compra) _then) = _$CompraCopyWithImpl;
@useResult
$Res call({
 String id, String? proveedorId, String? proveedorNombre, String? numeroFactura, String? fotoFacturaPath, Money total, bool pagadaDeCaja, EstadoCompra estado, String usuarioNombre, DateTime fecha, List<CompraItem> items
});




}
/// @nodoc
class _$CompraCopyWithImpl<$Res>
    implements $CompraCopyWith<$Res> {
  _$CompraCopyWithImpl(this._self, this._then);

  final Compra _self;
  final $Res Function(Compra) _then;

/// Create a copy of Compra
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? proveedorId = freezed,Object? proveedorNombre = freezed,Object? numeroFactura = freezed,Object? fotoFacturaPath = freezed,Object? total = null,Object? pagadaDeCaja = null,Object? estado = null,Object? usuarioNombre = null,Object? fecha = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proveedorId: freezed == proveedorId ? _self.proveedorId : proveedorId // ignore: cast_nullable_to_non_nullable
as String?,proveedorNombre: freezed == proveedorNombre ? _self.proveedorNombre : proveedorNombre // ignore: cast_nullable_to_non_nullable
as String?,numeroFactura: freezed == numeroFactura ? _self.numeroFactura : numeroFactura // ignore: cast_nullable_to_non_nullable
as String?,fotoFacturaPath: freezed == fotoFacturaPath ? _self.fotoFacturaPath : fotoFacturaPath // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,pagadaDeCaja: null == pagadaDeCaja ? _self.pagadaDeCaja : pagadaDeCaja // ignore: cast_nullable_to_non_nullable
as bool,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoCompra,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CompraItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Compra].
extension CompraPatterns on Compra {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Compra value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Compra() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Compra value)  $default,){
final _that = this;
switch (_that) {
case _Compra():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Compra value)?  $default,){
final _that = this;
switch (_that) {
case _Compra() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? proveedorId,  String? proveedorNombre,  String? numeroFactura,  String? fotoFacturaPath,  Money total,  bool pagadaDeCaja,  EstadoCompra estado,  String usuarioNombre,  DateTime fecha,  List<CompraItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Compra() when $default != null:
return $default(_that.id,_that.proveedorId,_that.proveedorNombre,_that.numeroFactura,_that.fotoFacturaPath,_that.total,_that.pagadaDeCaja,_that.estado,_that.usuarioNombre,_that.fecha,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? proveedorId,  String? proveedorNombre,  String? numeroFactura,  String? fotoFacturaPath,  Money total,  bool pagadaDeCaja,  EstadoCompra estado,  String usuarioNombre,  DateTime fecha,  List<CompraItem> items)  $default,) {final _that = this;
switch (_that) {
case _Compra():
return $default(_that.id,_that.proveedorId,_that.proveedorNombre,_that.numeroFactura,_that.fotoFacturaPath,_that.total,_that.pagadaDeCaja,_that.estado,_that.usuarioNombre,_that.fecha,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? proveedorId,  String? proveedorNombre,  String? numeroFactura,  String? fotoFacturaPath,  Money total,  bool pagadaDeCaja,  EstadoCompra estado,  String usuarioNombre,  DateTime fecha,  List<CompraItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Compra() when $default != null:
return $default(_that.id,_that.proveedorId,_that.proveedorNombre,_that.numeroFactura,_that.fotoFacturaPath,_that.total,_that.pagadaDeCaja,_that.estado,_that.usuarioNombre,_that.fecha,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _Compra implements Compra {
  const _Compra({required this.id, this.proveedorId, this.proveedorNombre, this.numeroFactura, this.fotoFacturaPath, required this.total, required this.pagadaDeCaja, required this.estado, required this.usuarioNombre, required this.fecha, final  List<CompraItem> items = const []}): _items = items;
  

@override final  String id;
@override final  String? proveedorId;
@override final  String? proveedorNombre;
@override final  String? numeroFactura;
@override final  String? fotoFacturaPath;
@override final  Money total;
@override final  bool pagadaDeCaja;
@override final  EstadoCompra estado;
@override final  String usuarioNombre;
@override final  DateTime fecha;
 final  List<CompraItem> _items;
@override@JsonKey() List<CompraItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Compra
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompraCopyWith<_Compra> get copyWith => __$CompraCopyWithImpl<_Compra>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Compra&&(identical(other.id, id) || other.id == id)&&(identical(other.proveedorId, proveedorId) || other.proveedorId == proveedorId)&&(identical(other.proveedorNombre, proveedorNombre) || other.proveedorNombre == proveedorNombre)&&(identical(other.numeroFactura, numeroFactura) || other.numeroFactura == numeroFactura)&&(identical(other.fotoFacturaPath, fotoFacturaPath) || other.fotoFacturaPath == fotoFacturaPath)&&(identical(other.total, total) || other.total == total)&&(identical(other.pagadaDeCaja, pagadaDeCaja) || other.pagadaDeCaja == pagadaDeCaja)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,id,proveedorId,proveedorNombre,numeroFactura,fotoFacturaPath,total,pagadaDeCaja,estado,usuarioNombre,fecha,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Compra(id: $id, proveedorId: $proveedorId, proveedorNombre: $proveedorNombre, numeroFactura: $numeroFactura, fotoFacturaPath: $fotoFacturaPath, total: $total, pagadaDeCaja: $pagadaDeCaja, estado: $estado, usuarioNombre: $usuarioNombre, fecha: $fecha, items: $items)';
}


}

/// @nodoc
abstract mixin class _$CompraCopyWith<$Res> implements $CompraCopyWith<$Res> {
  factory _$CompraCopyWith(_Compra value, $Res Function(_Compra) _then) = __$CompraCopyWithImpl;
@override @useResult
$Res call({
 String id, String? proveedorId, String? proveedorNombre, String? numeroFactura, String? fotoFacturaPath, Money total, bool pagadaDeCaja, EstadoCompra estado, String usuarioNombre, DateTime fecha, List<CompraItem> items
});




}
/// @nodoc
class __$CompraCopyWithImpl<$Res>
    implements _$CompraCopyWith<$Res> {
  __$CompraCopyWithImpl(this._self, this._then);

  final _Compra _self;
  final $Res Function(_Compra) _then;

/// Create a copy of Compra
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? proveedorId = freezed,Object? proveedorNombre = freezed,Object? numeroFactura = freezed,Object? fotoFacturaPath = freezed,Object? total = null,Object? pagadaDeCaja = null,Object? estado = null,Object? usuarioNombre = null,Object? fecha = null,Object? items = null,}) {
  return _then(_Compra(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,proveedorId: freezed == proveedorId ? _self.proveedorId : proveedorId // ignore: cast_nullable_to_non_nullable
as String?,proveedorNombre: freezed == proveedorNombre ? _self.proveedorNombre : proveedorNombre // ignore: cast_nullable_to_non_nullable
as String?,numeroFactura: freezed == numeroFactura ? _self.numeroFactura : numeroFactura // ignore: cast_nullable_to_non_nullable
as String?,fotoFacturaPath: freezed == fotoFacturaPath ? _self.fotoFacturaPath : fotoFacturaPath // ignore: cast_nullable_to_non_nullable
as String?,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,pagadaDeCaja: null == pagadaDeCaja ? _self.pagadaDeCaja : pagadaDeCaja // ignore: cast_nullable_to_non_nullable
as bool,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoCompra,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CompraItem>,
  ));
}


}

/// @nodoc
mixin _$ItemCompraInput {

 String get productoId; String get productoNombre; double get cantidad; Money get costoUnitario;
/// Create a copy of ItemCompraInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCompraInputCopyWith<ItemCompraInput> get copyWith => _$ItemCompraInputCopyWithImpl<ItemCompraInput>(this as ItemCompraInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemCompraInput&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.productoNombre, productoNombre) || other.productoNombre == productoNombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.costoUnitario, costoUnitario) || other.costoUnitario == costoUnitario));
}


@override
int get hashCode => Object.hash(runtimeType,productoId,productoNombre,cantidad,costoUnitario);

@override
String toString() {
  return 'ItemCompraInput(productoId: $productoId, productoNombre: $productoNombre, cantidad: $cantidad, costoUnitario: $costoUnitario)';
}


}

/// @nodoc
abstract mixin class $ItemCompraInputCopyWith<$Res>  {
  factory $ItemCompraInputCopyWith(ItemCompraInput value, $Res Function(ItemCompraInput) _then) = _$ItemCompraInputCopyWithImpl;
@useResult
$Res call({
 String productoId, String productoNombre, double cantidad, Money costoUnitario
});




}
/// @nodoc
class _$ItemCompraInputCopyWithImpl<$Res>
    implements $ItemCompraInputCopyWith<$Res> {
  _$ItemCompraInputCopyWithImpl(this._self, this._then);

  final ItemCompraInput _self;
  final $Res Function(ItemCompraInput) _then;

/// Create a copy of ItemCompraInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productoId = null,Object? productoNombre = null,Object? cantidad = null,Object? costoUnitario = null,}) {
  return _then(_self.copyWith(
productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,productoNombre: null == productoNombre ? _self.productoNombre : productoNombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,costoUnitario: null == costoUnitario ? _self.costoUnitario : costoUnitario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemCompraInput].
extension ItemCompraInputPatterns on ItemCompraInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemCompraInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemCompraInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemCompraInput value)  $default,){
final _that = this;
switch (_that) {
case _ItemCompraInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemCompraInput value)?  $default,){
final _that = this;
switch (_that) {
case _ItemCompraInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productoId,  String productoNombre,  double cantidad,  Money costoUnitario)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemCompraInput() when $default != null:
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.costoUnitario);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productoId,  String productoNombre,  double cantidad,  Money costoUnitario)  $default,) {final _that = this;
switch (_that) {
case _ItemCompraInput():
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.costoUnitario);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productoId,  String productoNombre,  double cantidad,  Money costoUnitario)?  $default,) {final _that = this;
switch (_that) {
case _ItemCompraInput() when $default != null:
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.costoUnitario);case _:
  return null;

}
}

}

/// @nodoc


class _ItemCompraInput extends ItemCompraInput {
  const _ItemCompraInput({required this.productoId, required this.productoNombre, required this.cantidad, required this.costoUnitario}): super._();
  

@override final  String productoId;
@override final  String productoNombre;
@override final  double cantidad;
@override final  Money costoUnitario;

/// Create a copy of ItemCompraInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCompraInputCopyWith<_ItemCompraInput> get copyWith => __$ItemCompraInputCopyWithImpl<_ItemCompraInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemCompraInput&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.productoNombre, productoNombre) || other.productoNombre == productoNombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.costoUnitario, costoUnitario) || other.costoUnitario == costoUnitario));
}


@override
int get hashCode => Object.hash(runtimeType,productoId,productoNombre,cantidad,costoUnitario);

@override
String toString() {
  return 'ItemCompraInput(productoId: $productoId, productoNombre: $productoNombre, cantidad: $cantidad, costoUnitario: $costoUnitario)';
}


}

/// @nodoc
abstract mixin class _$ItemCompraInputCopyWith<$Res> implements $ItemCompraInputCopyWith<$Res> {
  factory _$ItemCompraInputCopyWith(_ItemCompraInput value, $Res Function(_ItemCompraInput) _then) = __$ItemCompraInputCopyWithImpl;
@override @useResult
$Res call({
 String productoId, String productoNombre, double cantidad, Money costoUnitario
});




}
/// @nodoc
class __$ItemCompraInputCopyWithImpl<$Res>
    implements _$ItemCompraInputCopyWith<$Res> {
  __$ItemCompraInputCopyWithImpl(this._self, this._then);

  final _ItemCompraInput _self;
  final $Res Function(_ItemCompraInput) _then;

/// Create a copy of ItemCompraInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productoId = null,Object? productoNombre = null,Object? cantidad = null,Object? costoUnitario = null,}) {
  return _then(_ItemCompraInput(
productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,productoNombre: null == productoNombre ? _self.productoNombre : productoNombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,costoUnitario: null == costoUnitario ? _self.costoUnitario : costoUnitario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

// dart format on
