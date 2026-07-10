// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VentaItem {

 String get productoId; String get productoNombre; double get cantidad; Money get precioUnitario; Money get costoUnitario;
/// Create a copy of VentaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VentaItemCopyWith<VentaItem> get copyWith => _$VentaItemCopyWithImpl<VentaItem>(this as VentaItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VentaItem&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.productoNombre, productoNombre) || other.productoNombre == productoNombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.precioUnitario, precioUnitario) || other.precioUnitario == precioUnitario)&&(identical(other.costoUnitario, costoUnitario) || other.costoUnitario == costoUnitario));
}


@override
int get hashCode => Object.hash(runtimeType,productoId,productoNombre,cantidad,precioUnitario,costoUnitario);

@override
String toString() {
  return 'VentaItem(productoId: $productoId, productoNombre: $productoNombre, cantidad: $cantidad, precioUnitario: $precioUnitario, costoUnitario: $costoUnitario)';
}


}

/// @nodoc
abstract mixin class $VentaItemCopyWith<$Res>  {
  factory $VentaItemCopyWith(VentaItem value, $Res Function(VentaItem) _then) = _$VentaItemCopyWithImpl;
@useResult
$Res call({
 String productoId, String productoNombre, double cantidad, Money precioUnitario, Money costoUnitario
});




}
/// @nodoc
class _$VentaItemCopyWithImpl<$Res>
    implements $VentaItemCopyWith<$Res> {
  _$VentaItemCopyWithImpl(this._self, this._then);

  final VentaItem _self;
  final $Res Function(VentaItem) _then;

/// Create a copy of VentaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productoId = null,Object? productoNombre = null,Object? cantidad = null,Object? precioUnitario = null,Object? costoUnitario = null,}) {
  return _then(_self.copyWith(
productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,productoNombre: null == productoNombre ? _self.productoNombre : productoNombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,precioUnitario: null == precioUnitario ? _self.precioUnitario : precioUnitario // ignore: cast_nullable_to_non_nullable
as Money,costoUnitario: null == costoUnitario ? _self.costoUnitario : costoUnitario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [VentaItem].
extension VentaItemPatterns on VentaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VentaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VentaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VentaItem value)  $default,){
final _that = this;
switch (_that) {
case _VentaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VentaItem value)?  $default,){
final _that = this;
switch (_that) {
case _VentaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productoId,  String productoNombre,  double cantidad,  Money precioUnitario,  Money costoUnitario)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VentaItem() when $default != null:
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.precioUnitario,_that.costoUnitario);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productoId,  String productoNombre,  double cantidad,  Money precioUnitario,  Money costoUnitario)  $default,) {final _that = this;
switch (_that) {
case _VentaItem():
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.precioUnitario,_that.costoUnitario);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productoId,  String productoNombre,  double cantidad,  Money precioUnitario,  Money costoUnitario)?  $default,) {final _that = this;
switch (_that) {
case _VentaItem() when $default != null:
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.precioUnitario,_that.costoUnitario);case _:
  return null;

}
}

}

/// @nodoc


class _VentaItem extends VentaItem {
  const _VentaItem({required this.productoId, required this.productoNombre, required this.cantidad, required this.precioUnitario, required this.costoUnitario}): super._();
  

@override final  String productoId;
@override final  String productoNombre;
@override final  double cantidad;
@override final  Money precioUnitario;
@override final  Money costoUnitario;

/// Create a copy of VentaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VentaItemCopyWith<_VentaItem> get copyWith => __$VentaItemCopyWithImpl<_VentaItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VentaItem&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.productoNombre, productoNombre) || other.productoNombre == productoNombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.precioUnitario, precioUnitario) || other.precioUnitario == precioUnitario)&&(identical(other.costoUnitario, costoUnitario) || other.costoUnitario == costoUnitario));
}


@override
int get hashCode => Object.hash(runtimeType,productoId,productoNombre,cantidad,precioUnitario,costoUnitario);

@override
String toString() {
  return 'VentaItem(productoId: $productoId, productoNombre: $productoNombre, cantidad: $cantidad, precioUnitario: $precioUnitario, costoUnitario: $costoUnitario)';
}


}

