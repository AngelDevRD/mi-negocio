// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResumenFinanciero {

 Money get ventas; Money get compras; Money get gastos; Money get sueldos; Money get ganancia; Money get dineroMovido; Money get valorInventario;
/// Create a copy of ResumenFinanciero
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResumenFinancieroCopyWith<ResumenFinanciero> get copyWith => _$ResumenFinancieroCopyWithImpl<ResumenFinanciero>(this as ResumenFinanciero, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResumenFinanciero&&(identical(other.ventas, ventas) || other.ventas == ventas)&&(identical(other.compras, compras) || other.compras == compras)&&(identical(other.gastos, gastos) || other.gastos == gastos)&&(identical(other.sueldos, sueldos) || other.sueldos == sueldos)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia)&&(identical(other.dineroMovido, dineroMovido) || other.dineroMovido == dineroMovido)&&(identical(other.valorInventario, valorInventario) || other.valorInventario == valorInventario));
}


@override
int get hashCode => Object.hash(runtimeType,ventas,compras,gastos,sueldos,ganancia,dineroMovido,valorInventario);

@override
String toString() {
  return 'ResumenFinanciero(ventas: $ventas, compras: $compras, gastos: $gastos, sueldos: $sueldos, ganancia: $ganancia, dineroMovido: $dineroMovido, valorInventario: $valorInventario)';
}


}

/// @nodoc
abstract mixin class $ResumenFinancieroCopyWith<$Res>  {
  factory $ResumenFinancieroCopyWith(ResumenFinanciero value, $Res Function(ResumenFinanciero) _then) = _$ResumenFinancieroCopyWithImpl;
@useResult
$Res call({
 Money ventas, Money compras, Money gastos, Money sueldos, Money ganancia, Money dineroMovido, Money valorInventario
});




}
/// @nodoc
class _$ResumenFinancieroCopyWithImpl<$Res>
    implements $ResumenFinancieroCopyWith<$Res> {
  _$ResumenFinancieroCopyWithImpl(this._self, this._then);

  final ResumenFinanciero _self;
  final $Res Function(ResumenFinanciero) _then;

/// Create a copy of ResumenFinanciero
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ventas = null,Object? compras = null,Object? gastos = null,Object? sueldos = null,Object? ganancia = null,Object? dineroMovido = null,Object? valorInventario = null,}) {
  return _then(_self.copyWith(
ventas: null == ventas ? _self.ventas : ventas // ignore: cast_nullable_to_non_nullable
as Money,compras: null == compras ? _self.compras : compras // ignore: cast_nullable_to_non_nullable
as Money,gastos: null == gastos ? _self.gastos : gastos // ignore: cast_nullable_to_non_nullable
as Money,sueldos: null == sueldos ? _self.sueldos : sueldos // ignore: cast_nullable_to_non_nullable
as Money,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as Money,dineroMovido: null == dineroMovido ? _self.dineroMovido : dineroMovido // ignore: cast_nullable_to_non_nullable
as Money,valorInventario: null == valorInventario ? _self.valorInventario : valorInventario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [ResumenFinanciero].
extension ResumenFinancieroPatterns on ResumenFinanciero {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResumenFinanciero value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResumenFinanciero() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResumenFinanciero value)  $default,){
final _that = this;
switch (_that) {
case _ResumenFinanciero():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResumenFinanciero value)?  $default,){
final _that = this;
switch (_that) {
case _ResumenFinanciero() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Money ventas,  Money compras,  Money gastos,  Money sueldos,  Money ganancia,  Money dineroMovido,  Money valorInventario)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResumenFinanciero() when $default != null:
return $default(_that.ventas,_that.compras,_that.gastos,_that.sueldos,_that.ganancia,_that.dineroMovido,_that.valorInventario);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Money ventas,  Money compras,  Money gastos,  Money sueldos,  Money ganancia,  Money dineroMovido,  Money valorInventario)  $default,) {final _that = this;
switch (_that) {
case _ResumenFinanciero():
return $default(_that.ventas,_that.compras,_that.gastos,_that.sueldos,_that.ganancia,_that.dineroMovido,_that.valorInventario);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Money ventas,  Money compras,  Money gastos,  Money sueldos,  Money ganancia,  Money dineroMovido,  Money valorInventario)?  $default,) {final _that = this;
switch (_that) {
case _ResumenFinanciero() when $default != null:
return $default(_that.ventas,_that.compras,_that.gastos,_that.sueldos,_that.ganancia,_that.dineroMovido,_that.valorInventario);case _:
  return null;

}
}

}

