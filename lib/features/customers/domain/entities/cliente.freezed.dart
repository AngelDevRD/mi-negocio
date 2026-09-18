// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cliente.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Cliente {

 String get id; String get nombre; String? get telefono; String? get nota;/// `null` = sin límite de crédito.
 Money? get limiteCredito; bool get activo; Money get saldo;
/// Create a copy of Cliente
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClienteCopyWith<Cliente> get copyWith => _$ClienteCopyWithImpl<Cliente>(this as Cliente, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cliente&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.limiteCredito, limiteCredito) || other.limiteCredito == limiteCredito)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.saldo, saldo) || other.saldo == saldo));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,telefono,nota,limiteCredito,activo,saldo);

@override
String toString() {
  return 'Cliente(id: $id, nombre: $nombre, telefono: $telefono, nota: $nota, limiteCredito: $limiteCredito, activo: $activo, saldo: $saldo)';
}


}

/// @nodoc
abstract mixin class $ClienteCopyWith<$Res>  {
  factory $ClienteCopyWith(Cliente value, $Res Function(Cliente) _then) = _$ClienteCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, String? telefono, String? nota, Money? limiteCredito, bool activo, Money saldo
});




}
/// @nodoc
class _$ClienteCopyWithImpl<$Res>
    implements $ClienteCopyWith<$Res> {
  _$ClienteCopyWithImpl(this._self, this._then);

  final Cliente _self;
  final $Res Function(Cliente) _then;

/// Create a copy of Cliente
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? telefono = freezed,Object? nota = freezed,Object? limiteCredito = freezed,Object? activo = null,Object? saldo = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,limiteCredito: freezed == limiteCredito ? _self.limiteCredito : limiteCredito // ignore: cast_nullable_to_non_nullable
as Money?,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,saldo: null == saldo ? _self.saldo : saldo // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}

}


/// Adds pattern-matching-related methods to [Cliente].
extension ClientePatterns on Cliente {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cliente value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cliente() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cliente value)  $default,){
final _that = this;
switch (_that) {
case _Cliente():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cliente value)?  $default,){
final _that = this;
switch (_that) {
case _Cliente() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  String? telefono,  String? nota,  Money? limiteCredito,  bool activo,  Money saldo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cliente() when $default != null:
return $default(_that.id,_that.nombre,_that.telefono,_that.nota,_that.limiteCredito,_that.activo,_that.saldo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  String? telefono,  String? nota,  Money? limiteCredito,  bool activo,  Money saldo)  $default,) {final _that = this;
switch (_that) {
case _Cliente():
return $default(_that.id,_that.nombre,_that.telefono,_that.nota,_that.limiteCredito,_that.activo,_that.saldo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  String? telefono,  String? nota,  Money? limiteCredito,  bool activo,  Money saldo)?  $default,) {final _that = this;
switch (_that) {
case _Cliente() when $default != null:
return $default(_that.id,_that.nombre,_that.telefono,_that.nota,_that.limiteCredito,_that.activo,_that.saldo);case _:
  return null;

}
}

}

/// @nodoc


class _Cliente implements Cliente {
  const _Cliente({required this.id, required this.nombre, this.telefono, this.nota, this.limiteCredito, required this.activo, required this.saldo});
  

@override final  String id;
@override final  String nombre;
@override final  String? telefono;
@override final  String? nota;
/// `null` = sin límite de crédito.
@override final  Money? limiteCredito;
@override final  bool activo;
@override final  Money saldo;

/// Create a copy of Cliente
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClienteCopyWith<_Cliente> get copyWith => __$ClienteCopyWithImpl<_Cliente>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cliente&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.limiteCredito, limiteCredito) || other.limiteCredito == limiteCredito)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.saldo, saldo) || other.saldo == saldo));
}


@override
int get hashCode => Object.hash(runtimeType,id,nombre,telefono,nota,limiteCredito,activo,saldo);

@override
String toString() {
  return 'Cliente(id: $id, nombre: $nombre, telefono: $telefono, nota: $nota, limiteCredito: $limiteCredito, activo: $activo, saldo: $saldo)';
}


}