/// @nodoc
abstract mixin class _$VentaItemCopyWith<$Res> implements $VentaItemCopyWith<$Res> {
  factory _$VentaItemCopyWith(_VentaItem value, $Res Function(_VentaItem) _then) = __$VentaItemCopyWithImpl;
@override @useResult
$Res call({
 String productoId, String productoNombre, double cantidad, Money precioUnitario, Money costoUnitario
});




}
/// @nodoc
class __$VentaItemCopyWithImpl<$Res>
    implements _$VentaItemCopyWith<$Res> {
  __$VentaItemCopyWithImpl(this._self, this._then);

  final _VentaItem _self;
  final $Res Function(_VentaItem) _then;

/// Create a copy of VentaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productoId = null,Object? productoNombre = null,Object? cantidad = null,Object? precioUnitario = null,Object? costoUnitario = null,}) {
  return _then(_VentaItem(
productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,productoNombre: null == productoNombre ? _self.productoNombre : productoNombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,precioUnitario: null == precioUnitario ? _self.precioUnitario : precioUnitario // ignore: cast_nullable_to_non_nullable
as Money,costoUnitario: null == costoUnitario ? _self.costoUnitario : costoUnitario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$Venta {

 String get id; TipoVenta get tipo; Money get total; Money get ganancia; EstadoVenta get estado; String? get nota; String get usuarioNombre; DateTime get fecha; List<VentaItem> get items;
/// Create a copy of Venta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VentaCopyWith<Venta> get copyWith => _$VentaCopyWithImpl<Venta>(this as Venta, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Venta&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.total, total) || other.total == total)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,total,ganancia,estado,nota,usuarioNombre,fecha,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'Venta(id: $id, tipo: $tipo, total: $total, ganancia: $ganancia, estado: $estado, nota: $nota, usuarioNombre: $usuarioNombre, fecha: $fecha, items: $items)';
}


}

/// @nodoc
abstract mixin class $VentaCopyWith<$Res>  {
  factory $VentaCopyWith(Venta value, $Res Function(Venta) _then) = _$VentaCopyWithImpl;
@useResult
$Res call({
 String id, TipoVenta tipo, Money total, Money ganancia, EstadoVenta estado, String? nota, String usuarioNombre, DateTime fecha, List<VentaItem> items
});




}
/// @nodoc
class _$VentaCopyWithImpl<$Res>
    implements $VentaCopyWith<$Res> {
  _$VentaCopyWithImpl(this._self, this._then);

  final Venta _self;
  final $Res Function(Venta) _then;

/// Create a copy of Venta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tipo = null,Object? total = null,Object? ganancia = null,Object? estado = null,Object? nota = freezed,Object? usuarioNombre = null,Object? fecha = null,Object? items = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoVenta,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as Money,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoVenta,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<VentaItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Venta].
extension VentaPatterns on Venta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Venta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Venta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Venta value)  $default,){
final _that = this;
switch (_that) {
case _Venta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Venta value)?  $default,){
final _that = this;
switch (_that) {
case _Venta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TipoVenta tipo,  Money total,  Money ganancia,  EstadoVenta estado,  String? nota,  String usuarioNombre,  DateTime fecha,  List<VentaItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Venta() when $default != null:
return $default(_that.id,_that.tipo,_that.total,_that.ganancia,_that.estado,_that.nota,_that.usuarioNombre,_that.fecha,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TipoVenta tipo,  Money total,  Money ganancia,  EstadoVenta estado,  String? nota,  String usuarioNombre,  DateTime fecha,  List<VentaItem> items)  $default,) {final _that = this;
switch (_that) {
case _Venta():
return $default(_that.id,_that.tipo,_that.total,_that.ganancia,_that.estado,_that.nota,_that.usuarioNombre,_that.fecha,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TipoVenta tipo,  Money total,  Money ganancia,  EstadoVenta estado,  String? nota,  String usuarioNombre,  DateTime fecha,  List<VentaItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Venta() when $default != null:
return $default(_that.id,_that.tipo,_that.total,_that.ganancia,_that.estado,_that.nota,_that.usuarioNombre,_that.fecha,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _Venta implements Venta {
  const _Venta({required this.id, required this.tipo, required this.total, required this.ganancia, required this.estado, this.nota, required this.usuarioNombre, required this.fecha, final  List<VentaItem> items = const []}): _items = items;
  

@override final  String id;
@override final  TipoVenta tipo;
@override final  Money total;
@override final  Money ganancia;
@override final  EstadoVenta estado;
@override final  String? nota;
@override final  String usuarioNombre;
@override final  DateTime fecha;
 final  List<VentaItem> _items;
@override@JsonKey() List<VentaItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Venta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VentaCopyWith<_Venta> get copyWith => __$VentaCopyWithImpl<_Venta>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Venta&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.total, total) || other.total == total)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,total,ganancia,estado,nota,usuarioNombre,fecha,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'Venta(id: $id, tipo: $tipo, total: $total, ganancia: $ganancia, estado: $estado, nota: $nota, usuarioNombre: $usuarioNombre, fecha: $fecha, items: $items)';
}


}

/// @nodoc
abstract mixin class _$VentaCopyWith<$Res> implements $VentaCopyWith<$Res> {
  factory _$VentaCopyWith(_Venta value, $Res Function(_Venta) _then) = __$VentaCopyWithImpl;
@override @useResult
$Res call({
 String id, TipoVenta tipo, Money total, Money ganancia, EstadoVenta estado, String? nota, String usuarioNombre, DateTime fecha, List<VentaItem> items
});




}
/// @nodoc
class __$VentaCopyWithImpl<$Res>
    implements _$VentaCopyWith<$Res> {
  __$VentaCopyWithImpl(this._self, this._then);

  final _Venta _self;
  final $Res Function(_Venta) _then;

/// Create a copy of Venta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tipo = null,Object? total = null,Object? ganancia = null,Object? estado = null,Object? nota = freezed,Object? usuarioNombre = null,Object? fecha = null,Object? items = null,}) {
  return _then(_Venta(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoVenta,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as Money,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoVenta,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<VentaItem>,
  ));
}


}

/// @nodoc
mixin _$ItemVentaInput {

 String get productoId; String get productoNombre; double get cantidad; Money get precioUnitario;
/// Create a copy of ItemVentaInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemVentaInputCopyWith<ItemVentaInput> get copyWith => _$ItemVentaInputCopyWithImpl<ItemVentaInput>(this as ItemVentaInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemVentaInput&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.productoNombre, productoNombre) || other.productoNombre == productoNombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.precioUnitario, precioUnitario) || other.precioUnitario == precioUnitario));
}


@override
int get hashCode => Object.hash(runtimeType,productoId,productoNombre,cantidad,precioUnitario);

@override
String toString() {
  return 'ItemVentaInput(productoId: $productoId, productoNombre: $productoNombre, cantidad: $cantidad, precioUnitario: $precioUnitario)';
}


}

/// @nodoc
abstract mixin class $ItemVentaInputCopyWith<$Res>  {
  factory $ItemVentaInputCopyWith(ItemVentaInput value, $Res Function(ItemVentaInput) _then) = _$ItemVentaInputCopyWithImpl;
@useResult
$Res call({
 String productoId, String productoNombre, double cantidad, Money precioUnitario
});




}
/// @nodoc
class _$ItemVentaInputCopyWithImpl<$Res>
    implements $ItemVentaInputCopyWith<$Res> {
  _$ItemVentaInputCopyWithImpl(this._self, this._then);

  final ItemVentaInput _self;
  final $Res Function(ItemVentaInput) _then;

/// Create a copy of ItemVentaInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productoId = null,Object? productoNombre = null,Object? cantidad = null,Object? precioUnitario = null,}) {
  return _then(_self.copyWith(
productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,productoNombre: null == productoNombre ? _self.productoNombre : productoNombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,precioUnitario: null == precioUnitario ? _self.precioUnitario : precioUnitario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemVentaInput].
extension ItemVentaInputPatterns on ItemVentaInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemVentaInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemVentaInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemVentaInput value)  $default,){
final _that = this;
switch (_that) {
case _ItemVentaInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemVentaInput value)?  $default,){
final _that = this;
switch (_that) {
case _ItemVentaInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productoId,  String productoNombre,  double cantidad,  Money precioUnitario)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemVentaInput() when $default != null:
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.precioUnitario);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productoId,  String productoNombre,  double cantidad,  Money precioUnitario)  $default,) {final _that = this;
switch (_that) {
case _ItemVentaInput():
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.precioUnitario);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productoId,  String productoNombre,  double cantidad,  Money precioUnitario)?  $default,) {final _that = this;
switch (_that) {
case _ItemVentaInput() when $default != null:
return $default(_that.productoId,_that.productoNombre,_that.cantidad,_that.precioUnitario);case _:
  return null;

}
}

}