/// @nodoc


class _ResumenFinanciero implements ResumenFinanciero {
  const _ResumenFinanciero({required this.ventas, required this.compras, required this.gastos, required this.sueldos, required this.ganancia, required this.dineroMovido, required this.valorInventario});
  

@override final  Money ventas;
@override final  Money compras;
@override final  Money gastos;
@override final  Money sueldos;
@override final  Money ganancia;
@override final  Money dineroMovido;
@override final  Money valorInventario;

/// Create a copy of ResumenFinanciero
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResumenFinancieroCopyWith<_ResumenFinanciero> get copyWith => __$ResumenFinancieroCopyWithImpl<_ResumenFinanciero>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResumenFinanciero&&(identical(other.ventas, ventas) || other.ventas == ventas)&&(identical(other.compras, compras) || other.compras == compras)&&(identical(other.gastos, gastos) || other.gastos == gastos)&&(identical(other.sueldos, sueldos) || other.sueldos == sueldos)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia)&&(identical(other.dineroMovido, dineroMovido) || other.dineroMovido == dineroMovido)&&(identical(other.valorInventario, valorInventario) || other.valorInventario == valorInventario));
}


@override
int get hashCode => Object.hash(runtimeType,ventas,compras,gastos,sueldos,ganancia,dineroMovido,valorInventario);

@override
String toString() {
  return 'ResumenFinanciero(ventas: $ventas, compras: $compras, gastos: $gastos, sueldos: $sueldos, ganancia: $ganancia, dineroMovido: $dineroMovido, valorInventario: $valorInventario)';
}


}

/// @nodoc
abstract mixin class _$ResumenFinancieroCopyWith<$Res> implements $ResumenFinancieroCopyWith<$Res> {
  factory _$ResumenFinancieroCopyWith(_ResumenFinanciero value, $Res Function(_ResumenFinanciero) _then) = __$ResumenFinancieroCopyWithImpl;
@override @useResult
$Res call({
 Money ventas, Money compras, Money gastos, Money sueldos, Money ganancia, Money dineroMovido, Money valorInventario
});




}
/// @nodoc
class __$ResumenFinancieroCopyWithImpl<$Res>
    implements _$ResumenFinancieroCopyWith<$Res> {
  __$ResumenFinancieroCopyWithImpl(this._self, this._then);

  final _ResumenFinanciero _self;
  final $Res Function(_ResumenFinanciero) _then;

/// Create a copy of ResumenFinanciero
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ventas = null,Object? compras = null,Object? gastos = null,Object? sueldos = null,Object? ganancia = null,Object? dineroMovido = null,Object? valorInventario = null,}) {
  return _then(_ResumenFinanciero(
ventas: null == ventas ? _self.ventas : ventas // ignore: cast_nullable_to_non_nullable
as Money,compras: null == compras ? _self.compras : compras // ignore: cast_nullable_to_non_nullable
as Money,gastos: null == gastos ? _self.gastos : gastos // ignore: cast_nullable_to_non_nullable
as Money,sueldos: null == sueldos ? _self.sueldos : sueldos // ignore: cast_nullable_to_non_nullable
as Money,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as Money,dineroMovido: null == dineroMovido ? _self.dineroMovido : dineroMovido // ignore: cast_nullable_to_non_nullable
as Money,valorInventario: null == valorInventario ? _self.valorInventario : valorInventario // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$PuntoMensual {

 DateTime get mes; Money get ventas; Money get compras; Money get gastos; Money get sueldos; Money get ganancia;
/// Create a copy of PuntoMensual
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PuntoMensualCopyWith<PuntoMensual> get copyWith => _$PuntoMensualCopyWithImpl<PuntoMensual>(this as PuntoMensual, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PuntoMensual&&(identical(other.mes, mes) || other.mes == mes)&&(identical(other.ventas, ventas) || other.ventas == ventas)&&(identical(other.compras, compras) || other.compras == compras)&&(identical(other.gastos, gastos) || other.gastos == gastos)&&(identical(other.sueldos, sueldos) || other.sueldos == sueldos)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia));
}


@override
int get hashCode => Object.hash(runtimeType,mes,ventas,compras,gastos,sueldos,ganancia);

@override
String toString() {
  return 'PuntoMensual(mes: $mes, ventas: $ventas, compras: $compras, gastos: $gastos, sueldos: $sueldos, ganancia: $ganancia)';
}


}