/// @nodoc
abstract mixin class _$ClienteCopyWith<$Res> implements $ClienteCopyWith<$Res> {
  factory _$ClienteCopyWith(_Cliente value, $Res Function(_Cliente) _then) = __$ClienteCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, String? telefono, String? nota, Money? limiteCredito, bool activo, Money saldo
});




}
/// @nodoc
class __$ClienteCopyWithImpl<$Res>
    implements _$ClienteCopyWith<$Res> {
  __$ClienteCopyWithImpl(this._self, this._then);

  final _Cliente _self;
  final $Res Function(_Cliente) _then;

/// Create a copy of Cliente
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? telefono = freezed,Object? nota = freezed,Object? limiteCredito = freezed,Object? activo = null,Object? saldo = null,}) {
  return _then(_Cliente(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,limiteCredito: freezed == limiteCredito ? _self.limiteCredito : limiteCredito // ignore: cast_nullable_to_non_nullable
as Money?,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,saldo: null == saldo ? _self.saldo : saldo // ignore: cast_nullable_to_non_nullable
as Money,
  ));
}


}

/// @nodoc
mixin _$MovimientoCliente {

 String get id; TipoMovimientoCliente get tipo; Money get monto; String? get ventaId; MetodoPago? get metodoPago; String? get nota; DateTime get fecha; String get usuarioNombre;
/// Create a copy of MovimientoCliente
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovimientoClienteCopyWith<MovimientoCliente> get copyWith => _$MovimientoClienteCopyWithImpl<MovimientoCliente>(this as MovimientoCliente, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovimientoCliente&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.ventaId, ventaId) || other.ventaId == ventaId)&&(identical(other.metodoPago, metodoPago) || other.metodoPago == metodoPago)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,monto,ventaId,metodoPago,nota,fecha,usuarioNombre);

@override
String toString() {
  return 'MovimientoCliente(id: $id, tipo: $tipo, monto: $monto, ventaId: $ventaId, metodoPago: $metodoPago, nota: $nota, fecha: $fecha, usuarioNombre: $usuarioNombre)';
}


}

/// @nodoc
abstract mixin class $MovimientoClienteCopyWith<$Res>  {
  factory $MovimientoClienteCopyWith(MovimientoCliente value, $Res Function(MovimientoCliente) _then) = _$MovimientoClienteCopyWithImpl;
@useResult
$Res call({
 String id, TipoMovimientoCliente tipo, Money monto, String? ventaId, MetodoPago? metodoPago, String? nota, DateTime fecha, String usuarioNombre
});




}
/// @nodoc
class _$MovimientoClienteCopyWithImpl<$Res>
    implements $MovimientoClienteCopyWith<$Res> {
  _$MovimientoClienteCopyWithImpl(this._self, this._then);

  final MovimientoCliente _self;
  final $Res Function(MovimientoCliente) _then;

/// Create a copy of MovimientoCliente
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tipo = null,Object? monto = null,Object? ventaId = freezed,Object? metodoPago = freezed,Object? nota = freezed,Object? fecha = null,Object? usuarioNombre = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoMovimientoCliente,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,ventaId: freezed == ventaId ? _self.ventaId : ventaId // ignore: cast_nullable_to_non_nullable
as String?,metodoPago: freezed == metodoPago ? _self.metodoPago : metodoPago // ignore: cast_nullable_to_non_nullable
as MetodoPago?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MovimientoCliente].
extension MovimientoClientePatterns on MovimientoCliente {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovimientoCliente value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovimientoCliente() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovimientoCliente value)  $default,){
final _that = this;
switch (_that) {
case _MovimientoCliente():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovimientoCliente value)?  $default,){
final _that = this;
switch (_that) {
case _MovimientoCliente() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TipoMovimientoCliente tipo,  Money monto,  String? ventaId,  MetodoPago? metodoPago,  String? nota,  DateTime fecha,  String usuarioNombre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovimientoCliente() when $default != null:
return $default(_that.id,_that.tipo,_that.monto,_that.ventaId,_that.metodoPago,_that.nota,_that.fecha,_that.usuarioNombre);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TipoMovimientoCliente tipo,  Money monto,  String? ventaId,  MetodoPago? metodoPago,  String? nota,  DateTime fecha,  String usuarioNombre)  $default,) {final _that = this;
switch (_that) {
case _MovimientoCliente():
return $default(_that.id,_that.tipo,_that.monto,_that.ventaId,_that.metodoPago,_that.nota,_that.fecha,_that.usuarioNombre);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TipoMovimientoCliente tipo,  Money monto,  String? ventaId,  MetodoPago? metodoPago,  String? nota,  DateTime fecha,  String usuarioNombre)?  $default,) {final _that = this;
switch (_that) {
case _MovimientoCliente() when $default != null:
return $default(_that.id,_that.tipo,_that.monto,_that.ventaId,_that.metodoPago,_that.nota,_that.fecha,_that.usuarioNombre);case _:
  return null;

}
}

}