/// @nodoc


class _ItemVentaInput extends ItemVentaInput {
  const _ItemVentaInput({required this.productoId, required this.productoNombre, required this.cantidad, required this.precioUnitario}): super._();
  

@override final  String productoId;
@override final  String productoNombre;
@override final  double cantidad;
@override final  Money precioUnitario;

/// Create a copy of ItemVentaInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemVentaInputCopyWith<_ItemVentaInput> get copyWith => __$ItemVentaInputCopyWithImpl<_ItemVentaInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemVentaInput&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.productoNombre, productoNombre) || other.productoNombre == productoNombre)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.precioUnitario, precioUnitario) || other.precioUnitario == precioUnitario));
}


@override
int get hashCode => Object.hash(runtimeType,productoId,productoNombre,cantidad,precioUnitario);

@override
String toString() {
  return 'ItemVentaInput(productoId: $productoId, productoNombre: $productoNombre, cantidad: $cantidad, precioUnitario: $precioUnitario)';
}


}

/// @nodoc
abstract mixin class _$ItemVentaInputCopyWith<$Res> implements $ItemVentaInputCopyWith<$Res> {
  factory _$ItemVentaInputCopyWith(_ItemVentaInput value, $Res Function(_ItemVentaInput) _then) = __$ItemVentaInputCopyWithImpl;
@override @useResult
$Res call({
 String productoId, String productoNombre, double cantidad, Money precioUnitario
});




}
/// @nodoc
class __$ItemVentaInputCopyWithImpl<$Res>
    implements _$ItemVentaInputCopyWith<$Res> {
  __$ItemVentaInputCopyWithImpl(this._self, this._then);

  final _ItemVentaInput _self;
  final $Res Function(_ItemVentaInput) _then;

/// Create a copy of ItemVentaInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productoId = null,Object? productoNombre = null,Object? cantidad = null,Object? precioUnitario = null,}) {
  return _then(_ItemVentaInput(
productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,productoNombre: null == productoNombre ? _self.productoNombre : productoNombre // ignore: cast_nullable_to_non_nullable
as String,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as double,precioUnitario: null == precioUnitario ? _self.precioUnitario : precioUnitario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

// dart format on