/// @nodoc
abstract mixin class $PuntoMensualCopyWith<$Res>  {
  factory $PuntoMensualCopyWith(PuntoMensual value, $Res Function(PuntoMensual) _then) = _$PuntoMensualCopyWithImpl;
@useResult
$Res call({
 DateTime mes, Money ventas, Money compras, Money gastos, Money sueldos, Money ganancia
});




}
/// @nodoc
class _$PuntoMensualCopyWithImpl<$Res>
    implements $PuntoMensualCopyWith<$Res> {
  _$PuntoMensualCopyWithImpl(this._self, this._then);

  final PuntoMensual _self;
  final $Res Function(PuntoMensual) _then;

/// Create a copy of PuntoMensual
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mes = null,Object? ventas = null,Object? compras = null,Object? gastos = null,Object? sueldos = null,Object? ganancia = null,}) {
  return _then(_self.copyWith(
mes: null == mes ? _self.mes : mes // ignore: cast_nullable_to_non_nullable
as DateTime,ventas: null == ventas ? _self.ventas : ventas // ignore: cast_nullable_to_non_nullable
as Money,compras: null == compras ? _self.compras : compras // ignore: cast_nullable_to_non_nullable
as Money,gastos: null == gastos ? _self.gastos : gastos // ignore: cast_nullable_to_non_nullable
as Money,sueldos: null == sueldos ? _self.sueldos : sueldos // ignore: cast_nullable_to_non_nullable
as Money,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [PuntoMensual].
extension PuntoMensualPatterns on PuntoMensual {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PuntoMensual value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PuntoMensual() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PuntoMensual value)  $default,){
final _that = this;
switch (_that) {
case _PuntoMensual():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PuntoMensual value)?  $default,){
final _that = this;
switch (_that) {
case _PuntoMensual() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime mes,  Money ventas,  Money compras,  Money gastos,  Money sueldos,  Money ganancia)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PuntoMensual() when $default != null:
return $default(_that.mes,_that.ventas,_that.compras,_that.gastos,_that.sueldos,_that.ganancia);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime mes,  Money ventas,  Money compras,  Money gastos,  Money sueldos,  Money ganancia)  $default,) {final _that = this;
switch (_that) {
case _PuntoMensual():
return $default(_that.mes,_that.ventas,_that.compras,_that.gastos,_that.sueldos,_that.ganancia);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime mes,  Money ventas,  Money compras,  Money gastos,  Money sueldos,  Money ganancia)?  $default,) {final _that = this;
switch (_that) {
case _PuntoMensual() when $default != null:
return $default(_that.mes,_that.ventas,_that.compras,_that.gastos,_that.sueldos,_that.ganancia);case _:
  return null;

}
}

}

/// @nodoc


class _PuntoMensual implements PuntoMensual {
  const _PuntoMensual({required this.mes, required this.ventas, required this.compras, required this.gastos, required this.sueldos, required this.ganancia});
  

@override final  DateTime mes;
@override final  Money ventas;
@override final  Money compras;
@override final  Money gastos;
@override final  Money sueldos;
@override final  Money ganancia;

/// Create a copy of PuntoMensual
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PuntoMensualCopyWith<_PuntoMensual> get copyWith => __$PuntoMensualCopyWithImpl<_PuntoMensual>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PuntoMensual&&(identical(other.mes, mes) || other.mes == mes)&&(identical(other.ventas, ventas) || other.ventas == ventas)&&(identical(other.compras, compras) || other.compras == compras)&&(identical(other.gastos, gastos) || other.gastos == gastos)&&(identical(other.sueldos, sueldos) || other.sueldos == sueldos)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia));
}


@override
int get hashCode => Object.hash(runtimeType,mes,ventas,compras,gastos,sueldos,ganancia);

@override
String toString() {
  return 'PuntoMensual(mes: $mes, ventas: $ventas, compras: $compras, gastos: $gastos, sueldos: $sueldos, ganancia: $ganancia)';
}


}