/// @nodoc


class _MovimientoCliente implements MovimientoCliente {
  const _MovimientoCliente({required this.id, required this.tipo, required this.monto, this.ventaId, this.metodoPago, this.nota, required this.fecha, required this.usuarioNombre});
  

@override final  String id;
@override final  TipoMovimientoCliente tipo;
@override final  Money monto;
@override final  String? ventaId;
@override final  MetodoPago? metodoPago;
@override final  String? nota;
@override final  DateTime fecha;
@override final  String usuarioNombre;

/// Create a copy of MovimientoCliente
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovimientoClienteCopyWith<_MovimientoCliente> get copyWith => __$MovimientoClienteCopyWithImpl<_MovimientoCliente>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovimientoCliente&&(identical(other.id, id) || other.id == id)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.monto, monto) || other.monto == monto)&&(identical(other.ventaId, ventaId) || other.ventaId == ventaId)&&(identical(other.metodoPago, metodoPago) || other.metodoPago == metodoPago)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.fecha, fecha) || other.fecha == fecha)&&(identical(other.usuarioNombre, usuarioNombre) || other.usuarioNombre == usuarioNombre));
}


@override
int get hashCode => Object.hash(runtimeType,id,tipo,monto,ventaId,metodoPago,nota,fecha,usuarioNombre);

@override
String toString() {
  return 'MovimientoCliente(id: $id, tipo: $tipo, monto: $monto, ventaId: $ventaId, metodoPago: $metodoPago, nota: $nota, fecha: $fecha, usuarioNombre: $usuarioNombre)';
}


}

/// @nodoc
abstract mixin class _$MovimientoClienteCopyWith<$Res> implements $MovimientoClienteCopyWith<$Res> {
  factory _$MovimientoClienteCopyWith(_MovimientoCliente value, $Res Function(_MovimientoCliente) _then) = __$MovimientoClienteCopyWithImpl;
@override @useResult
$Res call({
 String id, TipoMovimientoCliente tipo, Money monto, String? ventaId, MetodoPago? metodoPago, String? nota, DateTime fecha, String usuarioNombre
});




}
/// @nodoc
class __$MovimientoClienteCopyWithImpl<$Res>
    implements _$MovimientoClienteCopyWith<$Res> {
  __$MovimientoClienteCopyWithImpl(this._self, this._then);

  final _MovimientoCliente _self;
  final $Res Function(_MovimientoCliente) _then;

/// Create a copy of MovimientoCliente
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tipo = null,Object? monto = null,Object? ventaId = freezed,Object? metodoPago = freezed,Object? nota = freezed,Object? fecha = null,Object? usuarioNombre = null,}) {
  return _then(_MovimientoCliente(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoMovimientoCliente,monto: null == monto ? _self.monto : monto // ignore: cast_nullable_to_non_nullable
as Money,ventaId: freezed == ventaId ? _self.ventaId : ventaId // ignore: cast_nullable_to_non_nullable
as String?,metodoPago: freezed == metodoPago ? _self.metodoPago : metodoPago // ignore: cast_nullable_to_non_nullable
as MetodoPago?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,fecha: null == fecha ? _self.fecha : fecha // ignore: cast_nullable_to_non_nullable
as DateTime,usuarioNombre: null == usuarioNombre ? _self.usuarioNombre : usuarioNombre // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
