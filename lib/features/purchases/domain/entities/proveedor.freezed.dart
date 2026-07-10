// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'proveedor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Proveedor {

 String get id; String get nombre; String? get telefono;
/// Create a copy of Proveedor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProveedorCopyWith<Proveedor> get copyWith => _$ProveedorCopyWithImpl<Proveedor>(this as Proveedor, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Proveedor&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.telefono, telefono) || other.telefono == telefono));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,telefono);

@override
String toString() {
  return 'Proveedor(id: $id, nombre: $nombre, telefono: $telefono)';
}


}

/// @nodoc
abstract mixin class $ProveedorCopyWith<$Res>  {
  factory $ProveedorCopyWith(Proveedor value, $Res Function(Proveedor) _then) = _$ProveedorCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, String? telefono
});




}
/// @nodoc
class _$ProveedorCopyWithImpl<$Res>
    implements $ProveedorCopyWith<$Res> {
  _$ProveedorCopyWithImpl(this._self, this._then);

  final Proveedor _self;
  final $Res Function(Proveedor) _then;

/// Create a copy of Proveedor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? telefono = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Proveedor].
extension ProveedorPatterns on Proveedor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Proveedor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Proveedor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Proveedor value)  $default,){
final _that = this;
switch (_that) {
case _Proveedor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Proveedor value)?  $default,){
final _that = this;
switch (_that) {
case _Proveedor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  String? telefono)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Proveedor() when $default != null:
return $default(_that.id,_that.nombre,_that.telefono);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  String? telefono)  $default,) {final _that = this;
switch (_that) {
case _Proveedor():
return $default(_that.id,_that.nombre,_that.telefono);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  String? telefono)?  $default,) {final _that = this;
switch (_that) {
case _Proveedor() when $default != null:
return $default(_that.id,_that.nombre,_that.telefono);case _:
  return null;

}
}

}

/// @nodoc


class _Proveedor implements Proveedor {
  const _Proveedor({required this.id, required this.nombre, this.telefono});
  

@override final  String id;
@override final  String nombre;
@override final  String? telefono;

/// Create a copy of Proveedor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProveedorCopyWith<_Proveedor> get copyWith => __$ProveedorCopyWithImpl<_Proveedor>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Proveedor&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.telefono, telefono) || other.telefono == telefono));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,telefono);

@override
String toString() {
  return 'Proveedor(id: $id, nombre: $nombre, telefono: $telefono)';
}


}

/// @nodoc
abstract mixin class _$ProveedorCopyWith<$Res> implements $ProveedorCopyWith<$Res> {
  factory _$ProveedorCopyWith(_Proveedor value, $Res Function(_Proveedor) _then) = __$ProveedorCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, String? telefono
});




}
/// @nodoc
class __$ProveedorCopyWithImpl<$Res>
    implements _$ProveedorCopyWith<$Res> {
  __$ProveedorCopyWithImpl(this._self, this._then);

  final _Proveedor _self;
  final $Res Function(_Proveedor) _then;

/// Create a copy of Proveedor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? telefono = freezed,}) {
  return _then(_Proveedor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