/// @nodoc
abstract mixin class _$PuntoMensualCopyWith<$Res> implements $PuntoMensualCopyWith<$Res> {
  factory _$PuntoMensualCopyWith(_PuntoMensual value, $Res Function(_PuntoMensual) _then) = __$PuntoMensualCopyWithImpl;
@override @useResult
$Res call({
 DateTime mes, Money ventas, Money compras, Money gastos, Money sueldos, Money ganancia
});




}
/// @nodoc
class __$PuntoMensualCopyWithImpl<$Res>
    implements _$PuntoMensualCopyWith<$Res> {
  __$PuntoMensualCopyWithImpl(this._self, this._then);

  final _PuntoMensual _self;
  final $Res Function(_PuntoMensual) _then;

/// Create a copy of PuntoMensual
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mes = null,Object? ventas = null,Object? compras = null,Object? gastos = null,Object? sueldos = null,Object? ganancia = null,}) {
  return _then(_PuntoMensual(
mes: null == mes ? _self.mes : mes // ignore: cast_nullable_to_non_nullable
as DateTime,ventas: null == ventas ? _self.ventas : ventas // ignore: cast_nullable_to_non_nullable
as Money,compras: null == compras ? _self.compras : compras // ignore: cast_nullable_to_non_nullable
as Money,gastos: null == gastos ? _self.gastos : gastos // ignore: cast_nullable_to_non_nullable
as Money,sueldos: null == sueldos ? _self.sueldos : sueldos // ignore: cast_nullable_to_non_nullable
as Money,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$GastoPorCategoria {

 String get categoria; Money get total;
/// Create a copy of GastoPorCategoria
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GastoPorCategoriaCopyWith<GastoPorCategoria> get copyWith => _$GastoPorCategoriaCopyWithImpl<GastoPorCategoria>(this as GastoPorCategoria, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GastoPorCategoria&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,categoria,total);

@override
String toString() {
  return 'GastoPorCategoria(categoria: $categoria, total: $total)';
}


}

/// @nodoc
abstract mixin class $GastoPorCategoriaCopyWith<$Res>  {
  factory $GastoPorCategoriaCopyWith(GastoPorCategoria value, $Res Function(GastoPorCategoria) _then) = _$GastoPorCategoriaCopyWithImpl;
@useResult
$Res call({
 String categoria, Money total
});




}
/// @nodoc
class _$GastoPorCategoriaCopyWithImpl<$Res>
    implements $GastoPorCategoriaCopyWith<$Res> {
  _$GastoPorCategoriaCopyWithImpl(this._self, this._then);

  final GastoPorCategoria _self;
  final $Res Function(GastoPorCategoria) _then;

/// Create a copy of GastoPorCategoria
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoria = null,Object? total = null,}) {
  return _then(_self.copyWith(
categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [GastoPorCategoria].
extension GastoPorCategoriaPatterns on GastoPorCategoria {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GastoPorCategoria value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GastoPorCategoria() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GastoPorCategoria value)  $default,){
final _that = this;
switch (_that) {
case _GastoPorCategoria():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GastoPorCategoria value)?  $default,){
final _that = this;
switch (_that) {
case _GastoPorCategoria() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoria,  Money total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GastoPorCategoria() when $default != null:
return $default(_that.categoria,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoria,  Money total)  $default,) {final _that = this;
switch (_that) {
case _GastoPorCategoria():
return $default(_that.categoria,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoria,  Money total)?  $default,) {final _that = this;
switch (_that) {
case _GastoPorCategoria() when $default != null:
return $default(_that.categoria,_that.total);case _:
  return null;

}
}

}

/// @nodoc


class _GastoPorCategoria implements GastoPorCategoria {
  const _GastoPorCategoria({required this.categoria, required this.total});
  

@override final  String categoria;
@override final  Money total;

/// Create a copy of GastoPorCategoria
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GastoPorCategoriaCopyWith<_GastoPorCategoria> get copyWith => __$GastoPorCategoriaCopyWithImpl<_GastoPorCategoria>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GastoPorCategoria&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.total, total) || other.total == total));
}


@override
int get hashCode => Object.hash(runtimeType,categoria,total);

@override
String toString() {
  return 'GastoPorCategoria(categoria: $categoria, total: $total)';
}


}

/// @nodoc
abstract mixin class _$GastoPorCategoriaCopyWith<$Res> implements $GastoPorCategoriaCopyWith<$Res> {
  factory _$GastoPorCategoriaCopyWith(_GastoPorCategoria value, $Res Function(_GastoPorCategoria) _then) = __$GastoPorCategoriaCopyWithImpl;
@override @useResult
$Res call({
 String categoria, Money total
});




}
/// @nodoc
class __$GastoPorCategoriaCopyWithImpl<$Res>
    implements _$GastoPorCategoriaCopyWith<$Res> {
  __$GastoPorCategoriaCopyWithImpl(this._self, this._then);

  final _GastoPorCategoria _self;
  final $Res Function(_GastoPorCategoria) _then;

/// Create a copy of GastoPorCategoria
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoria = null,Object? total = null,}) {
  return _then(_GastoPorCategoria(
categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$ComparativaMensual {

 Money get ventasActual; Money get ventasAnterior; Money get gastosActual; Money get gastosAnterior; Money get gananciaActual; Money get gananciaAnterior;
/// Create a copy of ComparativaMensual
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComparativaMensualCopyWith<ComparativaMensual> get copyWith => _$ComparativaMensualCopyWithImpl<ComparativaMensual>(this as ComparativaMensual, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComparativaMensual&&(identical(other.ventasActual, ventasActual) || other.ventasActual == ventasActual)&&(identical(other.ventasAnterior, ventasAnterior) || other.ventasAnterior == ventasAnterior)&&(identical(other.gastosActual, gastosActual) || other.gastosActual == gastosActual)&&(identical(other.gastosAnterior, gastosAnterior) || other.gastosAnterior == gastosAnterior)&&(identical(other.gananciaActual, gananciaActual) || other.gananciaActual == gananciaActual)&&(identical(other.gananciaAnterior, gananciaAnterior) || other.gananciaAnterior == gananciaAnterior));
}


@override
int get hashCode => Object.hash(runtimeType,ventasActual,ventasAnterior,gastosActual,gastosAnterior,gananciaActual,gananciaAnterior);

@override
String toString() {
  return 'ComparativaMensual(ventasActual: $ventasActual, ventasAnterior: $ventasAnterior, gastosActual: $gastosActual, gastosAnterior: $gastosAnterior, gananciaActual: $gananciaActual, gananciaAnterior: $gananciaAnterior)';
}


}

/// @nodoc
abstract mixin class $ComparativaMensualCopyWith<$Res>  {
  factory $ComparativaMensualCopyWith(ComparativaMensual value, $Res Function(ComparativaMensual) _then) = _$ComparativaMensualCopyWithImpl;
@useResult
$Res call({
 Money ventasActual, Money ventasAnterior, Money gastosActual, Money gastosAnterior, Money gananciaActual, Money gananciaAnterior
});




}
/// @nodoc
class _$ComparativaMensualCopyWithImpl<$Res>
    implements $ComparativaMensualCopyWith<$Res> {
  _$ComparativaMensualCopyWithImpl(this._self, this._then);

  final ComparativaMensual _self;
  final $Res Function(ComparativaMensual) _then;

/// Create a copy of ComparativaMensual
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ventasActual = null,Object? ventasAnterior = null,Object? gastosActual = null,Object? gastosAnterior = null,Object? gananciaActual = null,Object? gananciaAnterior = null,}) {
  return _then(_self.copyWith(
ventasActual: null == ventasActual ? _self.ventasActual : ventasActual // ignore: cast_nullable_to_non_nullable
as Money,ventasAnterior: null == ventasAnterior ? _self.ventasAnterior : ventasAnterior // ignore: cast_nullable_to_non_nullable
as Money,gastosActual: null == gastosActual ? _self.gastosActual : gastosActual // ignore: cast_nullable_to_non_nullable
as Money,gastosAnterior: null == gastosAnterior ? _self.gastosAnterior : gastosAnterior // ignore: cast_nullable_to_non_nullable
as Money,gananciaActual: null == gananciaActual ? _self.gananciaActual : gananciaActual // ignore: cast_nullable_to_non_nullable
as Money,gananciaAnterior: null == gananciaAnterior ? _self.gananciaAnterior : gananciaAnterior // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [ComparativaMensual].
extension ComparativaMensualPatterns on ComparativaMensual {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComparativaMensual value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComparativaMensual() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComparativaMensual value)  $default,){
final _that = this;
switch (_that) {
case _ComparativaMensual():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComparativaMensual value)?  $default,){
final _that = this;
switch (_that) {
case _ComparativaMensual() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Money ventasActual,  Money ventasAnterior,  Money gastosActual,  Money gastosAnterior,  Money gananciaActual,  Money gananciaAnterior)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComparativaMensual() when $default != null:
return $default(_that.ventasActual,_that.ventasAnterior,_that.gastosActual,_that.gastosAnterior,_that.gananciaActual,_that.gananciaAnterior);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Money ventasActual,  Money ventasAnterior,  Money gastosActual,  Money gastosAnterior,  Money gananciaActual,  Money gananciaAnterior)  $default,) {final _that = this;
switch (_that) {
case _ComparativaMensual():
return $default(_that.ventasActual,_that.ventasAnterior,_that.gastosActual,_that.gastosAnterior,_that.gananciaActual,_that.gananciaAnterior);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Money ventasActual,  Money ventasAnterior,  Money gastosActual,  Money gastosAnterior,  Money gananciaActual,  Money gananciaAnterior)?  $default,) {final _that = this;
switch (_that) {
case _ComparativaMensual() when $default != null:
return $default(_that.ventasActual,_that.ventasAnterior,_that.gastosActual,_that.gastosAnterior,_that.gananciaActual,_that.gananciaAnterior);case _:
  return null;

}
}

}

/// @nodoc


class _ComparativaMensual extends ComparativaMensual {
  const _ComparativaMensual({required this.ventasActual, required this.ventasAnterior, required this.gastosActual, required this.gastosAnterior, required this.gananciaActual, required this.gananciaAnterior}): super._();
  

@override final  Money ventasActual;
@override final  Money ventasAnterior;
@override final  Money gastosActual;
@override final  Money gastosAnterior;
@override final  Money gananciaActual;
@override final  Money gananciaAnterior;

/// Create a copy of ComparativaMensual
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComparativaMensualCopyWith<_ComparativaMensual> get copyWith => __$ComparativaMensualCopyWithImpl<_ComparativaMensual>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComparativaMensual&&(identical(other.ventasActual, ventasActual) || other.ventasActual == ventasActual)&&(identical(other.ventasAnterior, ventasAnterior) || other.ventasAnterior == ventasAnterior)&&(identical(other.gastosActual, gastosActual) || other.gastosActual == gastosActual)&&(identical(other.gastosAnterior, gastosAnterior) || other.gastosAnterior == gastosAnterior)&&(identical(other.gananciaActual, gananciaActual) || other.gananciaActual == gananciaActual)&&(identical(other.gananciaAnterior, gananciaAnterior) || other.gananciaAnterior == gananciaAnterior));
}


