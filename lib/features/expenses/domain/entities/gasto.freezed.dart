// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gasto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Gasto {

 String get id; String get categoria; String get concepto; DateTime get fecha; Money get monto; bool get saleDeCaja; String get usuarioNombre;
/// Create a copy of Gasto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GastoCopyWith<Gasto> get copyWith => _$GastoCopyWithImpl<Gasto>(this as Gasto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Gasto&&(identical(other.id, id) || other.id == id)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.concepto, concepto) || other.concepto == concepto)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.saleDeCaja, saleDeCaja) || other.saleDeCaja == saleDeCaja)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,categoria,concepto,fecha,monto,saleDeCaja,usuarioNombre);

@override
String toString() {
  return 'Gasto(id: $id, categoria: $categoria, concepto: $concepto, fecha: $fecha, monto: $monto, saleDeCaja: $saleDeCaja, usuarioNombre: $usuarioNombre)';
}


}

/// @nodoc
abstract mixin class $GastoCopyWith<$Res>  {
  factory $GastoCopyWith(Gasto value, $Res Function(Gasto) _then) = _$GastoCopyWithImpl;
@useResult
$Res call({
 String id, String categoria, String concepto, DateTime fecha, Money monto, bool saleDeCaja, String usuarioNombre
});




}
/// @nodoc
class _$GastoCopyWithImpl<$Res>
    implements $GastoCopyWith<$Res> {
  _$GastoCopyWithImpl(this._self, this._then);

  final Gasto _self;
  final $Res Function(Gasto) _then;

/// Create a copy of Gasto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoria = null,Object? concepto = null,Object? fecha = null,Object? monto = null,Object? saleDeCaja = null,Object? usuarioNombre = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,concepto: null == concepto ? _self.concepto : concepto // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,saleDeCaja: null == saleDeCaja ? _self.saleDeCaja : saleDeCaja // ignore: cast_nullable_to_non_nullable
as bool,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Gasto].
extension GastoPatterns on Gasto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Gasto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Gasto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Gasto value)  $default,){
final _that = this;
switch (_that) {
case _Gasto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Gasto value)?  $default,){
final _that = this;
switch (_that) {
case _Gasto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoria,  String concepto,  DateTime fecha,  Money monto,  bool saleDeCaja,  String usuarioNombre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Gasto() when $default != null:
return $default(_that.id,_that.categoria,_that.concepto,_that.fecha,_that.monto,_that.saleDeCaja,_that.usuarioNombre);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoria,  String concepto,  DateTime fecha,  Money monto,  bool saleDeCaja,  String usuarioNombre)  $default,) {final _that = this;
switch (_that) {
case _Gasto():
return $default(_that.id,_that.categoria,_that.concepto,_that.fecha,_that.monto,_that.saleDeCaja,_that.usuarioNombre);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoria,  String concepto,  DateTime fecha,  Money monto,  bool saleDeCaja,  String usuarioNombre)?  $default,) {final _that = this;
switch (_that) {
case _Gasto() when $default != null:
return $default(_that.id,_that.categoria,_that.concepto,_that.fecha,_that.monto,_that.saleDeCaja,_that.usuarioNombre);case _:
  return null;

}
}

}

/// @nodoc


class _Gasto implements Gasto {
  const _Gasto({required this.id, required this.categoria, required this.concepto, required this.fecha, required this.monto, required this.saleDeCaja, required this.usuarioNombre});
  

@override final  String id;
@override final  String categoria;
@override final  String concepto;
@override final  DateTime fecha;
@override final  Money monto;
@override final  bool saleDeCaja;
@override final  String usuarioNombre;

/// Create a copy of Gasto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GastoCopyWith<_Gasto> get copyWith => __$GastoCopyWithImpl<_Gasto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Gasto&&(identical(other.id, id) || other.id == id)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.concepto, concepto) || other.concepto == concepto)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.saleDeCaja, saleDeCaja) || other.saleDeCaja == saleDeCaja)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,categoria,concepto,fecha,monto,saleDeCaja,usuarioNombre);

@override
String toString() {
  return 'Gasto(id: $id, categoria: $categoria, concepto: $concepto, fecha: $fecha, monto: $monto, saleDeCaja: $saleDeCaja, usuarioNombre: $usuarioNombre)';
}


}

/// @nodoc
abstract mixin class _$GastoCopyWith<$Res> implements $GastoCopyWith<$Res> {
  factory _$GastoCopyWith(_Gasto value, $Res Function(_Gasto) _then) = __$GastoCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoria, String concepto, DateTime fecha, Money monto, bool saleDeCaja, String usuarioNombre
});




}
/// @nodoc
class __$GastoCopyWithImpl<$Res>
    implements _$GastoCopyWith<$Res> {
  __$GastoCopyWithImpl(this._self, this._then);

  final _Gasto _self;
  final $Res Function(_Gasto) _then;

/// Create a copy of Gasto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoria = null,Object? concepto = null,Object? fecha = null,Object? monto = null,Object? saleDeCaja = null,Object? usuarioNombre = null,}) {
  return _then(_Gasto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,concepto: null == concepto ? _self.concepto : concepto // ignore: cast_nullable_to_non_nullable
as String,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,saleDeCaja: null == saleDeCaja ? _self.saleDeCaja : saleDeCaja // ignore: cast_nullable_to_non_nullable
as bool,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