@override
int get hashCode => Object.hash(runtimeType,ventasActual,ventasAnterior,gastosActual,gastosAnterior,gananciaActual,gananciaAnterior);

@override
String toString() {
  return 'ComparativaMensual(ventasActual: $ventasActual, ventasAnterior: $ventasAnterior, gastosActual: $gastosActual, gastosAnterior: $gastosAnterior, gananciaActual: $gananciaActual, gananciaAnterior: $gananciaAnterior)';
}


}

/// @nodoc
abstract mixin class _$ComparativaMensualCopyWith<$Res> implements $ComparativaMensualCopyWith<$Res> {
  factory _$ComparativaMensualCopyWith(_ComparativaMensual value, $Res Function(_ComparativaMensual) _then) = __$ComparativaMensualCopyWithImpl;
@override @useResult
$Res call({
 Money ventasActual, Money ventasAnterior, Money gastosActual, Money gastosAnterior, Money gananciaActual, Money gananciaAnterior
});




}
/// @nodoc
class __$ComparativaMensualCopyWithImpl<$Res>
    implements _$ComparativaMensualCopyWith<$Res> {
  __$ComparativaMensualCopyWithImpl(this._self, this._then);

  final _ComparativaMensual _self;
  final $Res Function(_ComparativaMensual) _then;

/// Create a copy of ComparativaMensual
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ventasActual = null,Object? ventasAnterior = null,Object? gastosActual = null,Object? gastosAnterior = null,Object? gananciaActual = null,Object? gananciaAnterior = null,}) {
  return _then(_ComparativaMensual(
ventasActual: null == ventasActual ? _self.ventasActual : ventasActual // ignore: cast_nullable_to_non_nullable
as Money,ventasAnterior: null == ventasAnterior ? _self.ventasAnterior : ventasAnterior // ignore: cast_nullable_to_non_nullable
as Money,gastosActual: null == gastosActual ? _self.gastosActual : gastosActual // ignore: cast_nullable_to_non_nullable
as Money,gastosAnterior: null == gastosAnterior ? _self.gastosAnterior : gastosAnterior // ignore: cast_nullable_to_non_nullable
as Money,gananciaActual: null == gananciaActual ? _self.gananciaActual : gananciaActual // ignore: cast_nullable_to_non_nullable
as Money,gananciaAnterior: null == gananciaAnterior ? _self.gananciaAnterior : gananciaAnterior // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$ProductoVentasRanking {

 String get id; String get nombre; double get unidades; Money get ganancia;
/// Create a copy of ProductoVentasRanking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductoVentasRankingCopyWith<ProductoVentasRanking> get copyWith => _$ProductoVentasRankingCopyWithImpl<ProductoVentasRanking>(this as ProductoVentasRanking, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductoVentasRanking&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.unidades, unidades) || other.unidades == unidades)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,unidades,ganancia);

@override
String toString() {
  return 'ProductoVentasRanking(id: $id, nombre: $nombre, unidades: $unidades, ganancia: $ganancia)';
}


}

/// @nodoc
abstract mixin class $ProductoVentasRankingCopyWith<$Res>  {
  factory $ProductoVentasRankingCopyWith(ProductoVentasRanking value, $Res Function(ProductoVentasRanking) _then) = _$ProductoVentasRankingCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, double unidades, Money ganancia
});




}
/// @nodoc
class _$ProductoVentasRankingCopyWithImpl<$Res>
    implements $ProductoVentasRankingCopyWith<$Res> {
  _$ProductoVentasRankingCopyWithImpl(this._self, this._then);

  final ProductoVentasRanking _self;
  final $Res Function(ProductoVentasRanking) _then;

/// Create a copy of ProductoVentasRanking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? unidades = null,Object? ganancia = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,unidades: null == unidades ? _self.unidades : unidades // ignore: cast_nullable_to_non_nullable
as double,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductoVentasRanking].
extension ProductoVentasRankingPatterns on ProductoVentasRanking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductoVentasRanking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductoVentasRanking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductoVentasRanking value)  $default,){
final _that = this;
switch (_that) {
case _ProductoVentasRanking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductoVentasRanking value)?  $default,){
final _that = this;
switch (_that) {
case _ProductoVentasRanking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  double unidades,  Money ganancia)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductoVentasRanking() when $default != null:
return $default(_that.id,_that.nombre,_that.unidades,_that.ganancia);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  double unidades,  Money ganancia)  $default,) {final _that = this;
switch (_that) {
case _ProductoVentasRanking():
return $default(_that.id,_that.nombre,_that.unidades,_that.ganancia);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  double unidades,  Money ganancia)?  $default,) {final _that = this;
switch (_that) {
case _ProductoVentasRanking() when $default != null:
return $default(_that.id,_that.nombre,_that.unidades,_that.ganancia);case _:
  return null;

}
}

}

/// @nodoc


class _ProductoVentasRanking implements ProductoVentasRanking {
  const _ProductoVentasRanking({required this.id, required this.nombre, required this.unidades, required this.ganancia});
  

@override final  String id;
@override final  String nombre;
@override final  double unidades;
@override final  Money ganancia;

/// Create a copy of ProductoVentasRanking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductoVentasRankingCopyWith<_ProductoVentasRanking> get copyWith => __$ProductoVentasRankingCopyWithImpl<_ProductoVentasRanking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductoVentasRanking&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.unidades, unidades) || other.unidades == unidades)&&(identical(other.ganancia, ganancia) || other.ganancia == ganancia));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,unidades,ganancia);

@override
String toString() {
  return 'ProductoVentasRanking(id: $id, nombre: $nombre, unidades: $unidades, ganancia: $ganancia)';
}


}

/// @nodoc
abstract mixin class _$ProductoVentasRankingCopyWith<$Res> implements $ProductoVentasRankingCopyWith<$Res> {
  factory _$ProductoVentasRankingCopyWith(_ProductoVentasRanking value, $Res Function(_ProductoVentasRanking) _then) = __$ProductoVentasRankingCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, double unidades, Money ganancia
});




}
/// @nodoc
class __$ProductoVentasRankingCopyWithImpl<$Res>
    implements _$ProductoVentasRankingCopyWith<$Res> {
  __$ProductoVentasRankingCopyWithImpl(this._self, this._then);

  final _ProductoVentasRanking _self;
  final $Res Function(_ProductoVentasRanking) _then;

/// Create a copy of ProductoVentasRanking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? unidades = null,Object? ganancia = null,}) {
  return _then(_ProductoVentasRanking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,unidades: null == unidades ? _self.unidades : unidades // ignore: cast_nullable_to_non_nullable
as double,ganancia: null == ganancia ? _self.ganancia : ganancia // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$EmpleadoPagosRanking {

 String get id; String get nombre; DateTime get fechaIngreso; Money get totalPagado;
/// Create a copy of EmpleadoPagosRanking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmpleadoPagosRankingCopyWith<EmpleadoPagosRanking> get copyWith => _$EmpleadoPagosRankingCopyWithImpl<EmpleadoPagosRanking>(this as EmpleadoPagosRanking, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmpleadoPagosRanking&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.fechaIngreso, fechaIngreso) || other.fechaIngreso == fechaIngreso)&&(identical(other.totalPagado, totalPagado) || other.totalPagado == totalPagado));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,fechaIngreso,totalPagado);

@override
String toString() {
  return 'EmpleadoPagosRanking(id: $id, nombre: $nombre, fechaIngreso: $fechaIngreso, totalPagado: $totalPagado)';
}


}

/// @nodoc
abstract mixin class $EmpleadoPagosRankingCopyWith<$Res>  {
  factory $EmpleadoPagosRankingCopyWith(EmpleadoPagosRanking value, $Res Function(EmpleadoPagosRanking) _then) = _$EmpleadoPagosRankingCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, DateTime fechaIngreso, Money totalPagado
});




}
/// @nodoc
class _$EmpleadoPagosRankingCopyWithImpl<$Res>
    implements $EmpleadoPagosRankingCopyWith<$Res> {
  _$EmpleadoPagosRankingCopyWithImpl(this._self, this._then);

  final EmpleadoPagosRanking _self;
  final $Res Function(EmpleadoPagosRanking) _then;

/// Create a copy of EmpleadoPagosRanking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? fechaIngreso = null,Object? totalPagado = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,fechaIngreso: null == fechaIngreso ? _self.fechaIngreso : fechaIngreso // ignore: cast_nullable_to_non_nullable
as DateTime,totalPagado: null == totalPagado ? _self.totalPagado : totalPagado // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [EmpleadoPagosRanking].
extension EmpleadoPagosRankingPatterns on EmpleadoPagosRanking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmpleadoPagosRanking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmpleadoPagosRanking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmpleadoPagosRanking value)  $default,){
final _that = this;
switch (_that) {
case _EmpleadoPagosRanking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmpleadoPagosRanking value)?  $default,){
final _that = this;
switch (_that) {
case _EmpleadoPagosRanking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  DateTime fechaIngreso,  Money totalPagado)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmpleadoPagosRanking() when $default != null:
return $default(_that.id,_that.nombre,_that.fechaIngreso,_that.totalPagado);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  DateTime fechaIngreso,  Money totalPagado)  $default,) {final _that = this;
switch (_that) {
case _EmpleadoPagosRanking():
return $default(_that.id,_that.nombre,_that.fechaIngreso,_that.totalPagado);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  DateTime fechaIngreso,  Money totalPagado)?  $default,) {final _that = this;
switch (_that) {
case _EmpleadoPagosRanking() when $default != null:
return $default(_that.id,_that.nombre,_that.fechaIngreso,_that.totalPagado);case _:
  return null;

}
}

}

/// @nodoc


class _EmpleadoPagosRanking implements EmpleadoPagosRanking {
  const _EmpleadoPagosRanking({required this.id, required this.nombre, required this.fechaIngreso, required this.totalPagado});
  

@override final  String id;
@override final  String nombre;
@override final  DateTime fechaIngreso;
@override final  Money totalPagado;

/// Create a copy of EmpleadoPagosRanking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmpleadoPagosRankingCopyWith<_EmpleadoPagosRanking> get copyWith => __$EmpleadoPagosRankingCopyWithImpl<_EmpleadoPagosRanking>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmpleadoPagosRanking&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.fechaIngreso, fechaIngreso) || other.fechaIngreso == fechaIngreso)&&(identical(other.totalPagado, totalPagado) || other.totalPagado == totalPagado));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,fechaIngreso,totalPagado);

@override
String toString() {
  return 'EmpleadoPagosRanking(id: $id, nombre: $nombre, fechaIngreso: $fechaIngreso, totalPagado: $totalPagado)';
}


}

/// @nodoc
abstract mixin class _$EmpleadoPagosRankingCopyWith<$Res> implements $EmpleadoPagosRankingCopyWith<$Res> {
  factory _$EmpleadoPagosRankingCopyWith(_EmpleadoPagosRanking value, $Res Function(_EmpleadoPagosRanking) _then) = __$EmpleadoPagosRankingCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, DateTime fechaIngreso, Money totalPagado
});




}
/// @nodoc
class __$EmpleadoPagosRankingCopyWithImpl<$Res>
    implements _$EmpleadoPagosRankingCopyWith<$Res> {
  __$EmpleadoPagosRankingCopyWithImpl(this._self, this._then);

  final _EmpleadoPagosRanking _self;
  final $Res Function(_EmpleadoPagosRanking) _then;

/// Create a copy of EmpleadoPagosRanking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? fechaIngreso = null,Object? totalPagado = null,}) {
  return _then(_EmpleadoPagosRanking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,fechaIngreso: null == fechaIngreso ? _self.fechaIngreso : fechaIngreso // ignore: cast_nullable_to_non_nullable
as DateTime,totalPagado: null == totalPagado ? _self.totalPagado : totalPagado // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

// dart format on
