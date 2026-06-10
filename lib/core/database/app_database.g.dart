// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NegociosTable extends Negocios with TableInfo<$NegociosTable, Negocio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NegociosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _identificacionMeta = const VerificationMeta(
    'identificacion',
  );
  @override
  late final GeneratedColumn<String> identificacion = GeneratedColumn<String>(
    'identificacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _direccionMeta = const VerificationMeta(
    'direccion',
  );
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
    'direccion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monedaMeta = const VerificationMeta('moneda');
  @override
  late final GeneratedColumn<String> moneda = GeneratedColumn<String>(
    'moneda',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DOP'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    nombre,
    identificacion,
    direccion,
    telefono,
    email,
    logoPath,
    moneda,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'negocios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Negocio> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('identificacion')) {
      context.handle(
        _identificacionMeta,
        identificacion.isAcceptableOrUnknown(
          data['identificacion']!,
          _identificacionMeta,
        ),
      );
    }
    if (data.containsKey('direccion')) {
      context.handle(
        _direccionMeta,
        direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta),
      );
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('moneda')) {
      context.handle(
        _monedaMeta,
        moneda.isAcceptableOrUnknown(data['moneda']!, _monedaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Negocio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Negocio(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      identificacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identificacion'],
      ),
      direccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion'],
      ),
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      moneda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda'],
      )!,
    );
  }

  @override
  $NegociosTable createAlias(String alias) {
    return $NegociosTable(attachedDatabase, alias);
  }
}

class Negocio extends DataClass implements Insertable<Negocio> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String nombre;

  /// RNC o cédula del negocio (opcional).
  final String? identificacion;
  final String? direccion;
  final String? telefono;
  final String? email;
  final String? logoPath;
  final String moneda;
  const Negocio({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.nombre,
    this.identificacion,
    this.direccion,
    this.telefono,
    this.email,
    this.logoPath,
    required this.moneda,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || identificacion != null) {
      map['identificacion'] = Variable<String>(identificacion);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['moneda'] = Variable<String>(moneda);
    return map;
  }

  NegociosCompanion toCompanion(bool nullToAbsent) {
    return NegociosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      nombre: Value(nombre),
      identificacion: identificacion == null && nullToAbsent
          ? const Value.absent()
          : Value(identificacion),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      moneda: Value(moneda),
    );
  }

  factory Negocio.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Negocio(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
      identificacion: serializer.fromJson<String?>(json['identificacion']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      email: serializer.fromJson<String?>(json['email']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      moneda: serializer.fromJson<String>(json['moneda']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'nombre': serializer.toJson<String>(nombre),
      'identificacion': serializer.toJson<String?>(identificacion),
      'direccion': serializer.toJson<String?>(direccion),
      'telefono': serializer.toJson<String?>(telefono),
      'email': serializer.toJson<String?>(email),
      'logoPath': serializer.toJson<String?>(logoPath),
      'moneda': serializer.toJson<String>(moneda),
    };
  }

  Negocio copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    Value<String?> identificacion = const Value.absent(),
    Value<String?> direccion = const Value.absent(),
    Value<String?> telefono = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> logoPath = const Value.absent(),
    String? moneda,
  }) => Negocio(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    nombre: nombre ?? this.nombre,
    identificacion: identificacion.present
        ? identificacion.value
        : this.identificacion,
    direccion: direccion.present ? direccion.value : this.direccion,
    telefono: telefono.present ? telefono.value : this.telefono,
    email: email.present ? email.value : this.email,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    moneda: moneda ?? this.moneda,
  );
  Negocio copyWithCompanion(NegociosCompanion data) {
    return Negocio(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      identificacion: data.identificacion.present
          ? data.identificacion.value
          : this.identificacion,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      email: data.email.present ? data.email.value : this.email,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      moneda: data.moneda.present ? data.moneda.value : this.moneda,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Negocio(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nombre: $nombre, ')
          ..write('identificacion: $identificacion, ')
          ..write('direccion: $direccion, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('logoPath: $logoPath, ')
          ..write('moneda: $moneda')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    nombre,
    identificacion,
    direccion,
    telefono,
    email,
    logoPath,
    moneda,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Negocio &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.nombre == this.nombre &&
          other.identificacion == this.identificacion &&
          other.direccion == this.direccion &&
          other.telefono == this.telefono &&
          other.email == this.email &&
          other.logoPath == this.logoPath &&
          other.moneda == this.moneda);
}

class NegociosCompanion extends UpdateCompanion<Negocio> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> nombre;
  final Value<String?> identificacion;
  final Value<String?> direccion;
  final Value<String?> telefono;
  final Value<String?> email;
  final Value<String?> logoPath;
  final Value<String> moneda;
  final Value<int> rowid;
  const NegociosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.identificacion = const Value.absent(),
    this.direccion = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.moneda = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NegociosCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String nombre,
    this.identificacion = const Value.absent(),
    this.direccion = const Value.absent(),
    this.telefono = const Value.absent(),
    this.email = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.moneda = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Negocio> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? nombre,
    Expression<String>? identificacion,
    Expression<String>? direccion,
    Expression<String>? telefono,
    Expression<String>? email,
    Expression<String>? logoPath,
    Expression<String>? moneda,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (nombre != null) 'nombre': nombre,
      if (identificacion != null) 'identificacion': identificacion,
      if (direccion != null) 'direccion': direccion,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (logoPath != null) 'logo_path': logoPath,
      if (moneda != null) 'moneda': moneda,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NegociosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? nombre,
    Value<String?>? identificacion,
    Value<String?>? direccion,
    Value<String?>? telefono,
    Value<String?>? email,
    Value<String?>? logoPath,
    Value<String>? moneda,
    Value<int>? rowid,
  }) {
    return NegociosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      identificacion: identificacion ?? this.identificacion,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      logoPath: logoPath ?? this.logoPath,
      moneda: moneda ?? this.moneda,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (identificacion.present) {
      map['identificacion'] = Variable<String>(identificacion.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (moneda.present) {
      map['moneda'] = Variable<String>(moneda.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NegociosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nombre: $nombre, ')
          ..write('identificacion: $identificacion, ')
          ..write('direccion: $direccion, ')
          ..write('telefono: $telefono, ')
          ..write('email: $email, ')
          ..write('logoPath: $logoPath, ')
          ..write('moneda: $moneda, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsuariosTable extends Usuarios with TableInfo<$UsuariosTable, Usuario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _negocioIdMeta = const VerificationMeta(
    'negocioId',
  );
  @override
  late final GeneratedColumn<String> negocioId = GeneratedColumn<String>(
    'negocio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES negocios (id)',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RolUsuario, String> rol =
      GeneratedColumn<String>(
        'rol',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RolUsuario>($UsuariosTable.$converterrol);
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    deletedAt,
    id,
    createdAt,
    updatedAt,
    negocioId,
    nombre,
    username,
    passwordHash,
    salt,
    rol,
    activo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Usuario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('negocio_id')) {
      context.handle(
        _negocioIdMeta,
        negocioId.isAcceptableOrUnknown(data['negocio_id']!, _negocioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_negocioIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Usuario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Usuario(
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      negocioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}negocio_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salt'],
      )!,
      rol: $UsuariosTable.$converterrol.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rol'],
        )!,
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RolUsuario, String, String> $converterrol =
      const EnumNameConverter<RolUsuario>(RolUsuario.values);
}

class Usuario extends DataClass implements Insertable<Usuario> {
  final DateTime? deletedAt;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String negocioId;
  final String nombre;
  final String username;
  final String passwordHash;
  final String salt;
  final RolUsuario rol;
  final bool activo;
  const Usuario({
    this.deletedAt,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.negocioId,
    required this.nombre,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.rol,
    required this.activo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['negocio_id'] = Variable<String>(negocioId);
    map['nombre'] = Variable<String>(nombre);
    map['username'] = Variable<String>(username);
    map['password_hash'] = Variable<String>(passwordHash);
    map['salt'] = Variable<String>(salt);
    {
      map['rol'] = Variable<String>($UsuariosTable.$converterrol.toSql(rol));
    }
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      negocioId: Value(negocioId),
      nombre: Value(nombre),
      username: Value(username),
      passwordHash: Value(passwordHash),
      salt: Value(salt),
      rol: Value(rol),
      activo: Value(activo),
    );
  }

  factory Usuario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Usuario(
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      negocioId: serializer.fromJson<String>(json['negocioId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      username: serializer.fromJson<String>(json['username']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      salt: serializer.fromJson<String>(json['salt']),
      rol: $UsuariosTable.$converterrol.fromJson(
        serializer.fromJson<String>(json['rol']),
      ),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'negocioId': serializer.toJson<String>(negocioId),
      'nombre': serializer.toJson<String>(nombre),
      'username': serializer.toJson<String>(username),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'salt': serializer.toJson<String>(salt),
      'rol': serializer.toJson<String>(
        $UsuariosTable.$converterrol.toJson(rol),
      ),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  Usuario copyWith({
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? negocioId,
    String? nombre,
    String? username,
    String? passwordHash,
    String? salt,
    RolUsuario? rol,
    bool? activo,
  }) => Usuario(
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    negocioId: negocioId ?? this.negocioId,
    nombre: nombre ?? this.nombre,
    username: username ?? this.username,
    passwordHash: passwordHash ?? this.passwordHash,
    salt: salt ?? this.salt,
    rol: rol ?? this.rol,
    activo: activo ?? this.activo,
  );
  Usuario copyWithCompanion(UsuariosCompanion data) {
    return Usuario(
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      negocioId: data.negocioId.present ? data.negocioId.value : this.negocioId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      username: data.username.present ? data.username.value : this.username,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      salt: data.salt.present ? data.salt.value : this.salt,
      rol: data.rol.present ? data.rol.value : this.rol,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Usuario(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('negocioId: $negocioId, ')
          ..write('nombre: $nombre, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('rol: $rol, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deletedAt,
    id,
    createdAt,
    updatedAt,
    negocioId,
    nombre,
    username,
    passwordHash,
    salt,
    rol,
    activo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Usuario &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.negocioId == this.negocioId &&
          other.nombre == this.nombre &&
          other.username == this.username &&
          other.passwordHash == this.passwordHash &&
          other.salt == this.salt &&
          other.rol == this.rol &&
          other.activo == this.activo);
}

class UsuariosCompanion extends UpdateCompanion<Usuario> {
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> negocioId;
  final Value<String> nombre;
  final Value<String> username;
  final Value<String> passwordHash;
  final Value<String> salt;
  final Value<RolUsuario> rol;
  final Value<bool> activo;
  final Value<int> rowid;
  const UsuariosCompanion({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.negocioId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.username = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.salt = const Value.absent(),
    this.rol = const Value.absent(),
    this.activo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsuariosCompanion.insert({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String negocioId,
    required String nombre,
    required String username,
    required String passwordHash,
    required String salt,
    required RolUsuario rol,
    this.activo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : negocioId = Value(negocioId),
       nombre = Value(nombre),
       username = Value(username),
       passwordHash = Value(passwordHash),
       salt = Value(salt),
       rol = Value(rol);
  static Insertable<Usuario> custom({
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? negocioId,
    Expression<String>? nombre,
    Expression<String>? username,
    Expression<String>? passwordHash,
    Expression<String>? salt,
    Expression<String>? rol,
    Expression<bool>? activo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (negocioId != null) 'negocio_id': negocioId,
      if (nombre != null) 'nombre': nombre,
      if (username != null) 'username': username,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (salt != null) 'salt': salt,
      if (rol != null) 'rol': rol,
      if (activo != null) 'activo': activo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsuariosCompanion copyWith({
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? negocioId,
    Value<String>? nombre,
    Value<String>? username,
    Value<String>? passwordHash,
    Value<String>? salt,
    Value<RolUsuario>? rol,
    Value<bool>? activo,
    Value<int>? rowid,
  }) {
    return UsuariosCompanion(
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      negocioId: negocioId ?? this.negocioId,
      nombre: nombre ?? this.nombre,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (negocioId.present) {
      map['negocio_id'] = Variable<String>(negocioId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(
        $UsuariosTable.$converterrol.toSql(rol.value),
      );
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('negocioId: $negocioId, ')
          ..write('nombre: $nombre, ')
          ..write('username: $username, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('salt: $salt, ')
          ..write('rol: $rol, ')
          ..write('activo: $activo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LicenciasCacheTable extends LicenciasCache
    with TableInfo<$LicenciasCacheTable, LicenciasCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LicenciasCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoLicencia, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoLicencia>($LicenciasCacheTable.$convertertipo);
  @override
  late final GeneratedColumnWithTypeConverter<EstadoLicencia, String> estado =
      GeneratedColumn<String>(
        'estado',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EstadoLicencia>($LicenciasCacheTable.$converterestado);
  static const VerificationMeta _claveLicenciaMeta = const VerificationMeta(
    'claveLicencia',
  );
  @override
  late final GeneratedColumn<String> claveLicencia = GeneratedColumn<String>(
    'clave_licencia',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaActivacionMeta = const VerificationMeta(
    'fechaActivacion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaActivacion =
      GeneratedColumn<DateTime>(
        'fecha_activacion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fechaVencimientoMeta = const VerificationMeta(
    'fechaVencimiento',
  );
  @override
  late final GeneratedColumn<DateTime> fechaVencimiento =
      GeneratedColumn<DateTime>(
        'fecha_vencimiento',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ultimaValidacionMeta = const VerificationMeta(
    'ultimaValidacion',
  );
  @override
  late final GeneratedColumn<DateTime> ultimaValidacion =
      GeneratedColumn<DateTime>(
        'ultima_validacion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    tipo,
    estado,
    claveLicencia,
    deviceId,
    fechaActivacion,
    fechaVencimiento,
    ultimaValidacion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'licencias_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LicenciasCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('clave_licencia')) {
      context.handle(
        _claveLicenciaMeta,
        claveLicencia.isAcceptableOrUnknown(
          data['clave_licencia']!,
          _claveLicenciaMeta,
        ),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('fecha_activacion')) {
      context.handle(
        _fechaActivacionMeta,
        fechaActivacion.isAcceptableOrUnknown(
          data['fecha_activacion']!,
          _fechaActivacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaActivacionMeta);
    }
    if (data.containsKey('fecha_vencimiento')) {
      context.handle(
        _fechaVencimientoMeta,
        fechaVencimiento.isAcceptableOrUnknown(
          data['fecha_vencimiento']!,
          _fechaVencimientoMeta,
        ),
      );
    }
    if (data.containsKey('ultima_validacion')) {
      context.handle(
        _ultimaValidacionMeta,
        ultimaValidacion.isAcceptableOrUnknown(
          data['ultima_validacion']!,
          _ultimaValidacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ultimaValidacionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LicenciasCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LicenciasCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      tipo: $LicenciasCacheTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      estado: $LicenciasCacheTable.$converterestado.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado'],
        )!,
      ),
      claveLicencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave_licencia'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      fechaActivacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_activacion'],
      )!,
      fechaVencimiento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_vencimiento'],
      ),
      ultimaValidacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultima_validacion'],
      )!,
    );
  }

  @override
  $LicenciasCacheTable createAlias(String alias) {
    return $LicenciasCacheTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoLicencia, String, String> $convertertipo =
      const EnumNameConverter<TipoLicencia>(TipoLicencia.values);
  static JsonTypeConverter2<EstadoLicencia, String, String> $converterestado =
      const EnumNameConverter<EstadoLicencia>(EstadoLicencia.values);
}

class LicenciasCacheData extends DataClass
    implements Insertable<LicenciasCacheData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TipoLicencia tipo;
  final EstadoLicencia estado;
  final String? claveLicencia;
  final String deviceId;
  final DateTime fechaActivacion;
  final DateTime? fechaVencimiento;
  final DateTime ultimaValidacion;
  const LicenciasCacheData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.tipo,
    required this.estado,
    this.claveLicencia,
    required this.deviceId,
    required this.fechaActivacion,
    this.fechaVencimiento,
    required this.ultimaValidacion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    {
      map['tipo'] = Variable<String>(
        $LicenciasCacheTable.$convertertipo.toSql(tipo),
      );
    }
    {
      map['estado'] = Variable<String>(
        $LicenciasCacheTable.$converterestado.toSql(estado),
      );
    }
    if (!nullToAbsent || claveLicencia != null) {
      map['clave_licencia'] = Variable<String>(claveLicencia);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['fecha_activacion'] = Variable<DateTime>(fechaActivacion);
    if (!nullToAbsent || fechaVencimiento != null) {
      map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento);
    }
    map['ultima_validacion'] = Variable<DateTime>(ultimaValidacion);
    return map;
  }

  LicenciasCacheCompanion toCompanion(bool nullToAbsent) {
    return LicenciasCacheCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tipo: Value(tipo),
      estado: Value(estado),
      claveLicencia: claveLicencia == null && nullToAbsent
          ? const Value.absent()
          : Value(claveLicencia),
      deviceId: Value(deviceId),
      fechaActivacion: Value(fechaActivacion),
      fechaVencimiento: fechaVencimiento == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaVencimiento),
      ultimaValidacion: Value(ultimaValidacion),
    );
  }

  factory LicenciasCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LicenciasCacheData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tipo: $LicenciasCacheTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      estado: $LicenciasCacheTable.$converterestado.fromJson(
        serializer.fromJson<String>(json['estado']),
      ),
      claveLicencia: serializer.fromJson<String?>(json['claveLicencia']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      fechaActivacion: serializer.fromJson<DateTime>(json['fechaActivacion']),
      fechaVencimiento: serializer.fromJson<DateTime?>(
        json['fechaVencimiento'],
      ),
      ultimaValidacion: serializer.fromJson<DateTime>(json['ultimaValidacion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tipo': serializer.toJson<String>(
        $LicenciasCacheTable.$convertertipo.toJson(tipo),
      ),
      'estado': serializer.toJson<String>(
        $LicenciasCacheTable.$converterestado.toJson(estado),
      ),
      'claveLicencia': serializer.toJson<String?>(claveLicencia),
      'deviceId': serializer.toJson<String>(deviceId),
      'fechaActivacion': serializer.toJson<DateTime>(fechaActivacion),
      'fechaVencimiento': serializer.toJson<DateTime?>(fechaVencimiento),
      'ultimaValidacion': serializer.toJson<DateTime>(ultimaValidacion),
    };
  }

  LicenciasCacheData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    TipoLicencia? tipo,
    EstadoLicencia? estado,
    Value<String?> claveLicencia = const Value.absent(),
    String? deviceId,
    DateTime? fechaActivacion,
    Value<DateTime?> fechaVencimiento = const Value.absent(),
    DateTime? ultimaValidacion,
  }) => LicenciasCacheData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tipo: tipo ?? this.tipo,
    estado: estado ?? this.estado,
    claveLicencia: claveLicencia.present
        ? claveLicencia.value
        : this.claveLicencia,
    deviceId: deviceId ?? this.deviceId,
    fechaActivacion: fechaActivacion ?? this.fechaActivacion,
    fechaVencimiento: fechaVencimiento.present
        ? fechaVencimiento.value
        : this.fechaVencimiento,
    ultimaValidacion: ultimaValidacion ?? this.ultimaValidacion,
  );
  LicenciasCacheData copyWithCompanion(LicenciasCacheCompanion data) {
    return LicenciasCacheData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      estado: data.estado.present ? data.estado.value : this.estado,
      claveLicencia: data.claveLicencia.present
          ? data.claveLicencia.value
          : this.claveLicencia,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      fechaActivacion: data.fechaActivacion.present
          ? data.fechaActivacion.value
          : this.fechaActivacion,
      fechaVencimiento: data.fechaVencimiento.present
          ? data.fechaVencimiento.value
          : this.fechaVencimiento,
      ultimaValidacion: data.ultimaValidacion.present
          ? data.ultimaValidacion.value
          : this.ultimaValidacion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LicenciasCacheData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tipo: $tipo, ')
          ..write('estado: $estado, ')
          ..write('claveLicencia: $claveLicencia, ')
          ..write('deviceId: $deviceId, ')
          ..write('fechaActivacion: $fechaActivacion, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('ultimaValidacion: $ultimaValidacion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    tipo,
    estado,
    claveLicencia,
    deviceId,
    fechaActivacion,
    fechaVencimiento,
    ultimaValidacion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LicenciasCacheData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tipo == this.tipo &&
          other.estado == this.estado &&
          other.claveLicencia == this.claveLicencia &&
          other.deviceId == this.deviceId &&
          other.fechaActivacion == this.fechaActivacion &&
          other.fechaVencimiento == this.fechaVencimiento &&
          other.ultimaValidacion == this.ultimaValidacion);
}

class LicenciasCacheCompanion extends UpdateCompanion<LicenciasCacheData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<TipoLicencia> tipo;
  final Value<EstadoLicencia> estado;
  final Value<String?> claveLicencia;
  final Value<String> deviceId;
  final Value<DateTime> fechaActivacion;
  final Value<DateTime?> fechaVencimiento;
  final Value<DateTime> ultimaValidacion;
  final Value<int> rowid;
  const LicenciasCacheCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tipo = const Value.absent(),
    this.estado = const Value.absent(),
    this.claveLicencia = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.fechaActivacion = const Value.absent(),
    this.fechaVencimiento = const Value.absent(),
    this.ultimaValidacion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LicenciasCacheCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required TipoLicencia tipo,
    required EstadoLicencia estado,
    this.claveLicencia = const Value.absent(),
    required String deviceId,
    required DateTime fechaActivacion,
    this.fechaVencimiento = const Value.absent(),
    required DateTime ultimaValidacion,
    this.rowid = const Value.absent(),
  }) : tipo = Value(tipo),
       estado = Value(estado),
       deviceId = Value(deviceId),
       fechaActivacion = Value(fechaActivacion),
       ultimaValidacion = Value(ultimaValidacion);
  static Insertable<LicenciasCacheData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? tipo,
    Expression<String>? estado,
    Expression<String>? claveLicencia,
    Expression<String>? deviceId,
    Expression<DateTime>? fechaActivacion,
    Expression<DateTime>? fechaVencimiento,
    Expression<DateTime>? ultimaValidacion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tipo != null) 'tipo': tipo,
      if (estado != null) 'estado': estado,
      if (claveLicencia != null) 'clave_licencia': claveLicencia,
      if (deviceId != null) 'device_id': deviceId,
      if (fechaActivacion != null) 'fecha_activacion': fechaActivacion,
      if (fechaVencimiento != null) 'fecha_vencimiento': fechaVencimiento,
      if (ultimaValidacion != null) 'ultima_validacion': ultimaValidacion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LicenciasCacheCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<TipoLicencia>? tipo,
    Value<EstadoLicencia>? estado,
    Value<String?>? claveLicencia,
    Value<String>? deviceId,
    Value<DateTime>? fechaActivacion,
    Value<DateTime?>? fechaVencimiento,
    Value<DateTime>? ultimaValidacion,
    Value<int>? rowid,
  }) {
    return LicenciasCacheCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      claveLicencia: claveLicencia ?? this.claveLicencia,
      deviceId: deviceId ?? this.deviceId,
      fechaActivacion: fechaActivacion ?? this.fechaActivacion,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      ultimaValidacion: ultimaValidacion ?? this.ultimaValidacion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $LicenciasCacheTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (estado.present) {
      map['estado'] = Variable<String>(
        $LicenciasCacheTable.$converterestado.toSql(estado.value),
      );
    }
    if (claveLicencia.present) {
      map['clave_licencia'] = Variable<String>(claveLicencia.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (fechaActivacion.present) {
      map['fecha_activacion'] = Variable<DateTime>(fechaActivacion.value);
    }
    if (fechaVencimiento.present) {
      map['fecha_vencimiento'] = Variable<DateTime>(fechaVencimiento.value);
    }
    if (ultimaValidacion.present) {
      map['ultima_validacion'] = Variable<DateTime>(ultimaValidacion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LicenciasCacheCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tipo: $tipo, ')
          ..write('estado: $estado, ')
          ..write('claveLicencia: $claveLicencia, ')
          ..write('deviceId: $deviceId, ')
          ..write('fechaActivacion: $fechaActivacion, ')
          ..write('fechaVencimiento: $fechaVencimiento, ')
          ..write('ultimaValidacion: $ultimaValidacion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracionesTable extends Configuraciones
    with TableInfo<$ConfiguracionesTable, Configuracione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [clave, valor, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuraciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Configuracione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clave};
  @override
  Configuracione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Configuracione(
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConfiguracionesTable createAlias(String alias) {
    return $ConfiguracionesTable(attachedDatabase, alias);
  }
}

class Configuracione extends DataClass implements Insertable<Configuracione> {
  final String clave;
  final String valor;
  final DateTime updatedAt;
  const Configuracione({
    required this.clave,
    required this.valor,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clave'] = Variable<String>(clave);
    map['valor'] = Variable<String>(valor);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConfiguracionesCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracionesCompanion(
      clave: Value(clave),
      valor: Value(valor),
      updatedAt: Value(updatedAt),
    );
  }

  factory Configuracione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Configuracione(
      clave: serializer.fromJson<String>(json['clave']),
      valor: serializer.fromJson<String>(json['valor']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clave': serializer.toJson<String>(clave),
      'valor': serializer.toJson<String>(valor),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Configuracione copyWith({
    String? clave,
    String? valor,
    DateTime? updatedAt,
  }) => Configuracione(
    clave: clave ?? this.clave,
    valor: valor ?? this.valor,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Configuracione copyWithCompanion(ConfiguracionesCompanion data) {
    return Configuracione(
      clave: data.clave.present ? data.clave.value : this.clave,
      valor: data.valor.present ? data.valor.value : this.valor,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Configuracione(')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clave, valor, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Configuracione &&
          other.clave == this.clave &&
          other.valor == this.valor &&
          other.updatedAt == this.updatedAt);
}

class ConfiguracionesCompanion extends UpdateCompanion<Configuracione> {
  final Value<String> clave;
  final Value<String> valor;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConfiguracionesCompanion({
    this.clave = const Value.absent(),
    this.valor = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfiguracionesCompanion.insert({
    required String clave,
    required String valor,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clave = Value(clave),
       valor = Value(valor);
  static Insertable<Configuracione> custom({
    Expression<String>? clave,
    Expression<String>? valor,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clave != null) 'clave': clave,
      if (valor != null) 'valor': valor,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfiguracionesCompanion copyWith({
    Value<String>? clave,
    Value<String>? valor,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ConfiguracionesCompanion(
      clave: clave ?? this.clave,
      valor: valor ?? this.valor,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracionesCompanion(')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deletedAt,
    id,
    createdAt,
    updatedAt,
    nombre,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final DateTime? deletedAt;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String nombre;
  const Categoria({
    this.deletedAt,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.nombre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['nombre'] = Variable<String>(nombre);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      nombre: Value(nombre),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'nombre': serializer.toJson<String>(nombre),
    };
  }

  Categoria copyWith({
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
  }) => Categoria(
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    nombre: nombre ?? this.nombre,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nombre: $nombre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deletedAt, id, createdAt, updatedAt, nombre);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.nombre == this.nombre);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> nombre;
  final Value<int> rowid;
  const CategoriasCompanion({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String nombre,
    this.rowid = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Categoria> custom({
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? nombre,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (nombre != null) 'nombre': nombre,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriasCompanion copyWith({
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? nombre,
    Value<int>? rowid,
  }) {
    return CategoriasCompanion(
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nombre: $nombre, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, Producto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<String> categoriaId = GeneratedColumn<String>(
    'categoria_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _unidadMeta = const VerificationMeta('unidad');
  @override
  late final GeneratedColumn<String> unidad = GeneratedColumn<String>(
    'unidad',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unidad'),
  );
  static const VerificationMeta _precioCompraMeta = const VerificationMeta(
    'precioCompra',
  );
  @override
  late final GeneratedColumn<int> precioCompra = GeneratedColumn<int>(
    'precio_compra',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _precioVentaMeta = const VerificationMeta(
    'precioVenta',
  );
  @override
  late final GeneratedColumn<int> precioVenta = GeneratedColumn<int>(
    'precio_venta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockActualMeta = const VerificationMeta(
    'stockActual',
  );
  @override
  late final GeneratedColumn<double> stockActual = GeneratedColumn<double>(
    'stock_actual',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockMinimoMeta = const VerificationMeta(
    'stockMinimo',
  );
  @override
  late final GeneratedColumn<double> stockMinimo = GeneratedColumn<double>(
    'stock_minimo',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    deletedAt,
    id,
    createdAt,
    updatedAt,
    nombre,
    categoriaId,
    unidad,
    precioCompra,
    precioVenta,
    stockActual,
    stockMinimo,
    activo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Producto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('unidad')) {
      context.handle(
        _unidadMeta,
        unidad.isAcceptableOrUnknown(data['unidad']!, _unidadMeta),
      );
    }
    if (data.containsKey('precio_compra')) {
      context.handle(
        _precioCompraMeta,
        precioCompra.isAcceptableOrUnknown(
          data['precio_compra']!,
          _precioCompraMeta,
        ),
      );
    }
    if (data.containsKey('precio_venta')) {
      context.handle(
        _precioVentaMeta,
        precioVenta.isAcceptableOrUnknown(
          data['precio_venta']!,
          _precioVentaMeta,
        ),
      );
    }
    if (data.containsKey('stock_actual')) {
      context.handle(
        _stockActualMeta,
        stockActual.isAcceptableOrUnknown(
          data['stock_actual']!,
          _stockActualMeta,
        ),
      );
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
        _stockMinimoMeta,
        stockMinimo.isAcceptableOrUnknown(
          data['stock_minimo']!,
          _stockMinimoMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producto(
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria_id'],
      ),
      unidad: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidad'],
      )!,
      precioCompra: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_compra'],
      )!,
      precioVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_venta'],
      )!,
      stockActual: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_actual'],
      )!,
      stockMinimo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_minimo'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class Producto extends DataClass implements Insertable<Producto> {
  final DateTime? deletedAt;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String nombre;
  final String? categoriaId;

  /// Unidad de venta: unidad, libra, caja, paquete…
  final String unidad;
  final int precioCompra;
  final int precioVenta;

  /// Cantidades como REAL: productos pesables (libras) admiten fracciones.
  final double stockActual;
  final double stockMinimo;
  final bool activo;
  const Producto({
    this.deletedAt,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.nombre,
    this.categoriaId,
    required this.unidad,
    required this.precioCompra,
    required this.precioVenta,
    required this.stockActual,
    required this.stockMinimo,
    required this.activo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<String>(categoriaId);
    }
    map['unidad'] = Variable<String>(unidad);
    map['precio_compra'] = Variable<int>(precioCompra);
    map['precio_venta'] = Variable<int>(precioVenta);
    map['stock_actual'] = Variable<double>(stockActual);
    map['stock_minimo'] = Variable<double>(stockMinimo);
    map['activo'] = Variable<bool>(activo);
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      nombre: Value(nombre),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      unidad: Value(unidad),
      precioCompra: Value(precioCompra),
      precioVenta: Value(precioVenta),
      stockActual: Value(stockActual),
      stockMinimo: Value(stockMinimo),
      activo: Value(activo),
    );
  }

  factory Producto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producto(
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
      categoriaId: serializer.fromJson<String?>(json['categoriaId']),
      unidad: serializer.fromJson<String>(json['unidad']),
      precioCompra: serializer.fromJson<int>(json['precioCompra']),
      precioVenta: serializer.fromJson<int>(json['precioVenta']),
      stockActual: serializer.fromJson<double>(json['stockActual']),
      stockMinimo: serializer.fromJson<double>(json['stockMinimo']),
      activo: serializer.fromJson<bool>(json['activo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'nombre': serializer.toJson<String>(nombre),
      'categoriaId': serializer.toJson<String?>(categoriaId),
      'unidad': serializer.toJson<String>(unidad),
      'precioCompra': serializer.toJson<int>(precioCompra),
      'precioVenta': serializer.toJson<int>(precioVenta),
      'stockActual': serializer.toJson<double>(stockActual),
      'stockMinimo': serializer.toJson<double>(stockMinimo),
      'activo': serializer.toJson<bool>(activo),
    };
  }

  Producto copyWith({
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    Value<String?> categoriaId = const Value.absent(),
    String? unidad,
    int? precioCompra,
    int? precioVenta,
    double? stockActual,
    double? stockMinimo,
    bool? activo,
  }) => Producto(
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    nombre: nombre ?? this.nombre,
    categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
    unidad: unidad ?? this.unidad,
    precioCompra: precioCompra ?? this.precioCompra,
    precioVenta: precioVenta ?? this.precioVenta,
    stockActual: stockActual ?? this.stockActual,
    stockMinimo: stockMinimo ?? this.stockMinimo,
    activo: activo ?? this.activo,
  );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      unidad: data.unidad.present ? data.unidad.value : this.unidad,
      precioCompra: data.precioCompra.present
          ? data.precioCompra.value
          : this.precioCompra,
      precioVenta: data.precioVenta.present
          ? data.precioVenta.value
          : this.precioVenta,
      stockActual: data.stockActual.present
          ? data.stockActual.value
          : this.stockActual,
      stockMinimo: data.stockMinimo.present
          ? data.stockMinimo.value
          : this.stockMinimo,
      activo: data.activo.present ? data.activo.value : this.activo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nombre: $nombre, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('unidad: $unidad, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('activo: $activo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deletedAt,
    id,
    createdAt,
    updatedAt,
    nombre,
    categoriaId,
    unidad,
    precioCompra,
    precioVenta,
    stockActual,
    stockMinimo,
    activo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.nombre == this.nombre &&
          other.categoriaId == this.categoriaId &&
          other.unidad == this.unidad &&
          other.precioCompra == this.precioCompra &&
          other.precioVenta == this.precioVenta &&
          other.stockActual == this.stockActual &&
          other.stockMinimo == this.stockMinimo &&
          other.activo == this.activo);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> nombre;
  final Value<String?> categoriaId;
  final Value<String> unidad;
  final Value<int> precioCompra;
  final Value<int> precioVenta;
  final Value<double> stockActual;
  final Value<double> stockMinimo;
  final Value<bool> activo;
  final Value<int> rowid;
  const ProductosCompanion({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.unidad = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.activo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductosCompanion.insert({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String nombre,
    this.categoriaId = const Value.absent(),
    this.unidad = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.activo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Producto> custom({
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? nombre,
    Expression<String>? categoriaId,
    Expression<String>? unidad,
    Expression<int>? precioCompra,
    Expression<int>? precioVenta,
    Expression<double>? stockActual,
    Expression<double>? stockMinimo,
    Expression<bool>? activo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (nombre != null) 'nombre': nombre,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (unidad != null) 'unidad': unidad,
      if (precioCompra != null) 'precio_compra': precioCompra,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (stockActual != null) 'stock_actual': stockActual,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (activo != null) 'activo': activo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductosCompanion copyWith({
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? nombre,
    Value<String?>? categoriaId,
    Value<String>? unidad,
    Value<int>? precioCompra,
    Value<int>? precioVenta,
    Value<double>? stockActual,
    Value<double>? stockMinimo,
    Value<bool>? activo,
    Value<int>? rowid,
  }) {
    return ProductosCompanion(
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      categoriaId: categoriaId ?? this.categoriaId,
      unidad: unidad ?? this.unidad,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVenta: precioVenta ?? this.precioVenta,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      activo: activo ?? this.activo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<String>(categoriaId.value);
    }
    if (unidad.present) {
      map['unidad'] = Variable<String>(unidad.value);
    }
    if (precioCompra.present) {
      map['precio_compra'] = Variable<int>(precioCompra.value);
    }
    if (precioVenta.present) {
      map['precio_venta'] = Variable<int>(precioVenta.value);
    }
    if (stockActual.present) {
      map['stock_actual'] = Variable<double>(stockActual.value);
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<double>(stockMinimo.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nombre: $nombre, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('unidad: $unidad, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('activo: $activo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistorialPreciosTable extends HistorialPrecios
    with TableInfo<$HistorialPreciosTable, HistorialPrecio> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistorialPreciosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoPrecio, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoPrecio>($HistorialPreciosTable.$convertertipo);
  static const VerificationMeta _precioAnteriorMeta = const VerificationMeta(
    'precioAnterior',
  );
  @override
  late final GeneratedColumn<int> precioAnterior = GeneratedColumn<int>(
    'precio_anterior',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioNuevoMeta = const VerificationMeta(
    'precioNuevo',
  );
  @override
  late final GeneratedColumn<int> precioNuevo = GeneratedColumn<int>(
    'precio_nuevo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    productoId,
    tipo,
    precioAnterior,
    precioNuevo,
    usuarioId,
    fecha,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'historial_precios';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistorialPrecio> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('precio_anterior')) {
      context.handle(
        _precioAnteriorMeta,
        precioAnterior.isAcceptableOrUnknown(
          data['precio_anterior']!,
          _precioAnteriorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioAnteriorMeta);
    }
    if (data.containsKey('precio_nuevo')) {
      context.handle(
        _precioNuevoMeta,
        precioNuevo.isAcceptableOrUnknown(
          data['precio_nuevo']!,
          _precioNuevoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioNuevoMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistorialPrecio map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistorialPrecio(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      tipo: $HistorialPreciosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      precioAnterior: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_anterior'],
      )!,
      precioNuevo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_nuevo'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
    );
  }

  @override
  $HistorialPreciosTable createAlias(String alias) {
    return $HistorialPreciosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoPrecio, String, String> $convertertipo =
      const EnumNameConverter<TipoPrecio>(TipoPrecio.values);
}

class HistorialPrecio extends DataClass implements Insertable<HistorialPrecio> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productoId;
  final TipoPrecio tipo;
  final int precioAnterior;
  final int precioNuevo;
  final String usuarioId;
  final DateTime fecha;
  const HistorialPrecio({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.productoId,
    required this.tipo,
    required this.precioAnterior,
    required this.precioNuevo,
    required this.usuarioId,
    required this.fecha,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['producto_id'] = Variable<String>(productoId);
    {
      map['tipo'] = Variable<String>(
        $HistorialPreciosTable.$convertertipo.toSql(tipo),
      );
    }
    map['precio_anterior'] = Variable<int>(precioAnterior);
    map['precio_nuevo'] = Variable<int>(precioNuevo);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['fecha'] = Variable<DateTime>(fecha);
    return map;
  }

  HistorialPreciosCompanion toCompanion(bool nullToAbsent) {
    return HistorialPreciosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      productoId: Value(productoId),
      tipo: Value(tipo),
      precioAnterior: Value(precioAnterior),
      precioNuevo: Value(precioNuevo),
      usuarioId: Value(usuarioId),
      fecha: Value(fecha),
    );
  }

  factory HistorialPrecio.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistorialPrecio(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      productoId: serializer.fromJson<String>(json['productoId']),
      tipo: $HistorialPreciosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      precioAnterior: serializer.fromJson<int>(json['precioAnterior']),
      precioNuevo: serializer.fromJson<int>(json['precioNuevo']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'productoId': serializer.toJson<String>(productoId),
      'tipo': serializer.toJson<String>(
        $HistorialPreciosTable.$convertertipo.toJson(tipo),
      ),
      'precioAnterior': serializer.toJson<int>(precioAnterior),
      'precioNuevo': serializer.toJson<int>(precioNuevo),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'fecha': serializer.toJson<DateTime>(fecha),
    };
  }

  HistorialPrecio copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productoId,
    TipoPrecio? tipo,
    int? precioAnterior,
    int? precioNuevo,
    String? usuarioId,
    DateTime? fecha,
  }) => HistorialPrecio(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    productoId: productoId ?? this.productoId,
    tipo: tipo ?? this.tipo,
    precioAnterior: precioAnterior ?? this.precioAnterior,
    precioNuevo: precioNuevo ?? this.precioNuevo,
    usuarioId: usuarioId ?? this.usuarioId,
    fecha: fecha ?? this.fecha,
  );
  HistorialPrecio copyWithCompanion(HistorialPreciosCompanion data) {
    return HistorialPrecio(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      precioAnterior: data.precioAnterior.present
          ? data.precioAnterior.value
          : this.precioAnterior,
      precioNuevo: data.precioNuevo.present
          ? data.precioNuevo.value
          : this.precioNuevo,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistorialPrecio(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productoId: $productoId, ')
          ..write('tipo: $tipo, ')
          ..write('precioAnterior: $precioAnterior, ')
          ..write('precioNuevo: $precioNuevo, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    productoId,
    tipo,
    precioAnterior,
    precioNuevo,
    usuarioId,
    fecha,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistorialPrecio &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.productoId == this.productoId &&
          other.tipo == this.tipo &&
          other.precioAnterior == this.precioAnterior &&
          other.precioNuevo == this.precioNuevo &&
          other.usuarioId == this.usuarioId &&
          other.fecha == this.fecha);
}

class HistorialPreciosCompanion extends UpdateCompanion<HistorialPrecio> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> productoId;
  final Value<TipoPrecio> tipo;
  final Value<int> precioAnterior;
  final Value<int> precioNuevo;
  final Value<String> usuarioId;
  final Value<DateTime> fecha;
  final Value<int> rowid;
  const HistorialPreciosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.productoId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.precioAnterior = const Value.absent(),
    this.precioNuevo = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistorialPreciosCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String productoId,
    required TipoPrecio tipo,
    required int precioAnterior,
    required int precioNuevo,
    required String usuarioId,
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productoId = Value(productoId),
       tipo = Value(tipo),
       precioAnterior = Value(precioAnterior),
       precioNuevo = Value(precioNuevo),
       usuarioId = Value(usuarioId);
  static Insertable<HistorialPrecio> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? productoId,
    Expression<String>? tipo,
    Expression<int>? precioAnterior,
    Expression<int>? precioNuevo,
    Expression<String>? usuarioId,
    Expression<DateTime>? fecha,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (productoId != null) 'producto_id': productoId,
      if (tipo != null) 'tipo': tipo,
      if (precioAnterior != null) 'precio_anterior': precioAnterior,
      if (precioNuevo != null) 'precio_nuevo': precioNuevo,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (fecha != null) 'fecha': fecha,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistorialPreciosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? productoId,
    Value<TipoPrecio>? tipo,
    Value<int>? precioAnterior,
    Value<int>? precioNuevo,
    Value<String>? usuarioId,
    Value<DateTime>? fecha,
    Value<int>? rowid,
  }) {
    return HistorialPreciosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productoId: productoId ?? this.productoId,
      tipo: tipo ?? this.tipo,
      precioAnterior: precioAnterior ?? this.precioAnterior,
      precioNuevo: precioNuevo ?? this.precioNuevo,
      usuarioId: usuarioId ?? this.usuarioId,
      fecha: fecha ?? this.fecha,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $HistorialPreciosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (precioAnterior.present) {
      map['precio_anterior'] = Variable<int>(precioAnterior.value);
    }
    if (precioNuevo.present) {
      map['precio_nuevo'] = Variable<int>(precioNuevo.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistorialPreciosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productoId: $productoId, ')
          ..write('tipo: $tipo, ')
          ..write('precioAnterior: $precioAnterior, ')
          ..write('precioNuevo: $precioNuevo, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProveedoresTable extends Proveedores
    with TableInfo<$ProveedoresTable, Proveedore> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProveedoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deletedAt,
    id,
    createdAt,
    updatedAt,
    nombre,
    telefono,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proveedores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Proveedore> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Proveedore map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Proveedore(
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
    );
  }

  @override
  $ProveedoresTable createAlias(String alias) {
    return $ProveedoresTable(attachedDatabase, alias);
  }
}

class Proveedore extends DataClass implements Insertable<Proveedore> {
  final DateTime? deletedAt;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String nombre;
  final String? telefono;
  const Proveedore({
    this.deletedAt,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.nombre,
    this.telefono,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    return map;
  }

  ProveedoresCompanion toCompanion(bool nullToAbsent) {
    return ProveedoresCompanion(
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      nombre: Value(nombre),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
    );
  }

  factory Proveedore.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Proveedore(
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      nombre: serializer.fromJson<String>(json['nombre']),
      telefono: serializer.fromJson<String?>(json['telefono']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'nombre': serializer.toJson<String>(nombre),
      'telefono': serializer.toJson<String?>(telefono),
    };
  }

  Proveedore copyWith({
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    Value<String?> telefono = const Value.absent(),
  }) => Proveedore(
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    nombre: nombre ?? this.nombre,
    telefono: telefono.present ? telefono.value : this.telefono,
  );
  Proveedore copyWithCompanion(ProveedoresCompanion data) {
    return Proveedore(
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Proveedore(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(deletedAt, id, createdAt, updatedAt, nombre, telefono);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Proveedore &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.nombre == this.nombre &&
          other.telefono == this.telefono);
}

class ProveedoresCompanion extends UpdateCompanion<Proveedore> {
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> nombre;
  final Value<String?> telefono;
  final Value<int> rowid;
  const ProveedoresCompanion({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.nombre = const Value.absent(),
    this.telefono = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProveedoresCompanion.insert({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String nombre,
    this.telefono = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : nombre = Value(nombre);
  static Insertable<Proveedore> custom({
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? nombre,
    Expression<String>? telefono,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProveedoresCompanion copyWith({
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? nombre,
    Value<String?>? telefono,
    Value<int>? rowid,
  }) {
    return ProveedoresCompanion(
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProveedoresCompanion(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('nombre: $nombre, ')
          ..write('telefono: $telefono, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovimientosInventarioTable extends MovimientosInventario
    with TableInfo<$MovimientosInventarioTable, MovimientosInventarioData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovimientosInventarioTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoMovimientoInventario, String>
  tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoMovimientoInventario>(
        $MovimientosInventarioTable.$convertertipo,
      );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockResultanteMeta = const VerificationMeta(
    'stockResultante',
  );
  @override
  late final GeneratedColumn<double> stockResultante = GeneratedColumn<double>(
    'stock_resultante',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
    'motivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenciaIdMeta = const VerificationMeta(
    'referenciaId',
  );
  @override
  late final GeneratedColumn<String> referenciaId = GeneratedColumn<String>(
    'referencia_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    productoId,
    tipo,
    cantidad,
    stockResultante,
    motivo,
    referenciaId,
    usuarioId,
    fecha,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movimientos_inventario';
  @override
  VerificationContext validateIntegrity(
    Insertable<MovimientosInventarioData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('stock_resultante')) {
      context.handle(
        _stockResultanteMeta,
        stockResultante.isAcceptableOrUnknown(
          data['stock_resultante']!,
          _stockResultanteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockResultanteMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(
        _motivoMeta,
        motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta),
      );
    }
    if (data.containsKey('referencia_id')) {
      context.handle(
        _referenciaIdMeta,
        referenciaId.isAcceptableOrUnknown(
          data['referencia_id']!,
          _referenciaIdMeta,
        ),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MovimientosInventarioData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MovimientosInventarioData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      tipo: $MovimientosInventarioTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      stockResultante: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_resultante'],
      )!,
      motivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo'],
      ),
      referenciaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia_id'],
      ),
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
    );
  }

  @override
  $MovimientosInventarioTable createAlias(String alias) {
    return $MovimientosInventarioTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoMovimientoInventario, String, String>
  $convertertipo = const EnumNameConverter<TipoMovimientoInventario>(
    TipoMovimientoInventario.values,
  );
}

class MovimientosInventarioData extends DataClass
    implements Insertable<MovimientosInventarioData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String productoId;
  final TipoMovimientoInventario tipo;
  final double cantidad;
  final double stockResultante;

  /// Obligatorio en ajustes manuales (RN-19).
  final String? motivo;

  /// Venta, compra o anulación que originó el movimiento.
  final String? referenciaId;
  final String usuarioId;
  final DateTime fecha;
  const MovimientosInventarioData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.productoId,
    required this.tipo,
    required this.cantidad,
    required this.stockResultante,
    this.motivo,
    this.referenciaId,
    required this.usuarioId,
    required this.fecha,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['producto_id'] = Variable<String>(productoId);
    {
      map['tipo'] = Variable<String>(
        $MovimientosInventarioTable.$convertertipo.toSql(tipo),
      );
    }
    map['cantidad'] = Variable<double>(cantidad);
    map['stock_resultante'] = Variable<double>(stockResultante);
    if (!nullToAbsent || motivo != null) {
      map['motivo'] = Variable<String>(motivo);
    }
    if (!nullToAbsent || referenciaId != null) {
      map['referencia_id'] = Variable<String>(referenciaId);
    }
    map['usuario_id'] = Variable<String>(usuarioId);
    map['fecha'] = Variable<DateTime>(fecha);
    return map;
  }

  MovimientosInventarioCompanion toCompanion(bool nullToAbsent) {
    return MovimientosInventarioCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      productoId: Value(productoId),
      tipo: Value(tipo),
      cantidad: Value(cantidad),
      stockResultante: Value(stockResultante),
      motivo: motivo == null && nullToAbsent
          ? const Value.absent()
          : Value(motivo),
      referenciaId: referenciaId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenciaId),
      usuarioId: Value(usuarioId),
      fecha: Value(fecha),
    );
  }

  factory MovimientosInventarioData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MovimientosInventarioData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      productoId: serializer.fromJson<String>(json['productoId']),
      tipo: $MovimientosInventarioTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      stockResultante: serializer.fromJson<double>(json['stockResultante']),
      motivo: serializer.fromJson<String?>(json['motivo']),
      referenciaId: serializer.fromJson<String?>(json['referenciaId']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'productoId': serializer.toJson<String>(productoId),
      'tipo': serializer.toJson<String>(
        $MovimientosInventarioTable.$convertertipo.toJson(tipo),
      ),
      'cantidad': serializer.toJson<double>(cantidad),
      'stockResultante': serializer.toJson<double>(stockResultante),
      'motivo': serializer.toJson<String?>(motivo),
      'referenciaId': serializer.toJson<String?>(referenciaId),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'fecha': serializer.toJson<DateTime>(fecha),
    };
  }

  MovimientosInventarioData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? productoId,
    TipoMovimientoInventario? tipo,
    double? cantidad,
    double? stockResultante,
    Value<String?> motivo = const Value.absent(),
    Value<String?> referenciaId = const Value.absent(),
    String? usuarioId,
    DateTime? fecha,
  }) => MovimientosInventarioData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    productoId: productoId ?? this.productoId,
    tipo: tipo ?? this.tipo,
    cantidad: cantidad ?? this.cantidad,
    stockResultante: stockResultante ?? this.stockResultante,
    motivo: motivo.present ? motivo.value : this.motivo,
    referenciaId: referenciaId.present ? referenciaId.value : this.referenciaId,
    usuarioId: usuarioId ?? this.usuarioId,
    fecha: fecha ?? this.fecha,
  );
  MovimientosInventarioData copyWithCompanion(
    MovimientosInventarioCompanion data,
  ) {
    return MovimientosInventarioData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      stockResultante: data.stockResultante.present
          ? data.stockResultante.value
          : this.stockResultante,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      referenciaId: data.referenciaId.present
          ? data.referenciaId.value
          : this.referenciaId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosInventarioData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productoId: $productoId, ')
          ..write('tipo: $tipo, ')
          ..write('cantidad: $cantidad, ')
          ..write('stockResultante: $stockResultante, ')
          ..write('motivo: $motivo, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    productoId,
    tipo,
    cantidad,
    stockResultante,
    motivo,
    referenciaId,
    usuarioId,
    fecha,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MovimientosInventarioData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.productoId == this.productoId &&
          other.tipo == this.tipo &&
          other.cantidad == this.cantidad &&
          other.stockResultante == this.stockResultante &&
          other.motivo == this.motivo &&
          other.referenciaId == this.referenciaId &&
          other.usuarioId == this.usuarioId &&
          other.fecha == this.fecha);
}

class MovimientosInventarioCompanion
    extends UpdateCompanion<MovimientosInventarioData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> productoId;
  final Value<TipoMovimientoInventario> tipo;
  final Value<double> cantidad;
  final Value<double> stockResultante;
  final Value<String?> motivo;
  final Value<String?> referenciaId;
  final Value<String> usuarioId;
  final Value<DateTime> fecha;
  final Value<int> rowid;
  const MovimientosInventarioCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.productoId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.stockResultante = const Value.absent(),
    this.motivo = const Value.absent(),
    this.referenciaId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MovimientosInventarioCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String productoId,
    required TipoMovimientoInventario tipo,
    required double cantidad,
    required double stockResultante,
    this.motivo = const Value.absent(),
    this.referenciaId = const Value.absent(),
    required String usuarioId,
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productoId = Value(productoId),
       tipo = Value(tipo),
       cantidad = Value(cantidad),
       stockResultante = Value(stockResultante),
       usuarioId = Value(usuarioId);
  static Insertable<MovimientosInventarioData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? productoId,
    Expression<String>? tipo,
    Expression<double>? cantidad,
    Expression<double>? stockResultante,
    Expression<String>? motivo,
    Expression<String>? referenciaId,
    Expression<String>? usuarioId,
    Expression<DateTime>? fecha,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (productoId != null) 'producto_id': productoId,
      if (tipo != null) 'tipo': tipo,
      if (cantidad != null) 'cantidad': cantidad,
      if (stockResultante != null) 'stock_resultante': stockResultante,
      if (motivo != null) 'motivo': motivo,
      if (referenciaId != null) 'referencia_id': referenciaId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (fecha != null) 'fecha': fecha,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MovimientosInventarioCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? productoId,
    Value<TipoMovimientoInventario>? tipo,
    Value<double>? cantidad,
    Value<double>? stockResultante,
    Value<String?>? motivo,
    Value<String?>? referenciaId,
    Value<String>? usuarioId,
    Value<DateTime>? fecha,
    Value<int>? rowid,
  }) {
    return MovimientosInventarioCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productoId: productoId ?? this.productoId,
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
      stockResultante: stockResultante ?? this.stockResultante,
      motivo: motivo ?? this.motivo,
      referenciaId: referenciaId ?? this.referenciaId,
      usuarioId: usuarioId ?? this.usuarioId,
      fecha: fecha ?? this.fecha,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $MovimientosInventarioTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (stockResultante.present) {
      map['stock_resultante'] = Variable<double>(stockResultante.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (referenciaId.present) {
      map['referencia_id'] = Variable<String>(referenciaId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovimientosInventarioCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('productoId: $productoId, ')
          ..write('tipo: $tipo, ')
          ..write('cantidad: $cantidad, ')
          ..write('stockResultante: $stockResultante, ')
          ..write('motivo: $motivo, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CajaSesionesTable extends CajaSesiones
    with TableInfo<$CajaSesionesTable, CajaSesione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CajaSesionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _fechaAperturaMeta = const VerificationMeta(
    'fechaApertura',
  );
  @override
  late final GeneratedColumn<DateTime> fechaApertura =
      GeneratedColumn<DateTime>(
        'fecha_apertura',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _montoAperturaMeta = const VerificationMeta(
    'montoApertura',
  );
  @override
  late final GeneratedColumn<int> montoApertura = GeneratedColumn<int>(
    'monto_apertura',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaCierreMeta = const VerificationMeta(
    'fechaCierre',
  );
  @override
  late final GeneratedColumn<DateTime> fechaCierre = GeneratedColumn<DateTime>(
    'fecha_cierre',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _montoEsperadoMeta = const VerificationMeta(
    'montoEsperado',
  );
  @override
  late final GeneratedColumn<int> montoEsperado = GeneratedColumn<int>(
    'monto_esperado',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _montoContadoMeta = const VerificationMeta(
    'montoContado',
  );
  @override
  late final GeneratedColumn<int> montoContado = GeneratedColumn<int>(
    'monto_contado',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diferenciaMeta = const VerificationMeta(
    'diferencia',
  );
  @override
  late final GeneratedColumn<int> diferencia = GeneratedColumn<int>(
    'diferencia',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _montoDejadoSiguienteMeta =
      const VerificationMeta('montoDejadoSiguiente');
  @override
  late final GeneratedColumn<int> montoDejadoSiguiente = GeneratedColumn<int>(
    'monto_dejado_siguiente',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usuarioAperturaMeta = const VerificationMeta(
    'usuarioApertura',
  );
  @override
  late final GeneratedColumn<String> usuarioApertura = GeneratedColumn<String>(
    'usuario_apertura',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _usuarioCierreMeta = const VerificationMeta(
    'usuarioCierre',
  );
  @override
  late final GeneratedColumn<String> usuarioCierre = GeneratedColumn<String>(
    'usuario_cierre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EstadoCajaSesion, String> estado =
      GeneratedColumn<String>(
        'estado',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EstadoCajaSesion>($CajaSesionesTable.$converterestado);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    fechaApertura,
    montoApertura,
    fechaCierre,
    montoEsperado,
    montoContado,
    diferencia,
    montoDejadoSiguiente,
    usuarioApertura,
    usuarioCierre,
    estado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'caja_sesiones';
  @override
  VerificationContext validateIntegrity(
    Insertable<CajaSesione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('fecha_apertura')) {
      context.handle(
        _fechaAperturaMeta,
        fechaApertura.isAcceptableOrUnknown(
          data['fecha_apertura']!,
          _fechaAperturaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaAperturaMeta);
    }
    if (data.containsKey('monto_apertura')) {
      context.handle(
        _montoAperturaMeta,
        montoApertura.isAcceptableOrUnknown(
          data['monto_apertura']!,
          _montoAperturaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoAperturaMeta);
    }
    if (data.containsKey('fecha_cierre')) {
      context.handle(
        _fechaCierreMeta,
        fechaCierre.isAcceptableOrUnknown(
          data['fecha_cierre']!,
          _fechaCierreMeta,
        ),
      );
    }
    if (data.containsKey('monto_esperado')) {
      context.handle(
        _montoEsperadoMeta,
        montoEsperado.isAcceptableOrUnknown(
          data['monto_esperado']!,
          _montoEsperadoMeta,
        ),
      );
    }
    if (data.containsKey('monto_contado')) {
      context.handle(
        _montoContadoMeta,
        montoContado.isAcceptableOrUnknown(
          data['monto_contado']!,
          _montoContadoMeta,
        ),
      );
    }
    if (data.containsKey('diferencia')) {
      context.handle(
        _diferenciaMeta,
        diferencia.isAcceptableOrUnknown(data['diferencia']!, _diferenciaMeta),
      );
    }
    if (data.containsKey('monto_dejado_siguiente')) {
      context.handle(
        _montoDejadoSiguienteMeta,
        montoDejadoSiguiente.isAcceptableOrUnknown(
          data['monto_dejado_siguiente']!,
          _montoDejadoSiguienteMeta,
        ),
      );
    }
    if (data.containsKey('usuario_apertura')) {
      context.handle(
        _usuarioAperturaMeta,
        usuarioApertura.isAcceptableOrUnknown(
          data['usuario_apertura']!,
          _usuarioAperturaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_usuarioAperturaMeta);
    }
    if (data.containsKey('usuario_cierre')) {
      context.handle(
        _usuarioCierreMeta,
        usuarioCierre.isAcceptableOrUnknown(
          data['usuario_cierre']!,
          _usuarioCierreMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CajaSesione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CajaSesione(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      fechaApertura: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_apertura'],
      )!,
      montoApertura: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_apertura'],
      )!,
      fechaCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_cierre'],
      ),
      montoEsperado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_esperado'],
      ),
      montoContado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_contado'],
      ),
      diferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diferencia'],
      ),
      montoDejadoSiguiente: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_dejado_siguiente'],
      ),
      usuarioApertura: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_apertura'],
      )!,
      usuarioCierre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_cierre'],
      ),
      estado: $CajaSesionesTable.$converterestado.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado'],
        )!,
      ),
    );
  }

  @override
  $CajaSesionesTable createAlias(String alias) {
    return $CajaSesionesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EstadoCajaSesion, String, String> $converterestado =
      const EnumNameConverter<EstadoCajaSesion>(EstadoCajaSesion.values);
}

class CajaSesione extends DataClass implements Insertable<CajaSesione> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime fechaApertura;
  final int montoApertura;
  final DateTime? fechaCierre;
  final int? montoEsperado;
  final int? montoContado;

  /// RN-08: contado − esperado (negativo = faltante).
  final int? diferencia;

  /// RN-09: precarga la apertura siguiente.
  final int? montoDejadoSiguiente;
  final String usuarioApertura;
  final String? usuarioCierre;
  final EstadoCajaSesion estado;
  const CajaSesione({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fechaApertura,
    required this.montoApertura,
    this.fechaCierre,
    this.montoEsperado,
    this.montoContado,
    this.diferencia,
    this.montoDejadoSiguiente,
    required this.usuarioApertura,
    this.usuarioCierre,
    required this.estado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['fecha_apertura'] = Variable<DateTime>(fechaApertura);
    map['monto_apertura'] = Variable<int>(montoApertura);
    if (!nullToAbsent || fechaCierre != null) {
      map['fecha_cierre'] = Variable<DateTime>(fechaCierre);
    }
    if (!nullToAbsent || montoEsperado != null) {
      map['monto_esperado'] = Variable<int>(montoEsperado);
    }
    if (!nullToAbsent || montoContado != null) {
      map['monto_contado'] = Variable<int>(montoContado);
    }
    if (!nullToAbsent || diferencia != null) {
      map['diferencia'] = Variable<int>(diferencia);
    }
    if (!nullToAbsent || montoDejadoSiguiente != null) {
      map['monto_dejado_siguiente'] = Variable<int>(montoDejadoSiguiente);
    }
    map['usuario_apertura'] = Variable<String>(usuarioApertura);
    if (!nullToAbsent || usuarioCierre != null) {
      map['usuario_cierre'] = Variable<String>(usuarioCierre);
    }
    {
      map['estado'] = Variable<String>(
        $CajaSesionesTable.$converterestado.toSql(estado),
      );
    }
    return map;
  }

  CajaSesionesCompanion toCompanion(bool nullToAbsent) {
    return CajaSesionesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      fechaApertura: Value(fechaApertura),
      montoApertura: Value(montoApertura),
      fechaCierre: fechaCierre == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaCierre),
      montoEsperado: montoEsperado == null && nullToAbsent
          ? const Value.absent()
          : Value(montoEsperado),
      montoContado: montoContado == null && nullToAbsent
          ? const Value.absent()
          : Value(montoContado),
      diferencia: diferencia == null && nullToAbsent
          ? const Value.absent()
          : Value(diferencia),
      montoDejadoSiguiente: montoDejadoSiguiente == null && nullToAbsent
          ? const Value.absent()
          : Value(montoDejadoSiguiente),
      usuarioApertura: Value(usuarioApertura),
      usuarioCierre: usuarioCierre == null && nullToAbsent
          ? const Value.absent()
          : Value(usuarioCierre),
      estado: Value(estado),
    );
  }

  factory CajaSesione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CajaSesione(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      fechaApertura: serializer.fromJson<DateTime>(json['fechaApertura']),
      montoApertura: serializer.fromJson<int>(json['montoApertura']),
      fechaCierre: serializer.fromJson<DateTime?>(json['fechaCierre']),
      montoEsperado: serializer.fromJson<int?>(json['montoEsperado']),
      montoContado: serializer.fromJson<int?>(json['montoContado']),
      diferencia: serializer.fromJson<int?>(json['diferencia']),
      montoDejadoSiguiente: serializer.fromJson<int?>(
        json['montoDejadoSiguiente'],
      ),
      usuarioApertura: serializer.fromJson<String>(json['usuarioApertura']),
      usuarioCierre: serializer.fromJson<String?>(json['usuarioCierre']),
      estado: $CajaSesionesTable.$converterestado.fromJson(
        serializer.fromJson<String>(json['estado']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'fechaApertura': serializer.toJson<DateTime>(fechaApertura),
      'montoApertura': serializer.toJson<int>(montoApertura),
      'fechaCierre': serializer.toJson<DateTime?>(fechaCierre),
      'montoEsperado': serializer.toJson<int?>(montoEsperado),
      'montoContado': serializer.toJson<int?>(montoContado),
      'diferencia': serializer.toJson<int?>(diferencia),
      'montoDejadoSiguiente': serializer.toJson<int?>(montoDejadoSiguiente),
      'usuarioApertura': serializer.toJson<String>(usuarioApertura),
      'usuarioCierre': serializer.toJson<String?>(usuarioCierre),
      'estado': serializer.toJson<String>(
        $CajaSesionesTable.$converterestado.toJson(estado),
      ),
    };
  }

  CajaSesione copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? fechaApertura,
    int? montoApertura,
    Value<DateTime?> fechaCierre = const Value.absent(),
    Value<int?> montoEsperado = const Value.absent(),
    Value<int?> montoContado = const Value.absent(),
    Value<int?> diferencia = const Value.absent(),
    Value<int?> montoDejadoSiguiente = const Value.absent(),
    String? usuarioApertura,
    Value<String?> usuarioCierre = const Value.absent(),
    EstadoCajaSesion? estado,
  }) => CajaSesione(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    fechaApertura: fechaApertura ?? this.fechaApertura,
    montoApertura: montoApertura ?? this.montoApertura,
    fechaCierre: fechaCierre.present ? fechaCierre.value : this.fechaCierre,
    montoEsperado: montoEsperado.present
        ? montoEsperado.value
        : this.montoEsperado,
    montoContado: montoContado.present ? montoContado.value : this.montoContado,
    diferencia: diferencia.present ? diferencia.value : this.diferencia,
    montoDejadoSiguiente: montoDejadoSiguiente.present
        ? montoDejadoSiguiente.value
        : this.montoDejadoSiguiente,
    usuarioApertura: usuarioApertura ?? this.usuarioApertura,
    usuarioCierre: usuarioCierre.present
        ? usuarioCierre.value
        : this.usuarioCierre,
    estado: estado ?? this.estado,
  );
  CajaSesione copyWithCompanion(CajaSesionesCompanion data) {
    return CajaSesione(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      fechaApertura: data.fechaApertura.present
          ? data.fechaApertura.value
          : this.fechaApertura,
      montoApertura: data.montoApertura.present
          ? data.montoApertura.value
          : this.montoApertura,
      fechaCierre: data.fechaCierre.present
          ? data.fechaCierre.value
          : this.fechaCierre,
      montoEsperado: data.montoEsperado.present
          ? data.montoEsperado.value
          : this.montoEsperado,
      montoContado: data.montoContado.present
          ? data.montoContado.value
          : this.montoContado,
      diferencia: data.diferencia.present
          ? data.diferencia.value
          : this.diferencia,
      montoDejadoSiguiente: data.montoDejadoSiguiente.present
          ? data.montoDejadoSiguiente.value
          : this.montoDejadoSiguiente,
      usuarioApertura: data.usuarioApertura.present
          ? data.usuarioApertura.value
          : this.usuarioApertura,
      usuarioCierre: data.usuarioCierre.present
          ? data.usuarioCierre.value
          : this.usuarioCierre,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CajaSesione(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('montoApertura: $montoApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('montoEsperado: $montoEsperado, ')
          ..write('montoContado: $montoContado, ')
          ..write('diferencia: $diferencia, ')
          ..write('montoDejadoSiguiente: $montoDejadoSiguiente, ')
          ..write('usuarioApertura: $usuarioApertura, ')
          ..write('usuarioCierre: $usuarioCierre, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    fechaApertura,
    montoApertura,
    fechaCierre,
    montoEsperado,
    montoContado,
    diferencia,
    montoDejadoSiguiente,
    usuarioApertura,
    usuarioCierre,
    estado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CajaSesione &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.fechaApertura == this.fechaApertura &&
          other.montoApertura == this.montoApertura &&
          other.fechaCierre == this.fechaCierre &&
          other.montoEsperado == this.montoEsperado &&
          other.montoContado == this.montoContado &&
          other.diferencia == this.diferencia &&
          other.montoDejadoSiguiente == this.montoDejadoSiguiente &&
          other.usuarioApertura == this.usuarioApertura &&
          other.usuarioCierre == this.usuarioCierre &&
          other.estado == this.estado);
}

class CajaSesionesCompanion extends UpdateCompanion<CajaSesione> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> fechaApertura;
  final Value<int> montoApertura;
  final Value<DateTime?> fechaCierre;
  final Value<int?> montoEsperado;
  final Value<int?> montoContado;
  final Value<int?> diferencia;
  final Value<int?> montoDejadoSiguiente;
  final Value<String> usuarioApertura;
  final Value<String?> usuarioCierre;
  final Value<EstadoCajaSesion> estado;
  final Value<int> rowid;
  const CajaSesionesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.fechaApertura = const Value.absent(),
    this.montoApertura = const Value.absent(),
    this.fechaCierre = const Value.absent(),
    this.montoEsperado = const Value.absent(),
    this.montoContado = const Value.absent(),
    this.diferencia = const Value.absent(),
    this.montoDejadoSiguiente = const Value.absent(),
    this.usuarioApertura = const Value.absent(),
    this.usuarioCierre = const Value.absent(),
    this.estado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CajaSesionesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required DateTime fechaApertura,
    required int montoApertura,
    this.fechaCierre = const Value.absent(),
    this.montoEsperado = const Value.absent(),
    this.montoContado = const Value.absent(),
    this.diferencia = const Value.absent(),
    this.montoDejadoSiguiente = const Value.absent(),
    required String usuarioApertura,
    this.usuarioCierre = const Value.absent(),
    required EstadoCajaSesion estado,
    this.rowid = const Value.absent(),
  }) : fechaApertura = Value(fechaApertura),
       montoApertura = Value(montoApertura),
       usuarioApertura = Value(usuarioApertura),
       estado = Value(estado);
  static Insertable<CajaSesione> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? fechaApertura,
    Expression<int>? montoApertura,
    Expression<DateTime>? fechaCierre,
    Expression<int>? montoEsperado,
    Expression<int>? montoContado,
    Expression<int>? diferencia,
    Expression<int>? montoDejadoSiguiente,
    Expression<String>? usuarioApertura,
    Expression<String>? usuarioCierre,
    Expression<String>? estado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (fechaApertura != null) 'fecha_apertura': fechaApertura,
      if (montoApertura != null) 'monto_apertura': montoApertura,
      if (fechaCierre != null) 'fecha_cierre': fechaCierre,
      if (montoEsperado != null) 'monto_esperado': montoEsperado,
      if (montoContado != null) 'monto_contado': montoContado,
      if (diferencia != null) 'diferencia': diferencia,
      if (montoDejadoSiguiente != null)
        'monto_dejado_siguiente': montoDejadoSiguiente,
      if (usuarioApertura != null) 'usuario_apertura': usuarioApertura,
      if (usuarioCierre != null) 'usuario_cierre': usuarioCierre,
      if (estado != null) 'estado': estado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CajaSesionesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? fechaApertura,
    Value<int>? montoApertura,
    Value<DateTime?>? fechaCierre,
    Value<int?>? montoEsperado,
    Value<int?>? montoContado,
    Value<int?>? diferencia,
    Value<int?>? montoDejadoSiguiente,
    Value<String>? usuarioApertura,
    Value<String?>? usuarioCierre,
    Value<EstadoCajaSesion>? estado,
    Value<int>? rowid,
  }) {
    return CajaSesionesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      montoApertura: montoApertura ?? this.montoApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      montoEsperado: montoEsperado ?? this.montoEsperado,
      montoContado: montoContado ?? this.montoContado,
      diferencia: diferencia ?? this.diferencia,
      montoDejadoSiguiente: montoDejadoSiguiente ?? this.montoDejadoSiguiente,
      usuarioApertura: usuarioApertura ?? this.usuarioApertura,
      usuarioCierre: usuarioCierre ?? this.usuarioCierre,
      estado: estado ?? this.estado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (fechaApertura.present) {
      map['fecha_apertura'] = Variable<DateTime>(fechaApertura.value);
    }
    if (montoApertura.present) {
      map['monto_apertura'] = Variable<int>(montoApertura.value);
    }
    if (fechaCierre.present) {
      map['fecha_cierre'] = Variable<DateTime>(fechaCierre.value);
    }
    if (montoEsperado.present) {
      map['monto_esperado'] = Variable<int>(montoEsperado.value);
    }
    if (montoContado.present) {
      map['monto_contado'] = Variable<int>(montoContado.value);
    }
    if (diferencia.present) {
      map['diferencia'] = Variable<int>(diferencia.value);
    }
    if (montoDejadoSiguiente.present) {
      map['monto_dejado_siguiente'] = Variable<int>(montoDejadoSiguiente.value);
    }
    if (usuarioApertura.present) {
      map['usuario_apertura'] = Variable<String>(usuarioApertura.value);
    }
    if (usuarioCierre.present) {
      map['usuario_cierre'] = Variable<String>(usuarioCierre.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(
        $CajaSesionesTable.$converterestado.toSql(estado.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CajaSesionesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fechaApertura: $fechaApertura, ')
          ..write('montoApertura: $montoApertura, ')
          ..write('fechaCierre: $fechaCierre, ')
          ..write('montoEsperado: $montoEsperado, ')
          ..write('montoContado: $montoContado, ')
          ..write('diferencia: $diferencia, ')
          ..write('montoDejadoSiguiente: $montoDejadoSiguiente, ')
          ..write('usuarioApertura: $usuarioApertura, ')
          ..write('usuarioCierre: $usuarioCierre, ')
          ..write('estado: $estado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CajaMovimientosTable extends CajaMovimientos
    with TableInfo<$CajaMovimientosTable, CajaMovimiento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CajaMovimientosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _cajaSesionIdMeta = const VerificationMeta(
    'cajaSesionId',
  );
  @override
  late final GeneratedColumn<String> cajaSesionId = GeneratedColumn<String>(
    'caja_sesion_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES caja_sesiones (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoCajaMovimiento, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoCajaMovimiento>($CajaMovimientosTable.$convertertipo);
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _motivoMeta = const VerificationMeta('motivo');
  @override
  late final GeneratedColumn<String> motivo = GeneratedColumn<String>(
    'motivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenciaIdMeta = const VerificationMeta(
    'referenciaId',
  );
  @override
  late final GeneratedColumn<String> referenciaId = GeneratedColumn<String>(
    'referencia_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    cajaSesionId,
    tipo,
    monto,
    motivo,
    referenciaId,
    usuarioId,
    fecha,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'caja_movimientos';
  @override
  VerificationContext validateIntegrity(
    Insertable<CajaMovimiento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('caja_sesion_id')) {
      context.handle(
        _cajaSesionIdMeta,
        cajaSesionId.isAcceptableOrUnknown(
          data['caja_sesion_id']!,
          _cajaSesionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cajaSesionIdMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('motivo')) {
      context.handle(
        _motivoMeta,
        motivo.isAcceptableOrUnknown(data['motivo']!, _motivoMeta),
      );
    }
    if (data.containsKey('referencia_id')) {
      context.handle(
        _referenciaIdMeta,
        referenciaId.isAcceptableOrUnknown(
          data['referencia_id']!,
          _referenciaIdMeta,
        ),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CajaMovimiento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CajaMovimiento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      cajaSesionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caja_sesion_id'],
      )!,
      tipo: $CajaMovimientosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      motivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}motivo'],
      ),
      referenciaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}referencia_id'],
      ),
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
    );
  }

  @override
  $CajaMovimientosTable createAlias(String alias) {
    return $CajaMovimientosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoCajaMovimiento, String, String> $convertertipo =
      const EnumNameConverter<TipoCajaMovimiento>(TipoCajaMovimiento.values);
}

class CajaMovimiento extends DataClass implements Insertable<CajaMovimiento> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String cajaSesionId;
  final TipoCajaMovimiento tipo;

  /// Con signo: entradas positivas, salidas negativas.
  final int monto;
  final String? motivo;
  final String? referenciaId;
  final String usuarioId;
  final DateTime fecha;
  const CajaMovimiento({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.cajaSesionId,
    required this.tipo,
    required this.monto,
    this.motivo,
    this.referenciaId,
    required this.usuarioId,
    required this.fecha,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['caja_sesion_id'] = Variable<String>(cajaSesionId);
    {
      map['tipo'] = Variable<String>(
        $CajaMovimientosTable.$convertertipo.toSql(tipo),
      );
    }
    map['monto'] = Variable<int>(monto);
    if (!nullToAbsent || motivo != null) {
      map['motivo'] = Variable<String>(motivo);
    }
    if (!nullToAbsent || referenciaId != null) {
      map['referencia_id'] = Variable<String>(referenciaId);
    }
    map['usuario_id'] = Variable<String>(usuarioId);
    map['fecha'] = Variable<DateTime>(fecha);
    return map;
  }

  CajaMovimientosCompanion toCompanion(bool nullToAbsent) {
    return CajaMovimientosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      cajaSesionId: Value(cajaSesionId),
      tipo: Value(tipo),
      monto: Value(monto),
      motivo: motivo == null && nullToAbsent
          ? const Value.absent()
          : Value(motivo),
      referenciaId: referenciaId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenciaId),
      usuarioId: Value(usuarioId),
      fecha: Value(fecha),
    );
  }

  factory CajaMovimiento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CajaMovimiento(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      cajaSesionId: serializer.fromJson<String>(json['cajaSesionId']),
      tipo: $CajaMovimientosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      monto: serializer.fromJson<int>(json['monto']),
      motivo: serializer.fromJson<String?>(json['motivo']),
      referenciaId: serializer.fromJson<String?>(json['referenciaId']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'cajaSesionId': serializer.toJson<String>(cajaSesionId),
      'tipo': serializer.toJson<String>(
        $CajaMovimientosTable.$convertertipo.toJson(tipo),
      ),
      'monto': serializer.toJson<int>(monto),
      'motivo': serializer.toJson<String?>(motivo),
      'referenciaId': serializer.toJson<String?>(referenciaId),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'fecha': serializer.toJson<DateTime>(fecha),
    };
  }

  CajaMovimiento copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cajaSesionId,
    TipoCajaMovimiento? tipo,
    int? monto,
    Value<String?> motivo = const Value.absent(),
    Value<String?> referenciaId = const Value.absent(),
    String? usuarioId,
    DateTime? fecha,
  }) => CajaMovimiento(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    cajaSesionId: cajaSesionId ?? this.cajaSesionId,
    tipo: tipo ?? this.tipo,
    monto: monto ?? this.monto,
    motivo: motivo.present ? motivo.value : this.motivo,
    referenciaId: referenciaId.present ? referenciaId.value : this.referenciaId,
    usuarioId: usuarioId ?? this.usuarioId,
    fecha: fecha ?? this.fecha,
  );
  CajaMovimiento copyWithCompanion(CajaMovimientosCompanion data) {
    return CajaMovimiento(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      cajaSesionId: data.cajaSesionId.present
          ? data.cajaSesionId.value
          : this.cajaSesionId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      monto: data.monto.present ? data.monto.value : this.monto,
      motivo: data.motivo.present ? data.motivo.value : this.motivo,
      referenciaId: data.referenciaId.present
          ? data.referenciaId.value
          : this.referenciaId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CajaMovimiento(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cajaSesionId: $cajaSesionId, ')
          ..write('tipo: $tipo, ')
          ..write('monto: $monto, ')
          ..write('motivo: $motivo, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    cajaSesionId,
    tipo,
    monto,
    motivo,
    referenciaId,
    usuarioId,
    fecha,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CajaMovimiento &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.cajaSesionId == this.cajaSesionId &&
          other.tipo == this.tipo &&
          other.monto == this.monto &&
          other.motivo == this.motivo &&
          other.referenciaId == this.referenciaId &&
          other.usuarioId == this.usuarioId &&
          other.fecha == this.fecha);
}

class CajaMovimientosCompanion extends UpdateCompanion<CajaMovimiento> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> cajaSesionId;
  final Value<TipoCajaMovimiento> tipo;
  final Value<int> monto;
  final Value<String?> motivo;
  final Value<String?> referenciaId;
  final Value<String> usuarioId;
  final Value<DateTime> fecha;
  final Value<int> rowid;
  const CajaMovimientosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.cajaSesionId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.monto = const Value.absent(),
    this.motivo = const Value.absent(),
    this.referenciaId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CajaMovimientosCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String cajaSesionId,
    required TipoCajaMovimiento tipo,
    required int monto,
    this.motivo = const Value.absent(),
    this.referenciaId = const Value.absent(),
    required String usuarioId,
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cajaSesionId = Value(cajaSesionId),
       tipo = Value(tipo),
       monto = Value(monto),
       usuarioId = Value(usuarioId);
  static Insertable<CajaMovimiento> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? cajaSesionId,
    Expression<String>? tipo,
    Expression<int>? monto,
    Expression<String>? motivo,
    Expression<String>? referenciaId,
    Expression<String>? usuarioId,
    Expression<DateTime>? fecha,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (cajaSesionId != null) 'caja_sesion_id': cajaSesionId,
      if (tipo != null) 'tipo': tipo,
      if (monto != null) 'monto': monto,
      if (motivo != null) 'motivo': motivo,
      if (referenciaId != null) 'referencia_id': referenciaId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (fecha != null) 'fecha': fecha,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CajaMovimientosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? cajaSesionId,
    Value<TipoCajaMovimiento>? tipo,
    Value<int>? monto,
    Value<String?>? motivo,
    Value<String?>? referenciaId,
    Value<String>? usuarioId,
    Value<DateTime>? fecha,
    Value<int>? rowid,
  }) {
    return CajaMovimientosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cajaSesionId: cajaSesionId ?? this.cajaSesionId,
      tipo: tipo ?? this.tipo,
      monto: monto ?? this.monto,
      motivo: motivo ?? this.motivo,
      referenciaId: referenciaId ?? this.referenciaId,
      usuarioId: usuarioId ?? this.usuarioId,
      fecha: fecha ?? this.fecha,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (cajaSesionId.present) {
      map['caja_sesion_id'] = Variable<String>(cajaSesionId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $CajaMovimientosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (motivo.present) {
      map['motivo'] = Variable<String>(motivo.value);
    }
    if (referenciaId.present) {
      map['referencia_id'] = Variable<String>(referenciaId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CajaMovimientosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('cajaSesionId: $cajaSesionId, ')
          ..write('tipo: $tipo, ')
          ..write('monto: $monto, ')
          ..write('motivo: $motivo, ')
          ..write('referenciaId: $referenciaId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ComprasTable extends Compras with TableInfo<$ComprasTable, Compra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _proveedorIdMeta = const VerificationMeta(
    'proveedorId',
  );
  @override
  late final GeneratedColumn<String> proveedorId = GeneratedColumn<String>(
    'proveedor_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES proveedores (id)',
    ),
  );
  static const VerificationMeta _numeroFacturaMeta = const VerificationMeta(
    'numeroFactura',
  );
  @override
  late final GeneratedColumn<String> numeroFactura = GeneratedColumn<String>(
    'numero_factura',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fotoFacturaPathMeta = const VerificationMeta(
    'fotoFacturaPath',
  );
  @override
  late final GeneratedColumn<String> fotoFacturaPath = GeneratedColumn<String>(
    'foto_factura_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagadaDeCajaMeta = const VerificationMeta(
    'pagadaDeCaja',
  );
  @override
  late final GeneratedColumn<bool> pagadaDeCaja = GeneratedColumn<bool>(
    'pagada_de_caja',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pagada_de_caja" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EstadoCompra, String> estado =
      GeneratedColumn<String>(
        'estado',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EstadoCompra>($ComprasTable.$converterestado);
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    proveedorId,
    numeroFactura,
    fotoFacturaPath,
    total,
    pagadaDeCaja,
    estado,
    usuarioId,
    fecha,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compras';
  @override
  VerificationContext validateIntegrity(
    Insertable<Compra> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('proveedor_id')) {
      context.handle(
        _proveedorIdMeta,
        proveedorId.isAcceptableOrUnknown(
          data['proveedor_id']!,
          _proveedorIdMeta,
        ),
      );
    }
    if (data.containsKey('numero_factura')) {
      context.handle(
        _numeroFacturaMeta,
        numeroFactura.isAcceptableOrUnknown(
          data['numero_factura']!,
          _numeroFacturaMeta,
        ),
      );
    }
    if (data.containsKey('foto_factura_path')) {
      context.handle(
        _fotoFacturaPathMeta,
        fotoFacturaPath.isAcceptableOrUnknown(
          data['foto_factura_path']!,
          _fotoFacturaPathMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('pagada_de_caja')) {
      context.handle(
        _pagadaDeCajaMeta,
        pagadaDeCaja.isAcceptableOrUnknown(
          data['pagada_de_caja']!,
          _pagadaDeCajaMeta,
        ),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Compra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Compra(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      proveedorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proveedor_id'],
      ),
      numeroFactura: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numero_factura'],
      ),
      fotoFacturaPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_factura_path'],
      ),
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      pagadaDeCaja: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pagada_de_caja'],
      )!,
      estado: $ComprasTable.$converterestado.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado'],
        )!,
      ),
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
    );
  }

  @override
  $ComprasTable createAlias(String alias) {
    return $ComprasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EstadoCompra, String, String> $converterestado =
      const EnumNameConverter<EstadoCompra>(EstadoCompra.values);
}

class Compra extends DataClass implements Insertable<Compra> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? proveedorId;
  final String? numeroFactura;
  final String? fotoFacturaPath;
  final int total;
  final bool pagadaDeCaja;
  final EstadoCompra estado;
  final String usuarioId;
  final DateTime fecha;
  const Compra({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.proveedorId,
    this.numeroFactura,
    this.fotoFacturaPath,
    required this.total,
    required this.pagadaDeCaja,
    required this.estado,
    required this.usuarioId,
    required this.fecha,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || proveedorId != null) {
      map['proveedor_id'] = Variable<String>(proveedorId);
    }
    if (!nullToAbsent || numeroFactura != null) {
      map['numero_factura'] = Variable<String>(numeroFactura);
    }
    if (!nullToAbsent || fotoFacturaPath != null) {
      map['foto_factura_path'] = Variable<String>(fotoFacturaPath);
    }
    map['total'] = Variable<int>(total);
    map['pagada_de_caja'] = Variable<bool>(pagadaDeCaja);
    {
      map['estado'] = Variable<String>(
        $ComprasTable.$converterestado.toSql(estado),
      );
    }
    map['usuario_id'] = Variable<String>(usuarioId);
    map['fecha'] = Variable<DateTime>(fecha);
    return map;
  }

  ComprasCompanion toCompanion(bool nullToAbsent) {
    return ComprasCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      proveedorId: proveedorId == null && nullToAbsent
          ? const Value.absent()
          : Value(proveedorId),
      numeroFactura: numeroFactura == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroFactura),
      fotoFacturaPath: fotoFacturaPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoFacturaPath),
      total: Value(total),
      pagadaDeCaja: Value(pagadaDeCaja),
      estado: Value(estado),
      usuarioId: Value(usuarioId),
      fecha: Value(fecha),
    );
  }

  factory Compra.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Compra(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      proveedorId: serializer.fromJson<String?>(json['proveedorId']),
      numeroFactura: serializer.fromJson<String?>(json['numeroFactura']),
      fotoFacturaPath: serializer.fromJson<String?>(json['fotoFacturaPath']),
      total: serializer.fromJson<int>(json['total']),
      pagadaDeCaja: serializer.fromJson<bool>(json['pagadaDeCaja']),
      estado: $ComprasTable.$converterestado.fromJson(
        serializer.fromJson<String>(json['estado']),
      ),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'proveedorId': serializer.toJson<String?>(proveedorId),
      'numeroFactura': serializer.toJson<String?>(numeroFactura),
      'fotoFacturaPath': serializer.toJson<String?>(fotoFacturaPath),
      'total': serializer.toJson<int>(total),
      'pagadaDeCaja': serializer.toJson<bool>(pagadaDeCaja),
      'estado': serializer.toJson<String>(
        $ComprasTable.$converterestado.toJson(estado),
      ),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'fecha': serializer.toJson<DateTime>(fecha),
    };
  }

  Compra copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> proveedorId = const Value.absent(),
    Value<String?> numeroFactura = const Value.absent(),
    Value<String?> fotoFacturaPath = const Value.absent(),
    int? total,
    bool? pagadaDeCaja,
    EstadoCompra? estado,
    String? usuarioId,
    DateTime? fecha,
  }) => Compra(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    proveedorId: proveedorId.present ? proveedorId.value : this.proveedorId,
    numeroFactura: numeroFactura.present
        ? numeroFactura.value
        : this.numeroFactura,
    fotoFacturaPath: fotoFacturaPath.present
        ? fotoFacturaPath.value
        : this.fotoFacturaPath,
    total: total ?? this.total,
    pagadaDeCaja: pagadaDeCaja ?? this.pagadaDeCaja,
    estado: estado ?? this.estado,
    usuarioId: usuarioId ?? this.usuarioId,
    fecha: fecha ?? this.fecha,
  );
  Compra copyWithCompanion(ComprasCompanion data) {
    return Compra(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      proveedorId: data.proveedorId.present
          ? data.proveedorId.value
          : this.proveedorId,
      numeroFactura: data.numeroFactura.present
          ? data.numeroFactura.value
          : this.numeroFactura,
      fotoFacturaPath: data.fotoFacturaPath.present
          ? data.fotoFacturaPath.value
          : this.fotoFacturaPath,
      total: data.total.present ? data.total.value : this.total,
      pagadaDeCaja: data.pagadaDeCaja.present
          ? data.pagadaDeCaja.value
          : this.pagadaDeCaja,
      estado: data.estado.present ? data.estado.value : this.estado,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Compra(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('proveedorId: $proveedorId, ')
          ..write('numeroFactura: $numeroFactura, ')
          ..write('fotoFacturaPath: $fotoFacturaPath, ')
          ..write('total: $total, ')
          ..write('pagadaDeCaja: $pagadaDeCaja, ')
          ..write('estado: $estado, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    proveedorId,
    numeroFactura,
    fotoFacturaPath,
    total,
    pagadaDeCaja,
    estado,
    usuarioId,
    fecha,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Compra &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.proveedorId == this.proveedorId &&
          other.numeroFactura == this.numeroFactura &&
          other.fotoFacturaPath == this.fotoFacturaPath &&
          other.total == this.total &&
          other.pagadaDeCaja == this.pagadaDeCaja &&
          other.estado == this.estado &&
          other.usuarioId == this.usuarioId &&
          other.fecha == this.fecha);
}

class ComprasCompanion extends UpdateCompanion<Compra> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> proveedorId;
  final Value<String?> numeroFactura;
  final Value<String?> fotoFacturaPath;
  final Value<int> total;
  final Value<bool> pagadaDeCaja;
  final Value<EstadoCompra> estado;
  final Value<String> usuarioId;
  final Value<DateTime> fecha;
  final Value<int> rowid;
  const ComprasCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.proveedorId = const Value.absent(),
    this.numeroFactura = const Value.absent(),
    this.fotoFacturaPath = const Value.absent(),
    this.total = const Value.absent(),
    this.pagadaDeCaja = const Value.absent(),
    this.estado = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ComprasCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.proveedorId = const Value.absent(),
    this.numeroFactura = const Value.absent(),
    this.fotoFacturaPath = const Value.absent(),
    required int total,
    this.pagadaDeCaja = const Value.absent(),
    required EstadoCompra estado,
    required String usuarioId,
    required DateTime fecha,
    this.rowid = const Value.absent(),
  }) : total = Value(total),
       estado = Value(estado),
       usuarioId = Value(usuarioId),
       fecha = Value(fecha);
  static Insertable<Compra> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? proveedorId,
    Expression<String>? numeroFactura,
    Expression<String>? fotoFacturaPath,
    Expression<int>? total,
    Expression<bool>? pagadaDeCaja,
    Expression<String>? estado,
    Expression<String>? usuarioId,
    Expression<DateTime>? fecha,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (proveedorId != null) 'proveedor_id': proveedorId,
      if (numeroFactura != null) 'numero_factura': numeroFactura,
      if (fotoFacturaPath != null) 'foto_factura_path': fotoFacturaPath,
      if (total != null) 'total': total,
      if (pagadaDeCaja != null) 'pagada_de_caja': pagadaDeCaja,
      if (estado != null) 'estado': estado,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (fecha != null) 'fecha': fecha,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ComprasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? proveedorId,
    Value<String?>? numeroFactura,
    Value<String?>? fotoFacturaPath,
    Value<int>? total,
    Value<bool>? pagadaDeCaja,
    Value<EstadoCompra>? estado,
    Value<String>? usuarioId,
    Value<DateTime>? fecha,
    Value<int>? rowid,
  }) {
    return ComprasCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      proveedorId: proveedorId ?? this.proveedorId,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      fotoFacturaPath: fotoFacturaPath ?? this.fotoFacturaPath,
      total: total ?? this.total,
      pagadaDeCaja: pagadaDeCaja ?? this.pagadaDeCaja,
      estado: estado ?? this.estado,
      usuarioId: usuarioId ?? this.usuarioId,
      fecha: fecha ?? this.fecha,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (proveedorId.present) {
      map['proveedor_id'] = Variable<String>(proveedorId.value);
    }
    if (numeroFactura.present) {
      map['numero_factura'] = Variable<String>(numeroFactura.value);
    }
    if (fotoFacturaPath.present) {
      map['foto_factura_path'] = Variable<String>(fotoFacturaPath.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (pagadaDeCaja.present) {
      map['pagada_de_caja'] = Variable<bool>(pagadaDeCaja.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(
        $ComprasTable.$converterestado.toSql(estado.value),
      );
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprasCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('proveedorId: $proveedorId, ')
          ..write('numeroFactura: $numeroFactura, ')
          ..write('fotoFacturaPath: $fotoFacturaPath, ')
          ..write('total: $total, ')
          ..write('pagadaDeCaja: $pagadaDeCaja, ')
          ..write('estado: $estado, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('fecha: $fecha, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompraItemsTable extends CompraItems
    with TableInfo<$CompraItemsTable, CompraItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompraItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _compraIdMeta = const VerificationMeta(
    'compraId',
  );
  @override
  late final GeneratedColumn<String> compraId = GeneratedColumn<String>(
    'compra_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES compras (id)',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id)',
    ),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoUnitarioMeta = const VerificationMeta(
    'costoUnitario',
  );
  @override
  late final GeneratedColumn<int> costoUnitario = GeneratedColumn<int>(
    'costo_unitario',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    compraId,
    productoId,
    cantidad,
    costoUnitario,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compra_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompraItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('compra_id')) {
      context.handle(
        _compraIdMeta,
        compraId.isAcceptableOrUnknown(data['compra_id']!, _compraIdMeta),
      );
    } else if (isInserting) {
      context.missing(_compraIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('costo_unitario')) {
      context.handle(
        _costoUnitarioMeta,
        costoUnitario.isAcceptableOrUnknown(
          data['costo_unitario']!,
          _costoUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costoUnitarioMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CompraItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompraItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      compraId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compra_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      costoUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}costo_unitario'],
      )!,
    );
  }

  @override
  $CompraItemsTable createAlias(String alias) {
    return $CompraItemsTable(attachedDatabase, alias);
  }
}

class CompraItem extends DataClass implements Insertable<CompraItem> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String compraId;
  final String productoId;
  final double cantidad;
  final int costoUnitario;
  const CompraItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.compraId,
    required this.productoId,
    required this.cantidad,
    required this.costoUnitario,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['compra_id'] = Variable<String>(compraId);
    map['producto_id'] = Variable<String>(productoId);
    map['cantidad'] = Variable<double>(cantidad);
    map['costo_unitario'] = Variable<int>(costoUnitario);
    return map;
  }

  CompraItemsCompanion toCompanion(bool nullToAbsent) {
    return CompraItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      compraId: Value(compraId),
      productoId: Value(productoId),
      cantidad: Value(cantidad),
      costoUnitario: Value(costoUnitario),
    );
  }

  factory CompraItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompraItem(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      compraId: serializer.fromJson<String>(json['compraId']),
      productoId: serializer.fromJson<String>(json['productoId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      costoUnitario: serializer.fromJson<int>(json['costoUnitario']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'compraId': serializer.toJson<String>(compraId),
      'productoId': serializer.toJson<String>(productoId),
      'cantidad': serializer.toJson<double>(cantidad),
      'costoUnitario': serializer.toJson<int>(costoUnitario),
    };
  }

  CompraItem copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? compraId,
    String? productoId,
    double? cantidad,
    int? costoUnitario,
  }) => CompraItem(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    compraId: compraId ?? this.compraId,
    productoId: productoId ?? this.productoId,
    cantidad: cantidad ?? this.cantidad,
    costoUnitario: costoUnitario ?? this.costoUnitario,
  );
  CompraItem copyWithCompanion(CompraItemsCompanion data) {
    return CompraItem(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      compraId: data.compraId.present ? data.compraId.value : this.compraId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompraItem(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('compraId: $compraId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    compraId,
    productoId,
    cantidad,
    costoUnitario,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompraItem &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.compraId == this.compraId &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad &&
          other.costoUnitario == this.costoUnitario);
}

class CompraItemsCompanion extends UpdateCompanion<CompraItem> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> compraId;
  final Value<String> productoId;
  final Value<double> cantidad;
  final Value<int> costoUnitario;
  final Value<int> rowid;
  const CompraItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.compraId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompraItemsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String compraId,
    required String productoId,
    required double cantidad,
    required int costoUnitario,
    this.rowid = const Value.absent(),
  }) : compraId = Value(compraId),
       productoId = Value(productoId),
       cantidad = Value(cantidad),
       costoUnitario = Value(costoUnitario);
  static Insertable<CompraItem> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? compraId,
    Expression<String>? productoId,
    Expression<double>? cantidad,
    Expression<int>? costoUnitario,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (compraId != null) 'compra_id': compraId,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompraItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? compraId,
    Value<String>? productoId,
    Value<double>? cantidad,
    Value<int>? costoUnitario,
    Value<int>? rowid,
  }) {
    return CompraItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      compraId: compraId ?? this.compraId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (compraId.present) {
      map['compra_id'] = Variable<String>(compraId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<int>(costoUnitario.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompraItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('compraId: $compraId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentasTable extends Ventas with TableInfo<$VentasTable, Venta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoVenta, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoVenta>($VentasTable.$convertertipo);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gananciaMeta = const VerificationMeta(
    'ganancia',
  );
  @override
  late final GeneratedColumn<int> ganancia = GeneratedColumn<int>(
    'ganancia',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cajaSesionIdMeta = const VerificationMeta(
    'cajaSesionId',
  );
  @override
  late final GeneratedColumn<String> cajaSesionId = GeneratedColumn<String>(
    'caja_sesion_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES caja_sesiones (id)',
    ),
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<EstadoVenta, String> estado =
      GeneratedColumn<String>(
        'estado',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EstadoVenta>($VentasTable.$converterestado);
  static const VerificationMeta _notaMeta = const VerificationMeta('nota');
  @override
  late final GeneratedColumn<String> nota = GeneratedColumn<String>(
    'nota',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    tipo,
    total,
    ganancia,
    cajaSesionId,
    usuarioId,
    estado,
    nota,
    fecha,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Venta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('ganancia')) {
      context.handle(
        _gananciaMeta,
        ganancia.isAcceptableOrUnknown(data['ganancia']!, _gananciaMeta),
      );
    } else if (isInserting) {
      context.missing(_gananciaMeta);
    }
    if (data.containsKey('caja_sesion_id')) {
      context.handle(
        _cajaSesionIdMeta,
        cajaSesionId.isAcceptableOrUnknown(
          data['caja_sesion_id']!,
          _cajaSesionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cajaSesionIdMeta);
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('nota')) {
      context.handle(
        _notaMeta,
        nota.isAcceptableOrUnknown(data['nota']!, _notaMeta),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Venta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Venta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      tipo: $VentasTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      )!,
      ganancia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ganancia'],
      )!,
      cajaSesionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caja_sesion_id'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      estado: $VentasTable.$converterestado.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado'],
        )!,
      ),
      nota: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nota'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
    );
  }

  @override
  $VentasTable createAlias(String alias) {
    return $VentasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoVenta, String, String> $convertertipo =
      const EnumNameConverter<TipoVenta>(TipoVenta.values);
  static JsonTypeConverter2<EstadoVenta, String, String> $converterestado =
      const EnumNameConverter<EstadoVenta>(EstadoVenta.values);
}

class Venta extends DataClass implements Insertable<Venta> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TipoVenta tipo;
  final int total;
  final int ganancia;
  final String cajaSesionId;
  final String usuarioId;
  final EstadoVenta estado;
  final String? nota;
  final DateTime fecha;
  const Venta({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.tipo,
    required this.total,
    required this.ganancia,
    required this.cajaSesionId,
    required this.usuarioId,
    required this.estado,
    this.nota,
    required this.fecha,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    {
      map['tipo'] = Variable<String>($VentasTable.$convertertipo.toSql(tipo));
    }
    map['total'] = Variable<int>(total);
    map['ganancia'] = Variable<int>(ganancia);
    map['caja_sesion_id'] = Variable<String>(cajaSesionId);
    map['usuario_id'] = Variable<String>(usuarioId);
    {
      map['estado'] = Variable<String>(
        $VentasTable.$converterestado.toSql(estado),
      );
    }
    if (!nullToAbsent || nota != null) {
      map['nota'] = Variable<String>(nota);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    return map;
  }

  VentasCompanion toCompanion(bool nullToAbsent) {
    return VentasCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tipo: Value(tipo),
      total: Value(total),
      ganancia: Value(ganancia),
      cajaSesionId: Value(cajaSesionId),
      usuarioId: Value(usuarioId),
      estado: Value(estado),
      nota: nota == null && nullToAbsent ? const Value.absent() : Value(nota),
      fecha: Value(fecha),
    );
  }

  factory Venta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Venta(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tipo: $VentasTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      total: serializer.fromJson<int>(json['total']),
      ganancia: serializer.fromJson<int>(json['ganancia']),
      cajaSesionId: serializer.fromJson<String>(json['cajaSesionId']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      estado: $VentasTable.$converterestado.fromJson(
        serializer.fromJson<String>(json['estado']),
      ),
      nota: serializer.fromJson<String?>(json['nota']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tipo': serializer.toJson<String>(
        $VentasTable.$convertertipo.toJson(tipo),
      ),
      'total': serializer.toJson<int>(total),
      'ganancia': serializer.toJson<int>(ganancia),
      'cajaSesionId': serializer.toJson<String>(cajaSesionId),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'estado': serializer.toJson<String>(
        $VentasTable.$converterestado.toJson(estado),
      ),
      'nota': serializer.toJson<String?>(nota),
      'fecha': serializer.toJson<DateTime>(fecha),
    };
  }

  Venta copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    TipoVenta? tipo,
    int? total,
    int? ganancia,
    String? cajaSesionId,
    String? usuarioId,
    EstadoVenta? estado,
    Value<String?> nota = const Value.absent(),
    DateTime? fecha,
  }) => Venta(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tipo: tipo ?? this.tipo,
    total: total ?? this.total,
    ganancia: ganancia ?? this.ganancia,
    cajaSesionId: cajaSesionId ?? this.cajaSesionId,
    usuarioId: usuarioId ?? this.usuarioId,
    estado: estado ?? this.estado,
    nota: nota.present ? nota.value : this.nota,
    fecha: fecha ?? this.fecha,
  );
  Venta copyWithCompanion(VentasCompanion data) {
    return Venta(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      total: data.total.present ? data.total.value : this.total,
      ganancia: data.ganancia.present ? data.ganancia.value : this.ganancia,
      cajaSesionId: data.cajaSesionId.present
          ? data.cajaSesionId.value
          : this.cajaSesionId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      estado: data.estado.present ? data.estado.value : this.estado,
      nota: data.nota.present ? data.nota.value : this.nota,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Venta(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tipo: $tipo, ')
          ..write('total: $total, ')
          ..write('ganancia: $ganancia, ')
          ..write('cajaSesionId: $cajaSesionId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('estado: $estado, ')
          ..write('nota: $nota, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    tipo,
    total,
    ganancia,
    cajaSesionId,
    usuarioId,
    estado,
    nota,
    fecha,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Venta &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tipo == this.tipo &&
          other.total == this.total &&
          other.ganancia == this.ganancia &&
          other.cajaSesionId == this.cajaSesionId &&
          other.usuarioId == this.usuarioId &&
          other.estado == this.estado &&
          other.nota == this.nota &&
          other.fecha == this.fecha);
}

class VentasCompanion extends UpdateCompanion<Venta> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<TipoVenta> tipo;
  final Value<int> total;
  final Value<int> ganancia;
  final Value<String> cajaSesionId;
  final Value<String> usuarioId;
  final Value<EstadoVenta> estado;
  final Value<String?> nota;
  final Value<DateTime> fecha;
  final Value<int> rowid;
  const VentasCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tipo = const Value.absent(),
    this.total = const Value.absent(),
    this.ganancia = const Value.absent(),
    this.cajaSesionId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.estado = const Value.absent(),
    this.nota = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentasCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required TipoVenta tipo,
    required int total,
    required int ganancia,
    required String cajaSesionId,
    required String usuarioId,
    required EstadoVenta estado,
    this.nota = const Value.absent(),
    required DateTime fecha,
    this.rowid = const Value.absent(),
  }) : tipo = Value(tipo),
       total = Value(total),
       ganancia = Value(ganancia),
       cajaSesionId = Value(cajaSesionId),
       usuarioId = Value(usuarioId),
       estado = Value(estado),
       fecha = Value(fecha);
  static Insertable<Venta> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? tipo,
    Expression<int>? total,
    Expression<int>? ganancia,
    Expression<String>? cajaSesionId,
    Expression<String>? usuarioId,
    Expression<String>? estado,
    Expression<String>? nota,
    Expression<DateTime>? fecha,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tipo != null) 'tipo': tipo,
      if (total != null) 'total': total,
      if (ganancia != null) 'ganancia': ganancia,
      if (cajaSesionId != null) 'caja_sesion_id': cajaSesionId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (estado != null) 'estado': estado,
      if (nota != null) 'nota': nota,
      if (fecha != null) 'fecha': fecha,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<TipoVenta>? tipo,
    Value<int>? total,
    Value<int>? ganancia,
    Value<String>? cajaSesionId,
    Value<String>? usuarioId,
    Value<EstadoVenta>? estado,
    Value<String?>? nota,
    Value<DateTime>? fecha,
    Value<int>? rowid,
  }) {
    return VentasCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tipo: tipo ?? this.tipo,
      total: total ?? this.total,
      ganancia: ganancia ?? this.ganancia,
      cajaSesionId: cajaSesionId ?? this.cajaSesionId,
      usuarioId: usuarioId ?? this.usuarioId,
      estado: estado ?? this.estado,
      nota: nota ?? this.nota,
      fecha: fecha ?? this.fecha,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $VentasTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (ganancia.present) {
      map['ganancia'] = Variable<int>(ganancia.value);
    }
    if (cajaSesionId.present) {
      map['caja_sesion_id'] = Variable<String>(cajaSesionId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(
        $VentasTable.$converterestado.toSql(estado.value),
      );
    }
    if (nota.present) {
      map['nota'] = Variable<String>(nota.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tipo: $tipo, ')
          ..write('total: $total, ')
          ..write('ganancia: $ganancia, ')
          ..write('cajaSesionId: $cajaSesionId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('estado: $estado, ')
          ..write('nota: $nota, ')
          ..write('fecha: $fecha, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentaItemsTable extends VentaItems
    with TableInfo<$VentaItemsTable, VentaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<String> ventaId = GeneratedColumn<String>(
    'venta_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ventas (id)',
    ),
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<String> productoId = GeneratedColumn<String>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES productos (id)',
    ),
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<double> cantidad = GeneratedColumn<double>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<int> precioUnitario = GeneratedColumn<int>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoUnitarioMeta = const VerificationMeta(
    'costoUnitario',
  );
  @override
  late final GeneratedColumn<int> costoUnitario = GeneratedColumn<int>(
    'costo_unitario',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    ventaId,
    productoId,
    cantidad,
    precioUnitario,
    costoUnitario,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'venta_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<VentaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioUnitarioMeta);
    }
    if (data.containsKey('costo_unitario')) {
      context.handle(
        _costoUnitarioMeta,
        costoUnitario.isAcceptableOrUnknown(
          data['costo_unitario']!,
          _costoUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costoUnitarioMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VentaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VentaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venta_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_id'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cantidad'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}precio_unitario'],
      )!,
      costoUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}costo_unitario'],
      )!,
    );
  }

  @override
  $VentaItemsTable createAlias(String alias) {
    return $VentaItemsTable(attachedDatabase, alias);
  }
}

class VentaItem extends DataClass implements Insertable<VentaItem> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ventaId;
  final String productoId;
  final double cantidad;
  final int precioUnitario;

  /// Costo vigente al momento de la venta (RN-05).
  final int costoUnitario;
  const VentaItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.ventaId,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    required this.costoUnitario,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['venta_id'] = Variable<String>(ventaId);
    map['producto_id'] = Variable<String>(productoId);
    map['cantidad'] = Variable<double>(cantidad);
    map['precio_unitario'] = Variable<int>(precioUnitario);
    map['costo_unitario'] = Variable<int>(costoUnitario);
    return map;
  }

  VentaItemsCompanion toCompanion(bool nullToAbsent) {
    return VentaItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      ventaId: Value(ventaId),
      productoId: Value(productoId),
      cantidad: Value(cantidad),
      precioUnitario: Value(precioUnitario),
      costoUnitario: Value(costoUnitario),
    );
  }

  factory VentaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VentaItem(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      ventaId: serializer.fromJson<String>(json['ventaId']),
      productoId: serializer.fromJson<String>(json['productoId']),
      cantidad: serializer.fromJson<double>(json['cantidad']),
      precioUnitario: serializer.fromJson<int>(json['precioUnitario']),
      costoUnitario: serializer.fromJson<int>(json['costoUnitario']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'ventaId': serializer.toJson<String>(ventaId),
      'productoId': serializer.toJson<String>(productoId),
      'cantidad': serializer.toJson<double>(cantidad),
      'precioUnitario': serializer.toJson<int>(precioUnitario),
      'costoUnitario': serializer.toJson<int>(costoUnitario),
    };
  }

  VentaItem copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ventaId,
    String? productoId,
    double? cantidad,
    int? precioUnitario,
    int? costoUnitario,
  }) => VentaItem(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    ventaId: ventaId ?? this.ventaId,
    productoId: productoId ?? this.productoId,
    cantidad: cantidad ?? this.cantidad,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    costoUnitario: costoUnitario ?? this.costoUnitario,
  );
  VentaItem copyWithCompanion(VentaItemsCompanion data) {
    return VentaItem(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VentaItem(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('costoUnitario: $costoUnitario')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    ventaId,
    productoId,
    cantidad,
    precioUnitario,
    costoUnitario,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VentaItem &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.ventaId == this.ventaId &&
          other.productoId == this.productoId &&
          other.cantidad == this.cantidad &&
          other.precioUnitario == this.precioUnitario &&
          other.costoUnitario == this.costoUnitario);
}

class VentaItemsCompanion extends UpdateCompanion<VentaItem> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> ventaId;
  final Value<String> productoId;
  final Value<double> cantidad;
  final Value<int> precioUnitario;
  final Value<int> costoUnitario;
  final Value<int> rowid;
  const VentaItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.costoUnitario = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentaItemsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String ventaId,
    required String productoId,
    required double cantidad,
    required int precioUnitario,
    required int costoUnitario,
    this.rowid = const Value.absent(),
  }) : ventaId = Value(ventaId),
       productoId = Value(productoId),
       cantidad = Value(cantidad),
       precioUnitario = Value(precioUnitario),
       costoUnitario = Value(costoUnitario);
  static Insertable<VentaItem> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? ventaId,
    Expression<String>? productoId,
    Expression<double>? cantidad,
    Expression<int>? precioUnitario,
    Expression<int>? costoUnitario,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (ventaId != null) 'venta_id': ventaId,
      if (productoId != null) 'producto_id': productoId,
      if (cantidad != null) 'cantidad': cantidad,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentaItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? ventaId,
    Value<String>? productoId,
    Value<double>? cantidad,
    Value<int>? precioUnitario,
    Value<int>? costoUnitario,
    Value<int>? rowid,
  }) {
    return VentaItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      costoUnitario: costoUnitario ?? this.costoUnitario,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<String>(ventaId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<String>(productoId.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<double>(cantidad.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<int>(precioUnitario.value);
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<int>(costoUnitario.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentaItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('cantidad: $cantidad, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('costoUnitario: $costoUnitario, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GastosTable extends Gastos with TableInfo<$GastosTable, Gasto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GastosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptoMeta = const VerificationMeta(
    'concepto',
  );
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
    'concepto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cajaSesionIdMeta = const VerificationMeta(
    'cajaSesionId',
  );
  @override
  late final GeneratedColumn<String> cajaSesionId = GeneratedColumn<String>(
    'caja_sesion_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES caja_sesiones (id)',
    ),
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    deletedAt,
    id,
    createdAt,
    updatedAt,
    categoria,
    concepto,
    fecha,
    monto,
    cajaSesionId,
    usuarioId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gastos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Gasto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('concepto')) {
      context.handle(
        _conceptoMeta,
        concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptoMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('caja_sesion_id')) {
      context.handle(
        _cajaSesionIdMeta,
        cajaSesionId.isAcceptableOrUnknown(
          data['caja_sesion_id']!,
          _cajaSesionIdMeta,
        ),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gasto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gasto(
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      concepto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concepto'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      cajaSesionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caja_sesion_id'],
      ),
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
    );
  }

  @override
  $GastosTable createAlias(String alias) {
    return $GastosTable(attachedDatabase, alias);
  }
}

class Gasto extends DataClass implements Insertable<Gasto> {
  final DateTime? deletedAt;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String categoria;
  final String concepto;
  final DateTime fecha;
  final int monto;
  final String? cajaSesionId;
  final String usuarioId;
  const Gasto({
    this.deletedAt,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.categoria,
    required this.concepto,
    required this.fecha,
    required this.monto,
    this.cajaSesionId,
    required this.usuarioId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['categoria'] = Variable<String>(categoria);
    map['concepto'] = Variable<String>(concepto);
    map['fecha'] = Variable<DateTime>(fecha);
    map['monto'] = Variable<int>(monto);
    if (!nullToAbsent || cajaSesionId != null) {
      map['caja_sesion_id'] = Variable<String>(cajaSesionId);
    }
    map['usuario_id'] = Variable<String>(usuarioId);
    return map;
  }

  GastosCompanion toCompanion(bool nullToAbsent) {
    return GastosCompanion(
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      categoria: Value(categoria),
      concepto: Value(concepto),
      fecha: Value(fecha),
      monto: Value(monto),
      cajaSesionId: cajaSesionId == null && nullToAbsent
          ? const Value.absent()
          : Value(cajaSesionId),
      usuarioId: Value(usuarioId),
    );
  }

  factory Gasto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gasto(
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      categoria: serializer.fromJson<String>(json['categoria']),
      concepto: serializer.fromJson<String>(json['concepto']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      monto: serializer.fromJson<int>(json['monto']),
      cajaSesionId: serializer.fromJson<String?>(json['cajaSesionId']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'categoria': serializer.toJson<String>(categoria),
      'concepto': serializer.toJson<String>(concepto),
      'fecha': serializer.toJson<DateTime>(fecha),
      'monto': serializer.toJson<int>(monto),
      'cajaSesionId': serializer.toJson<String?>(cajaSesionId),
      'usuarioId': serializer.toJson<String>(usuarioId),
    };
  }

  Gasto copyWith({
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoria,
    String? concepto,
    DateTime? fecha,
    int? monto,
    Value<String?> cajaSesionId = const Value.absent(),
    String? usuarioId,
  }) => Gasto(
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    categoria: categoria ?? this.categoria,
    concepto: concepto ?? this.concepto,
    fecha: fecha ?? this.fecha,
    monto: monto ?? this.monto,
    cajaSesionId: cajaSesionId.present ? cajaSesionId.value : this.cajaSesionId,
    usuarioId: usuarioId ?? this.usuarioId,
  );
  Gasto copyWithCompanion(GastosCompanion data) {
    return Gasto(
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      monto: data.monto.present ? data.monto.value : this.monto,
      cajaSesionId: data.cajaSesionId.present
          ? data.cajaSesionId.value
          : this.cajaSesionId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gasto(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('categoria: $categoria, ')
          ..write('concepto: $concepto, ')
          ..write('fecha: $fecha, ')
          ..write('monto: $monto, ')
          ..write('cajaSesionId: $cajaSesionId, ')
          ..write('usuarioId: $usuarioId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deletedAt,
    id,
    createdAt,
    updatedAt,
    categoria,
    concepto,
    fecha,
    monto,
    cajaSesionId,
    usuarioId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gasto &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.categoria == this.categoria &&
          other.concepto == this.concepto &&
          other.fecha == this.fecha &&
          other.monto == this.monto &&
          other.cajaSesionId == this.cajaSesionId &&
          other.usuarioId == this.usuarioId);
}

class GastosCompanion extends UpdateCompanion<Gasto> {
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> categoria;
  final Value<String> concepto;
  final Value<DateTime> fecha;
  final Value<int> monto;
  final Value<String?> cajaSesionId;
  final Value<String> usuarioId;
  final Value<int> rowid;
  const GastosCompanion({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.categoria = const Value.absent(),
    this.concepto = const Value.absent(),
    this.fecha = const Value.absent(),
    this.monto = const Value.absent(),
    this.cajaSesionId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GastosCompanion.insert({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String categoria,
    required String concepto,
    required DateTime fecha,
    required int monto,
    this.cajaSesionId = const Value.absent(),
    required String usuarioId,
    this.rowid = const Value.absent(),
  }) : categoria = Value(categoria),
       concepto = Value(concepto),
       fecha = Value(fecha),
       monto = Value(monto),
       usuarioId = Value(usuarioId);
  static Insertable<Gasto> custom({
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? categoria,
    Expression<String>? concepto,
    Expression<DateTime>? fecha,
    Expression<int>? monto,
    Expression<String>? cajaSesionId,
    Expression<String>? usuarioId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (categoria != null) 'categoria': categoria,
      if (concepto != null) 'concepto': concepto,
      if (fecha != null) 'fecha': fecha,
      if (monto != null) 'monto': monto,
      if (cajaSesionId != null) 'caja_sesion_id': cajaSesionId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GastosCompanion copyWith({
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? categoria,
    Value<String>? concepto,
    Value<DateTime>? fecha,
    Value<int>? monto,
    Value<String?>? cajaSesionId,
    Value<String>? usuarioId,
    Value<int>? rowid,
  }) {
    return GastosCompanion(
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoria: categoria ?? this.categoria,
      concepto: concepto ?? this.concepto,
      fecha: fecha ?? this.fecha,
      monto: monto ?? this.monto,
      cajaSesionId: cajaSesionId ?? this.cajaSesionId,
      usuarioId: usuarioId ?? this.usuarioId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (cajaSesionId.present) {
      map['caja_sesion_id'] = Variable<String>(cajaSesionId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GastosCompanion(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('categoria: $categoria, ')
          ..write('concepto: $concepto, ')
          ..write('fecha: $fecha, ')
          ..write('monto: $monto, ')
          ..write('cajaSesionId: $cajaSesionId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmpleadosTable extends Empleados
    with TableInfo<$EmpleadosTable, Empleado> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmpleadosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoEmpleado, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoEmpleado>($EmpleadosTable.$convertertipo);
  static const VerificationMeta _fotoPathMeta = const VerificationMeta(
    'fotoPath',
  );
  @override
  late final GeneratedColumn<String> fotoPath = GeneratedColumn<String>(
    'foto_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cedulaMeta = const VerificationMeta('cedula');
  @override
  late final GeneratedColumn<String> cedula = GeneratedColumn<String>(
    'cedula',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _direccionMeta = const VerificationMeta(
    'direccion',
  );
  @override
  late final GeneratedColumn<String> direccion = GeneratedColumn<String>(
    'direccion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefonoMeta = const VerificationMeta(
    'telefono',
  );
  @override
  late final GeneratedColumn<String> telefono = GeneratedColumn<String>(
    'telefono',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaIngresoMeta = const VerificationMeta(
    'fechaIngreso',
  );
  @override
  late final GeneratedColumn<DateTime> fechaIngreso = GeneratedColumn<DateTime>(
    'fecha_ingreso',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _salarioMeta = const VerificationMeta(
    'salario',
  );
  @override
  late final GeneratedColumn<int> salario = GeneratedColumn<int>(
    'salario',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frecuenciaPagoMeta = const VerificationMeta(
    'frecuenciaPago',
  );
  @override
  late final GeneratedColumn<String> frecuenciaPago = GeneratedColumn<String>(
    'frecuencia_pago',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deletedAt,
    id,
    createdAt,
    updatedAt,
    tipo,
    fotoPath,
    nombre,
    cedula,
    direccion,
    telefono,
    fechaIngreso,
    activo,
    salario,
    frecuenciaPago,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'empleados';
  @override
  VerificationContext validateIntegrity(
    Insertable<Empleado> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('foto_path')) {
      context.handle(
        _fotoPathMeta,
        fotoPath.isAcceptableOrUnknown(data['foto_path']!, _fotoPathMeta),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('cedula')) {
      context.handle(
        _cedulaMeta,
        cedula.isAcceptableOrUnknown(data['cedula']!, _cedulaMeta),
      );
    }
    if (data.containsKey('direccion')) {
      context.handle(
        _direccionMeta,
        direccion.isAcceptableOrUnknown(data['direccion']!, _direccionMeta),
      );
    }
    if (data.containsKey('telefono')) {
      context.handle(
        _telefonoMeta,
        telefono.isAcceptableOrUnknown(data['telefono']!, _telefonoMeta),
      );
    }
    if (data.containsKey('fecha_ingreso')) {
      context.handle(
        _fechaIngresoMeta,
        fechaIngreso.isAcceptableOrUnknown(
          data['fecha_ingreso']!,
          _fechaIngresoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaIngresoMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    }
    if (data.containsKey('salario')) {
      context.handle(
        _salarioMeta,
        salario.isAcceptableOrUnknown(data['salario']!, _salarioMeta),
      );
    }
    if (data.containsKey('frecuencia_pago')) {
      context.handle(
        _frecuenciaPagoMeta,
        frecuenciaPago.isAcceptableOrUnknown(
          data['frecuencia_pago']!,
          _frecuenciaPagoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Empleado map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Empleado(
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      tipo: $EmpleadosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      fotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_path'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      cedula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cedula'],
      ),
      direccion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion'],
      ),
      telefono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefono'],
      ),
      fechaIngreso: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_ingreso'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      salario: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salario'],
      ),
      frecuenciaPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frecuencia_pago'],
      ),
    );
  }

  @override
  $EmpleadosTable createAlias(String alias) {
    return $EmpleadosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoEmpleado, String, String> $convertertipo =
      const EnumNameConverter<TipoEmpleado>(TipoEmpleado.values);
}

class Empleado extends DataClass implements Insertable<Empleado> {
  final DateTime? deletedAt;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TipoEmpleado tipo;
  final String? fotoPath;
  final String nombre;
  final String? cedula;
  final String? direccion;
  final String? telefono;
  final DateTime fechaIngreso;
  final bool activo;
  final int? salario;

  /// semanal, quincenal, mensual…
  final String? frecuenciaPago;
  const Empleado({
    this.deletedAt,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.tipo,
    this.fotoPath,
    required this.nombre,
    this.cedula,
    this.direccion,
    this.telefono,
    required this.fechaIngreso,
    required this.activo,
    this.salario,
    this.frecuenciaPago,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    {
      map['tipo'] = Variable<String>(
        $EmpleadosTable.$convertertipo.toSql(tipo),
      );
    }
    if (!nullToAbsent || fotoPath != null) {
      map['foto_path'] = Variable<String>(fotoPath);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || cedula != null) {
      map['cedula'] = Variable<String>(cedula);
    }
    if (!nullToAbsent || direccion != null) {
      map['direccion'] = Variable<String>(direccion);
    }
    if (!nullToAbsent || telefono != null) {
      map['telefono'] = Variable<String>(telefono);
    }
    map['fecha_ingreso'] = Variable<DateTime>(fechaIngreso);
    map['activo'] = Variable<bool>(activo);
    if (!nullToAbsent || salario != null) {
      map['salario'] = Variable<int>(salario);
    }
    if (!nullToAbsent || frecuenciaPago != null) {
      map['frecuencia_pago'] = Variable<String>(frecuenciaPago);
    }
    return map;
  }

  EmpleadosCompanion toCompanion(bool nullToAbsent) {
    return EmpleadosCompanion(
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tipo: Value(tipo),
      fotoPath: fotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoPath),
      nombre: Value(nombre),
      cedula: cedula == null && nullToAbsent
          ? const Value.absent()
          : Value(cedula),
      direccion: direccion == null && nullToAbsent
          ? const Value.absent()
          : Value(direccion),
      telefono: telefono == null && nullToAbsent
          ? const Value.absent()
          : Value(telefono),
      fechaIngreso: Value(fechaIngreso),
      activo: Value(activo),
      salario: salario == null && nullToAbsent
          ? const Value.absent()
          : Value(salario),
      frecuenciaPago: frecuenciaPago == null && nullToAbsent
          ? const Value.absent()
          : Value(frecuenciaPago),
    );
  }

  factory Empleado.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Empleado(
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tipo: $EmpleadosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      fotoPath: serializer.fromJson<String?>(json['fotoPath']),
      nombre: serializer.fromJson<String>(json['nombre']),
      cedula: serializer.fromJson<String?>(json['cedula']),
      direccion: serializer.fromJson<String?>(json['direccion']),
      telefono: serializer.fromJson<String?>(json['telefono']),
      fechaIngreso: serializer.fromJson<DateTime>(json['fechaIngreso']),
      activo: serializer.fromJson<bool>(json['activo']),
      salario: serializer.fromJson<int?>(json['salario']),
      frecuenciaPago: serializer.fromJson<String?>(json['frecuenciaPago']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tipo': serializer.toJson<String>(
        $EmpleadosTable.$convertertipo.toJson(tipo),
      ),
      'fotoPath': serializer.toJson<String?>(fotoPath),
      'nombre': serializer.toJson<String>(nombre),
      'cedula': serializer.toJson<String?>(cedula),
      'direccion': serializer.toJson<String?>(direccion),
      'telefono': serializer.toJson<String?>(telefono),
      'fechaIngreso': serializer.toJson<DateTime>(fechaIngreso),
      'activo': serializer.toJson<bool>(activo),
      'salario': serializer.toJson<int?>(salario),
      'frecuenciaPago': serializer.toJson<String?>(frecuenciaPago),
    };
  }

  Empleado copyWith({
    Value<DateTime?> deletedAt = const Value.absent(),
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    TipoEmpleado? tipo,
    Value<String?> fotoPath = const Value.absent(),
    String? nombre,
    Value<String?> cedula = const Value.absent(),
    Value<String?> direccion = const Value.absent(),
    Value<String?> telefono = const Value.absent(),
    DateTime? fechaIngreso,
    bool? activo,
    Value<int?> salario = const Value.absent(),
    Value<String?> frecuenciaPago = const Value.absent(),
  }) => Empleado(
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tipo: tipo ?? this.tipo,
    fotoPath: fotoPath.present ? fotoPath.value : this.fotoPath,
    nombre: nombre ?? this.nombre,
    cedula: cedula.present ? cedula.value : this.cedula,
    direccion: direccion.present ? direccion.value : this.direccion,
    telefono: telefono.present ? telefono.value : this.telefono,
    fechaIngreso: fechaIngreso ?? this.fechaIngreso,
    activo: activo ?? this.activo,
    salario: salario.present ? salario.value : this.salario,
    frecuenciaPago: frecuenciaPago.present
        ? frecuenciaPago.value
        : this.frecuenciaPago,
  );
  Empleado copyWithCompanion(EmpleadosCompanion data) {
    return Empleado(
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      fotoPath: data.fotoPath.present ? data.fotoPath.value : this.fotoPath,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      cedula: data.cedula.present ? data.cedula.value : this.cedula,
      direccion: data.direccion.present ? data.direccion.value : this.direccion,
      telefono: data.telefono.present ? data.telefono.value : this.telefono,
      fechaIngreso: data.fechaIngreso.present
          ? data.fechaIngreso.value
          : this.fechaIngreso,
      activo: data.activo.present ? data.activo.value : this.activo,
      salario: data.salario.present ? data.salario.value : this.salario,
      frecuenciaPago: data.frecuenciaPago.present
          ? data.frecuenciaPago.value
          : this.frecuenciaPago,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Empleado(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tipo: $tipo, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('nombre: $nombre, ')
          ..write('cedula: $cedula, ')
          ..write('direccion: $direccion, ')
          ..write('telefono: $telefono, ')
          ..write('fechaIngreso: $fechaIngreso, ')
          ..write('activo: $activo, ')
          ..write('salario: $salario, ')
          ..write('frecuenciaPago: $frecuenciaPago')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deletedAt,
    id,
    createdAt,
    updatedAt,
    tipo,
    fotoPath,
    nombre,
    cedula,
    direccion,
    telefono,
    fechaIngreso,
    activo,
    salario,
    frecuenciaPago,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Empleado &&
          other.deletedAt == this.deletedAt &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tipo == this.tipo &&
          other.fotoPath == this.fotoPath &&
          other.nombre == this.nombre &&
          other.cedula == this.cedula &&
          other.direccion == this.direccion &&
          other.telefono == this.telefono &&
          other.fechaIngreso == this.fechaIngreso &&
          other.activo == this.activo &&
          other.salario == this.salario &&
          other.frecuenciaPago == this.frecuenciaPago);
}

class EmpleadosCompanion extends UpdateCompanion<Empleado> {
  final Value<DateTime?> deletedAt;
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<TipoEmpleado> tipo;
  final Value<String?> fotoPath;
  final Value<String> nombre;
  final Value<String?> cedula;
  final Value<String?> direccion;
  final Value<String?> telefono;
  final Value<DateTime> fechaIngreso;
  final Value<bool> activo;
  final Value<int?> salario;
  final Value<String?> frecuenciaPago;
  final Value<int> rowid;
  const EmpleadosCompanion({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tipo = const Value.absent(),
    this.fotoPath = const Value.absent(),
    this.nombre = const Value.absent(),
    this.cedula = const Value.absent(),
    this.direccion = const Value.absent(),
    this.telefono = const Value.absent(),
    this.fechaIngreso = const Value.absent(),
    this.activo = const Value.absent(),
    this.salario = const Value.absent(),
    this.frecuenciaPago = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmpleadosCompanion.insert({
    this.deletedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required TipoEmpleado tipo,
    this.fotoPath = const Value.absent(),
    required String nombre,
    this.cedula = const Value.absent(),
    this.direccion = const Value.absent(),
    this.telefono = const Value.absent(),
    required DateTime fechaIngreso,
    this.activo = const Value.absent(),
    this.salario = const Value.absent(),
    this.frecuenciaPago = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tipo = Value(tipo),
       nombre = Value(nombre),
       fechaIngreso = Value(fechaIngreso);
  static Insertable<Empleado> custom({
    Expression<DateTime>? deletedAt,
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? tipo,
    Expression<String>? fotoPath,
    Expression<String>? nombre,
    Expression<String>? cedula,
    Expression<String>? direccion,
    Expression<String>? telefono,
    Expression<DateTime>? fechaIngreso,
    Expression<bool>? activo,
    Expression<int>? salario,
    Expression<String>? frecuenciaPago,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tipo != null) 'tipo': tipo,
      if (fotoPath != null) 'foto_path': fotoPath,
      if (nombre != null) 'nombre': nombre,
      if (cedula != null) 'cedula': cedula,
      if (direccion != null) 'direccion': direccion,
      if (telefono != null) 'telefono': telefono,
      if (fechaIngreso != null) 'fecha_ingreso': fechaIngreso,
      if (activo != null) 'activo': activo,
      if (salario != null) 'salario': salario,
      if (frecuenciaPago != null) 'frecuencia_pago': frecuenciaPago,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmpleadosCompanion copyWith({
    Value<DateTime?>? deletedAt,
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<TipoEmpleado>? tipo,
    Value<String?>? fotoPath,
    Value<String>? nombre,
    Value<String?>? cedula,
    Value<String?>? direccion,
    Value<String?>? telefono,
    Value<DateTime>? fechaIngreso,
    Value<bool>? activo,
    Value<int?>? salario,
    Value<String?>? frecuenciaPago,
    Value<int>? rowid,
  }) {
    return EmpleadosCompanion(
      deletedAt: deletedAt ?? this.deletedAt,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tipo: tipo ?? this.tipo,
      fotoPath: fotoPath ?? this.fotoPath,
      nombre: nombre ?? this.nombre,
      cedula: cedula ?? this.cedula,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      activo: activo ?? this.activo,
      salario: salario ?? this.salario,
      frecuenciaPago: frecuenciaPago ?? this.frecuenciaPago,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $EmpleadosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (fotoPath.present) {
      map['foto_path'] = Variable<String>(fotoPath.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (cedula.present) {
      map['cedula'] = Variable<String>(cedula.value);
    }
    if (direccion.present) {
      map['direccion'] = Variable<String>(direccion.value);
    }
    if (telefono.present) {
      map['telefono'] = Variable<String>(telefono.value);
    }
    if (fechaIngreso.present) {
      map['fecha_ingreso'] = Variable<DateTime>(fechaIngreso.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (salario.present) {
      map['salario'] = Variable<int>(salario.value);
    }
    if (frecuenciaPago.present) {
      map['frecuencia_pago'] = Variable<String>(frecuenciaPago.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmpleadosCompanion(')
          ..write('deletedAt: $deletedAt, ')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tipo: $tipo, ')
          ..write('fotoPath: $fotoPath, ')
          ..write('nombre: $nombre, ')
          ..write('cedula: $cedula, ')
          ..write('direccion: $direccion, ')
          ..write('telefono: $telefono, ')
          ..write('fechaIngreso: $fechaIngreso, ')
          ..write('activo: $activo, ')
          ..write('salario: $salario, ')
          ..write('frecuenciaPago: $frecuenciaPago, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PagosEmpleadosTable extends PagosEmpleados
    with TableInfo<$PagosEmpleadosTable, PagosEmpleado> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagosEmpleadosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _empleadoIdMeta = const VerificationMeta(
    'empleadoId',
  );
  @override
  late final GeneratedColumn<String> empleadoId = GeneratedColumn<String>(
    'empleado_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES empleados (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoMeta = const VerificationMeta('monto');
  @override
  late final GeneratedColumn<int> monto = GeneratedColumn<int>(
    'monto',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodoMeta = const VerificationMeta(
    'periodo',
  );
  @override
  late final GeneratedColumn<String> periodo = GeneratedColumn<String>(
    'periodo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cajaSesionIdMeta = const VerificationMeta(
    'cajaSesionId',
  );
  @override
  late final GeneratedColumn<String> cajaSesionId = GeneratedColumn<String>(
    'caja_sesion_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES caja_sesiones (id)',
    ),
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    empleadoId,
    fecha,
    monto,
    periodo,
    cajaSesionId,
    usuarioId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagos_empleados';
  @override
  VerificationContext validateIntegrity(
    Insertable<PagosEmpleado> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('empleado_id')) {
      context.handle(
        _empleadoIdMeta,
        empleadoId.isAcceptableOrUnknown(data['empleado_id']!, _empleadoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_empleadoIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('monto')) {
      context.handle(
        _montoMeta,
        monto.isAcceptableOrUnknown(data['monto']!, _montoMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMeta);
    }
    if (data.containsKey('periodo')) {
      context.handle(
        _periodoMeta,
        periodo.isAcceptableOrUnknown(data['periodo']!, _periodoMeta),
      );
    }
    if (data.containsKey('caja_sesion_id')) {
      context.handle(
        _cajaSesionIdMeta,
        cajaSesionId.isAcceptableOrUnknown(
          data['caja_sesion_id']!,
          _cajaSesionIdMeta,
        ),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PagosEmpleado map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PagosEmpleado(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      empleadoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}empleado_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      monto: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto'],
      )!,
      periodo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}periodo'],
      ),
      cajaSesionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caja_sesion_id'],
      ),
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
    );
  }

  @override
  $PagosEmpleadosTable createAlias(String alias) {
    return $PagosEmpleadosTable(attachedDatabase, alias);
  }
}

class PagosEmpleado extends DataClass implements Insertable<PagosEmpleado> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String empleadoId;
  final DateTime fecha;
  final int monto;

  /// Período cubierto, ej. "1–15 junio 2026".
  final String? periodo;
  final String? cajaSesionId;
  final String usuarioId;
  const PagosEmpleado({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.empleadoId,
    required this.fecha,
    required this.monto,
    this.periodo,
    this.cajaSesionId,
    required this.usuarioId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['empleado_id'] = Variable<String>(empleadoId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['monto'] = Variable<int>(monto);
    if (!nullToAbsent || periodo != null) {
      map['periodo'] = Variable<String>(periodo);
    }
    if (!nullToAbsent || cajaSesionId != null) {
      map['caja_sesion_id'] = Variable<String>(cajaSesionId);
    }
    map['usuario_id'] = Variable<String>(usuarioId);
    return map;
  }

  PagosEmpleadosCompanion toCompanion(bool nullToAbsent) {
    return PagosEmpleadosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      empleadoId: Value(empleadoId),
      fecha: Value(fecha),
      monto: Value(monto),
      periodo: periodo == null && nullToAbsent
          ? const Value.absent()
          : Value(periodo),
      cajaSesionId: cajaSesionId == null && nullToAbsent
          ? const Value.absent()
          : Value(cajaSesionId),
      usuarioId: Value(usuarioId),
    );
  }

  factory PagosEmpleado.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PagosEmpleado(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      empleadoId: serializer.fromJson<String>(json['empleadoId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      monto: serializer.fromJson<int>(json['monto']),
      periodo: serializer.fromJson<String?>(json['periodo']),
      cajaSesionId: serializer.fromJson<String?>(json['cajaSesionId']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'empleadoId': serializer.toJson<String>(empleadoId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'monto': serializer.toJson<int>(monto),
      'periodo': serializer.toJson<String?>(periodo),
      'cajaSesionId': serializer.toJson<String?>(cajaSesionId),
      'usuarioId': serializer.toJson<String>(usuarioId),
    };
  }

  PagosEmpleado copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? empleadoId,
    DateTime? fecha,
    int? monto,
    Value<String?> periodo = const Value.absent(),
    Value<String?> cajaSesionId = const Value.absent(),
    String? usuarioId,
  }) => PagosEmpleado(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    empleadoId: empleadoId ?? this.empleadoId,
    fecha: fecha ?? this.fecha,
    monto: monto ?? this.monto,
    periodo: periodo.present ? periodo.value : this.periodo,
    cajaSesionId: cajaSesionId.present ? cajaSesionId.value : this.cajaSesionId,
    usuarioId: usuarioId ?? this.usuarioId,
  );
  PagosEmpleado copyWithCompanion(PagosEmpleadosCompanion data) {
    return PagosEmpleado(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      empleadoId: data.empleadoId.present
          ? data.empleadoId.value
          : this.empleadoId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      monto: data.monto.present ? data.monto.value : this.monto,
      periodo: data.periodo.present ? data.periodo.value : this.periodo,
      cajaSesionId: data.cajaSesionId.present
          ? data.cajaSesionId.value
          : this.cajaSesionId,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PagosEmpleado(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('empleadoId: $empleadoId, ')
          ..write('fecha: $fecha, ')
          ..write('monto: $monto, ')
          ..write('periodo: $periodo, ')
          ..write('cajaSesionId: $cajaSesionId, ')
          ..write('usuarioId: $usuarioId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    empleadoId,
    fecha,
    monto,
    periodo,
    cajaSesionId,
    usuarioId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PagosEmpleado &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.empleadoId == this.empleadoId &&
          other.fecha == this.fecha &&
          other.monto == this.monto &&
          other.periodo == this.periodo &&
          other.cajaSesionId == this.cajaSesionId &&
          other.usuarioId == this.usuarioId);
}

class PagosEmpleadosCompanion extends UpdateCompanion<PagosEmpleado> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> empleadoId;
  final Value<DateTime> fecha;
  final Value<int> monto;
  final Value<String?> periodo;
  final Value<String?> cajaSesionId;
  final Value<String> usuarioId;
  final Value<int> rowid;
  const PagosEmpleadosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.empleadoId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.monto = const Value.absent(),
    this.periodo = const Value.absent(),
    this.cajaSesionId = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PagosEmpleadosCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String empleadoId,
    required DateTime fecha,
    required int monto,
    this.periodo = const Value.absent(),
    this.cajaSesionId = const Value.absent(),
    required String usuarioId,
    this.rowid = const Value.absent(),
  }) : empleadoId = Value(empleadoId),
       fecha = Value(fecha),
       monto = Value(monto),
       usuarioId = Value(usuarioId);
  static Insertable<PagosEmpleado> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? empleadoId,
    Expression<DateTime>? fecha,
    Expression<int>? monto,
    Expression<String>? periodo,
    Expression<String>? cajaSesionId,
    Expression<String>? usuarioId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (empleadoId != null) 'empleado_id': empleadoId,
      if (fecha != null) 'fecha': fecha,
      if (monto != null) 'monto': monto,
      if (periodo != null) 'periodo': periodo,
      if (cajaSesionId != null) 'caja_sesion_id': cajaSesionId,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PagosEmpleadosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? empleadoId,
    Value<DateTime>? fecha,
    Value<int>? monto,
    Value<String?>? periodo,
    Value<String?>? cajaSesionId,
    Value<String>? usuarioId,
    Value<int>? rowid,
  }) {
    return PagosEmpleadosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      empleadoId: empleadoId ?? this.empleadoId,
      fecha: fecha ?? this.fecha,
      monto: monto ?? this.monto,
      periodo: periodo ?? this.periodo,
      cajaSesionId: cajaSesionId ?? this.cajaSesionId,
      usuarioId: usuarioId ?? this.usuarioId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (empleadoId.present) {
      map['empleado_id'] = Variable<String>(empleadoId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (monto.present) {
      map['monto'] = Variable<int>(monto.value);
    }
    if (periodo.present) {
      map['periodo'] = Variable<String>(periodo.value);
    }
    if (cajaSesionId.present) {
      map['caja_sesion_id'] = Variable<String>(cajaSesionId.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagosEmpleadosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('empleadoId: $empleadoId, ')
          ..write('fecha: $fecha, ')
          ..write('monto: $monto, ')
          ..write('periodo: $periodo, ')
          ..write('cajaSesionId: $cajaSesionId, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditoriaTable extends Auditoria
    with TableInfo<$AuditoriaTable, AuditoriaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditoriaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _usuarioIdMeta = const VerificationMeta(
    'usuarioId',
  );
  @override
  late final GeneratedColumn<String> usuarioId = GeneratedColumn<String>(
    'usuario_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES usuarios (id)',
    ),
  );
  static const VerificationMeta _accionMeta = const VerificationMeta('accion');
  @override
  late final GeneratedColumn<String> accion = GeneratedColumn<String>(
    'accion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduloMeta = const VerificationMeta('modulo');
  @override
  late final GeneratedColumn<String> modulo = GeneratedColumn<String>(
    'modulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entidadIdMeta = const VerificationMeta(
    'entidadId',
  );
  @override
  late final GeneratedColumn<String> entidadId = GeneratedColumn<String>(
    'entidad_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _datosAntesMeta = const VerificationMeta(
    'datosAntes',
  );
  @override
  late final GeneratedColumn<String> datosAntes = GeneratedColumn<String>(
    'datos_antes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _datosDespuesMeta = const VerificationMeta(
    'datosDespues',
  );
  @override
  late final GeneratedColumn<String> datosDespues = GeneratedColumn<String>(
    'datos_despues',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    usuarioId,
    accion,
    modulo,
    entidadId,
    datosAntes,
    datosDespues,
    fecha,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auditoria';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditoriaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('usuario_id')) {
      context.handle(
        _usuarioIdMeta,
        usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_usuarioIdMeta);
    }
    if (data.containsKey('accion')) {
      context.handle(
        _accionMeta,
        accion.isAcceptableOrUnknown(data['accion']!, _accionMeta),
      );
    } else if (isInserting) {
      context.missing(_accionMeta);
    }
    if (data.containsKey('modulo')) {
      context.handle(
        _moduloMeta,
        modulo.isAcceptableOrUnknown(data['modulo']!, _moduloMeta),
      );
    } else if (isInserting) {
      context.missing(_moduloMeta);
    }
    if (data.containsKey('entidad_id')) {
      context.handle(
        _entidadIdMeta,
        entidadId.isAcceptableOrUnknown(data['entidad_id']!, _entidadIdMeta),
      );
    }
    if (data.containsKey('datos_antes')) {
      context.handle(
        _datosAntesMeta,
        datosAntes.isAcceptableOrUnknown(data['datos_antes']!, _datosAntesMeta),
      );
    }
    if (data.containsKey('datos_despues')) {
      context.handle(
        _datosDespuesMeta,
        datosDespues.isAcceptableOrUnknown(
          data['datos_despues']!,
          _datosDespuesMeta,
        ),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditoriaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditoriaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      usuarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usuario_id'],
      )!,
      accion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accion'],
      )!,
      modulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modulo'],
      )!,
      entidadId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entidad_id'],
      ),
      datosAntes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datos_antes'],
      ),
      datosDespues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datos_despues'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
    );
  }

  @override
  $AuditoriaTable createAlias(String alias) {
    return $AuditoriaTable(attachedDatabase, alias);
  }
}

class AuditoriaData extends DataClass implements Insertable<AuditoriaData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String usuarioId;

  /// Acción corta, ej. 'crear', 'editar', 'anular', 'cerrar_caja'.
  final String accion;

  /// Módulo origen, ej. 'productos', 'ventas', 'caja'.
  final String modulo;
  final String? entidadId;

  /// Snapshots JSON del registro afectado (RF-AUD-01).
  final String? datosAntes;
  final String? datosDespues;
  final DateTime fecha;
  const AuditoriaData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.usuarioId,
    required this.accion,
    required this.modulo,
    this.entidadId,
    this.datosAntes,
    this.datosDespues,
    required this.fecha,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['usuario_id'] = Variable<String>(usuarioId);
    map['accion'] = Variable<String>(accion);
    map['modulo'] = Variable<String>(modulo);
    if (!nullToAbsent || entidadId != null) {
      map['entidad_id'] = Variable<String>(entidadId);
    }
    if (!nullToAbsent || datosAntes != null) {
      map['datos_antes'] = Variable<String>(datosAntes);
    }
    if (!nullToAbsent || datosDespues != null) {
      map['datos_despues'] = Variable<String>(datosDespues);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    return map;
  }

  AuditoriaCompanion toCompanion(bool nullToAbsent) {
    return AuditoriaCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      usuarioId: Value(usuarioId),
      accion: Value(accion),
      modulo: Value(modulo),
      entidadId: entidadId == null && nullToAbsent
          ? const Value.absent()
          : Value(entidadId),
      datosAntes: datosAntes == null && nullToAbsent
          ? const Value.absent()
          : Value(datosAntes),
      datosDespues: datosDespues == null && nullToAbsent
          ? const Value.absent()
          : Value(datosDespues),
      fecha: Value(fecha),
    );
  }

  factory AuditoriaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditoriaData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      usuarioId: serializer.fromJson<String>(json['usuarioId']),
      accion: serializer.fromJson<String>(json['accion']),
      modulo: serializer.fromJson<String>(json['modulo']),
      entidadId: serializer.fromJson<String?>(json['entidadId']),
      datosAntes: serializer.fromJson<String?>(json['datosAntes']),
      datosDespues: serializer.fromJson<String?>(json['datosDespues']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'usuarioId': serializer.toJson<String>(usuarioId),
      'accion': serializer.toJson<String>(accion),
      'modulo': serializer.toJson<String>(modulo),
      'entidadId': serializer.toJson<String?>(entidadId),
      'datosAntes': serializer.toJson<String?>(datosAntes),
      'datosDespues': serializer.toJson<String?>(datosDespues),
      'fecha': serializer.toJson<DateTime>(fecha),
    };
  }

  AuditoriaData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? usuarioId,
    String? accion,
    String? modulo,
    Value<String?> entidadId = const Value.absent(),
    Value<String?> datosAntes = const Value.absent(),
    Value<String?> datosDespues = const Value.absent(),
    DateTime? fecha,
  }) => AuditoriaData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    usuarioId: usuarioId ?? this.usuarioId,
    accion: accion ?? this.accion,
    modulo: modulo ?? this.modulo,
    entidadId: entidadId.present ? entidadId.value : this.entidadId,
    datosAntes: datosAntes.present ? datosAntes.value : this.datosAntes,
    datosDespues: datosDespues.present ? datosDespues.value : this.datosDespues,
    fecha: fecha ?? this.fecha,
  );
  AuditoriaData copyWithCompanion(AuditoriaCompanion data) {
    return AuditoriaData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      usuarioId: data.usuarioId.present ? data.usuarioId.value : this.usuarioId,
      accion: data.accion.present ? data.accion.value : this.accion,
      modulo: data.modulo.present ? data.modulo.value : this.modulo,
      entidadId: data.entidadId.present ? data.entidadId.value : this.entidadId,
      datosAntes: data.datosAntes.present
          ? data.datosAntes.value
          : this.datosAntes,
      datosDespues: data.datosDespues.present
          ? data.datosDespues.value
          : this.datosDespues,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditoriaData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('accion: $accion, ')
          ..write('modulo: $modulo, ')
          ..write('entidadId: $entidadId, ')
          ..write('datosAntes: $datosAntes, ')
          ..write('datosDespues: $datosDespues, ')
          ..write('fecha: $fecha')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    usuarioId,
    accion,
    modulo,
    entidadId,
    datosAntes,
    datosDespues,
    fecha,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditoriaData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.usuarioId == this.usuarioId &&
          other.accion == this.accion &&
          other.modulo == this.modulo &&
          other.entidadId == this.entidadId &&
          other.datosAntes == this.datosAntes &&
          other.datosDespues == this.datosDespues &&
          other.fecha == this.fecha);
}

class AuditoriaCompanion extends UpdateCompanion<AuditoriaData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> usuarioId;
  final Value<String> accion;
  final Value<String> modulo;
  final Value<String?> entidadId;
  final Value<String?> datosAntes;
  final Value<String?> datosDespues;
  final Value<DateTime> fecha;
  final Value<int> rowid;
  const AuditoriaCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.usuarioId = const Value.absent(),
    this.accion = const Value.absent(),
    this.modulo = const Value.absent(),
    this.entidadId = const Value.absent(),
    this.datosAntes = const Value.absent(),
    this.datosDespues = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditoriaCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String usuarioId,
    required String accion,
    required String modulo,
    this.entidadId = const Value.absent(),
    this.datosAntes = const Value.absent(),
    this.datosDespues = const Value.absent(),
    this.fecha = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : usuarioId = Value(usuarioId),
       accion = Value(accion),
       modulo = Value(modulo);
  static Insertable<AuditoriaData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? usuarioId,
    Expression<String>? accion,
    Expression<String>? modulo,
    Expression<String>? entidadId,
    Expression<String>? datosAntes,
    Expression<String>? datosDespues,
    Expression<DateTime>? fecha,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (usuarioId != null) 'usuario_id': usuarioId,
      if (accion != null) 'accion': accion,
      if (modulo != null) 'modulo': modulo,
      if (entidadId != null) 'entidad_id': entidadId,
      if (datosAntes != null) 'datos_antes': datosAntes,
      if (datosDespues != null) 'datos_despues': datosDespues,
      if (fecha != null) 'fecha': fecha,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditoriaCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? usuarioId,
    Value<String>? accion,
    Value<String>? modulo,
    Value<String?>? entidadId,
    Value<String?>? datosAntes,
    Value<String?>? datosDespues,
    Value<DateTime>? fecha,
    Value<int>? rowid,
  }) {
    return AuditoriaCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usuarioId: usuarioId ?? this.usuarioId,
      accion: accion ?? this.accion,
      modulo: modulo ?? this.modulo,
      entidadId: entidadId ?? this.entidadId,
      datosAntes: datosAntes ?? this.datosAntes,
      datosDespues: datosDespues ?? this.datosDespues,
      fecha: fecha ?? this.fecha,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (usuarioId.present) {
      map['usuario_id'] = Variable<String>(usuarioId.value);
    }
    if (accion.present) {
      map['accion'] = Variable<String>(accion.value);
    }
    if (modulo.present) {
      map['modulo'] = Variable<String>(modulo.value);
    }
    if (entidadId.present) {
      map['entidad_id'] = Variable<String>(entidadId.value);
    }
    if (datosAntes.present) {
      map['datos_antes'] = Variable<String>(datosAntes.value);
    }
    if (datosDespues.present) {
      map['datos_despues'] = Variable<String>(datosDespues.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditoriaCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('usuarioId: $usuarioId, ')
          ..write('accion: $accion, ')
          ..write('modulo: $modulo, ')
          ..write('entidadId: $entidadId, ')
          ..write('datosAntes: $datosAntes, ')
          ..write('datosDespues: $datosDespues, ')
          ..write('fecha: $fecha, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RespaldosTable extends Respaldos
    with TableInfo<$RespaldosTable, Respaldo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RespaldosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivoMeta = const VerificationMeta(
    'archivo',
  );
  @override
  late final GeneratedColumn<String> archivo = GeneratedColumn<String>(
    'archivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tamanoBytesMeta = const VerificationMeta(
    'tamanoBytes',
  );
  @override
  late final GeneratedColumn<int> tamanoBytes = GeneratedColumn<int>(
    'tamano_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TipoRespaldo, String> tipo =
      GeneratedColumn<String>(
        'tipo',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TipoRespaldo>($RespaldosTable.$convertertipo);
  static const VerificationMeta _resultadoMeta = const VerificationMeta(
    'resultado',
  );
  @override
  late final GeneratedColumn<String> resultado = GeneratedColumn<String>(
    'resultado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    fecha,
    archivo,
    tamanoBytes,
    tipo,
    resultado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'respaldos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Respaldo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('archivo')) {
      context.handle(
        _archivoMeta,
        archivo.isAcceptableOrUnknown(data['archivo']!, _archivoMeta),
      );
    } else if (isInserting) {
      context.missing(_archivoMeta);
    }
    if (data.containsKey('tamano_bytes')) {
      context.handle(
        _tamanoBytesMeta,
        tamanoBytes.isAcceptableOrUnknown(
          data['tamano_bytes']!,
          _tamanoBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tamanoBytesMeta);
    }
    if (data.containsKey('resultado')) {
      context.handle(
        _resultadoMeta,
        resultado.isAcceptableOrUnknown(data['resultado']!, _resultadoMeta),
      );
    } else if (isInserting) {
      context.missing(_resultadoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Respaldo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Respaldo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      archivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archivo'],
      )!,
      tamanoBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tamano_bytes'],
      )!,
      tipo: $RespaldosTable.$convertertipo.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tipo'],
        )!,
      ),
      resultado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resultado'],
      )!,
    );
  }

  @override
  $RespaldosTable createAlias(String alias) {
    return $RespaldosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TipoRespaldo, String, String> $convertertipo =
      const EnumNameConverter<TipoRespaldo>(TipoRespaldo.values);
}

class Respaldo extends DataClass implements Insertable<Respaldo> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime fecha;
  final String archivo;
  final int tamanoBytes;
  final TipoRespaldo tipo;

  /// 'ok' o mensaje de error.
  final String resultado;
  const Respaldo({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fecha,
    required this.archivo,
    required this.tamanoBytes,
    required this.tipo,
    required this.resultado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['fecha'] = Variable<DateTime>(fecha);
    map['archivo'] = Variable<String>(archivo);
    map['tamano_bytes'] = Variable<int>(tamanoBytes);
    {
      map['tipo'] = Variable<String>(
        $RespaldosTable.$convertertipo.toSql(tipo),
      );
    }
    map['resultado'] = Variable<String>(resultado);
    return map;
  }

  RespaldosCompanion toCompanion(bool nullToAbsent) {
    return RespaldosCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      fecha: Value(fecha),
      archivo: Value(archivo),
      tamanoBytes: Value(tamanoBytes),
      tipo: Value(tipo),
      resultado: Value(resultado),
    );
  }

  factory Respaldo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Respaldo(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      archivo: serializer.fromJson<String>(json['archivo']),
      tamanoBytes: serializer.fromJson<int>(json['tamanoBytes']),
      tipo: $RespaldosTable.$convertertipo.fromJson(
        serializer.fromJson<String>(json['tipo']),
      ),
      resultado: serializer.fromJson<String>(json['resultado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'fecha': serializer.toJson<DateTime>(fecha),
      'archivo': serializer.toJson<String>(archivo),
      'tamanoBytes': serializer.toJson<int>(tamanoBytes),
      'tipo': serializer.toJson<String>(
        $RespaldosTable.$convertertipo.toJson(tipo),
      ),
      'resultado': serializer.toJson<String>(resultado),
    };
  }

  Respaldo copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? fecha,
    String? archivo,
    int? tamanoBytes,
    TipoRespaldo? tipo,
    String? resultado,
  }) => Respaldo(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    fecha: fecha ?? this.fecha,
    archivo: archivo ?? this.archivo,
    tamanoBytes: tamanoBytes ?? this.tamanoBytes,
    tipo: tipo ?? this.tipo,
    resultado: resultado ?? this.resultado,
  );
  Respaldo copyWithCompanion(RespaldosCompanion data) {
    return Respaldo(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      archivo: data.archivo.present ? data.archivo.value : this.archivo,
      tamanoBytes: data.tamanoBytes.present
          ? data.tamanoBytes.value
          : this.tamanoBytes,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      resultado: data.resultado.present ? data.resultado.value : this.resultado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Respaldo(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fecha: $fecha, ')
          ..write('archivo: $archivo, ')
          ..write('tamanoBytes: $tamanoBytes, ')
          ..write('tipo: $tipo, ')
          ..write('resultado: $resultado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    fecha,
    archivo,
    tamanoBytes,
    tipo,
    resultado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Respaldo &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.fecha == this.fecha &&
          other.archivo == this.archivo &&
          other.tamanoBytes == this.tamanoBytes &&
          other.tipo == this.tipo &&
          other.resultado == this.resultado);
}

class RespaldosCompanion extends UpdateCompanion<Respaldo> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime> fecha;
  final Value<String> archivo;
  final Value<int> tamanoBytes;
  final Value<TipoRespaldo> tipo;
  final Value<String> resultado;
  final Value<int> rowid;
  const RespaldosCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.fecha = const Value.absent(),
    this.archivo = const Value.absent(),
    this.tamanoBytes = const Value.absent(),
    this.tipo = const Value.absent(),
    this.resultado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RespaldosCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required DateTime fecha,
    required String archivo,
    required int tamanoBytes,
    required TipoRespaldo tipo,
    required String resultado,
    this.rowid = const Value.absent(),
  }) : fecha = Value(fecha),
       archivo = Value(archivo),
       tamanoBytes = Value(tamanoBytes),
       tipo = Value(tipo),
       resultado = Value(resultado);
  static Insertable<Respaldo> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? fecha,
    Expression<String>? archivo,
    Expression<int>? tamanoBytes,
    Expression<String>? tipo,
    Expression<String>? resultado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (fecha != null) 'fecha': fecha,
      if (archivo != null) 'archivo': archivo,
      if (tamanoBytes != null) 'tamano_bytes': tamanoBytes,
      if (tipo != null) 'tipo': tipo,
      if (resultado != null) 'resultado': resultado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RespaldosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime>? fecha,
    Value<String>? archivo,
    Value<int>? tamanoBytes,
    Value<TipoRespaldo>? tipo,
    Value<String>? resultado,
    Value<int>? rowid,
  }) {
    return RespaldosCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fecha: fecha ?? this.fecha,
      archivo: archivo ?? this.archivo,
      tamanoBytes: tamanoBytes ?? this.tamanoBytes,
      tipo: tipo ?? this.tipo,
      resultado: resultado ?? this.resultado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (archivo.present) {
      map['archivo'] = Variable<String>(archivo.value);
    }
    if (tamanoBytes.present) {
      map['tamano_bytes'] = Variable<int>(tamanoBytes.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(
        $RespaldosTable.$convertertipo.toSql(tipo.value),
      );
    }
    if (resultado.present) {
      map['resultado'] = Variable<String>(resultado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RespaldosCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fecha: $fecha, ')
          ..write('archivo: $archivo, ')
          ..write('tamanoBytes: $tamanoBytes, ')
          ..write('tipo: $tipo, ')
          ..write('resultado: $resultado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: generateUuidV4,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _tablaMeta = const VerificationMeta('tabla');
  @override
  late final GeneratedColumn<String> tabla = GeneratedColumn<String>(
    'tabla',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registroIdMeta = const VerificationMeta(
    'registroId',
  );
  @override
  late final GeneratedColumn<String> registroId = GeneratedColumn<String>(
    'registro_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<OperacionSync, String> operacion =
      GeneratedColumn<String>(
        'operacion',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OperacionSync>($SyncQueueTable.$converteroperacion);
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EstadoSync, String> estado =
      GeneratedColumn<String>(
        'estado',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EstadoSync>($SyncQueueTable.$converterestado);
  static const VerificationMeta _intentosMeta = const VerificationMeta(
    'intentos',
  );
  @override
  late final GeneratedColumn<int> intentos = GeneratedColumn<int>(
    'intentos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    tabla,
    registroId,
    operacion,
    payload,
    estado,
    intentos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('tabla')) {
      context.handle(
        _tablaMeta,
        tabla.isAcceptableOrUnknown(data['tabla']!, _tablaMeta),
      );
    } else if (isInserting) {
      context.missing(_tablaMeta);
    }
    if (data.containsKey('registro_id')) {
      context.handle(
        _registroIdMeta,
        registroId.isAcceptableOrUnknown(data['registro_id']!, _registroIdMeta),
      );
    } else if (isInserting) {
      context.missing(_registroIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('intentos')) {
      context.handle(
        _intentosMeta,
        intentos.isAcceptableOrUnknown(data['intentos']!, _intentosMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      tabla: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tabla'],
      )!,
      registroId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registro_id'],
      )!,
      operacion: $SyncQueueTable.$converteroperacion.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}operacion'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      estado: $SyncQueueTable.$converterestado.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}estado'],
        )!,
      ),
      intentos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intentos'],
      )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OperacionSync, String, String> $converteroperacion =
      const EnumNameConverter<OperacionSync>(OperacionSync.values);
  static JsonTypeConverter2<EstadoSync, String, String> $converterestado =
      const EnumNameConverter<EstadoSync>(EstadoSync.values);
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Nombre de la tabla local afectada.
  final String tabla;
  final String registroId;
  final OperacionSync operacion;

  /// Snapshot JSON del registro al momento del cambio.
  final String payload;
  final EstadoSync estado;
  final int intentos;
  const SyncQueueData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.tabla,
    required this.registroId,
    required this.operacion,
    required this.payload,
    required this.estado,
    required this.intentos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['tabla'] = Variable<String>(tabla);
    map['registro_id'] = Variable<String>(registroId);
    {
      map['operacion'] = Variable<String>(
        $SyncQueueTable.$converteroperacion.toSql(operacion),
      );
    }
    map['payload'] = Variable<String>(payload);
    {
      map['estado'] = Variable<String>(
        $SyncQueueTable.$converterestado.toSql(estado),
      );
    }
    map['intentos'] = Variable<int>(intentos);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      tabla: Value(tabla),
      registroId: Value(registroId),
      operacion: Value(operacion),
      payload: Value(payload),
      estado: Value(estado),
      intentos: Value(intentos),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      tabla: serializer.fromJson<String>(json['tabla']),
      registroId: serializer.fromJson<String>(json['registroId']),
      operacion: $SyncQueueTable.$converteroperacion.fromJson(
        serializer.fromJson<String>(json['operacion']),
      ),
      payload: serializer.fromJson<String>(json['payload']),
      estado: $SyncQueueTable.$converterestado.fromJson(
        serializer.fromJson<String>(json['estado']),
      ),
      intentos: serializer.fromJson<int>(json['intentos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'tabla': serializer.toJson<String>(tabla),
      'registroId': serializer.toJson<String>(registroId),
      'operacion': serializer.toJson<String>(
        $SyncQueueTable.$converteroperacion.toJson(operacion),
      ),
      'payload': serializer.toJson<String>(payload),
      'estado': serializer.toJson<String>(
        $SyncQueueTable.$converterestado.toJson(estado),
      ),
      'intentos': serializer.toJson<int>(intentos),
    };
  }

  SyncQueueData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? tabla,
    String? registroId,
    OperacionSync? operacion,
    String? payload,
    EstadoSync? estado,
    int? intentos,
  }) => SyncQueueData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tabla: tabla ?? this.tabla,
    registroId: registroId ?? this.registroId,
    operacion: operacion ?? this.operacion,
    payload: payload ?? this.payload,
    estado: estado ?? this.estado,
    intentos: intentos ?? this.intentos,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      tabla: data.tabla.present ? data.tabla.value : this.tabla,
      registroId: data.registroId.present
          ? data.registroId.value
          : this.registroId,
      operacion: data.operacion.present ? data.operacion.value : this.operacion,
      payload: data.payload.present ? data.payload.value : this.payload,
      estado: data.estado.present ? data.estado.value : this.estado,
      intentos: data.intentos.present ? data.intentos.value : this.intentos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tabla: $tabla, ')
          ..write('registroId: $registroId, ')
          ..write('operacion: $operacion, ')
          ..write('payload: $payload, ')
          ..write('estado: $estado, ')
          ..write('intentos: $intentos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    tabla,
    registroId,
    operacion,
    payload,
    estado,
    intentos,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.tabla == this.tabla &&
          other.registroId == this.registroId &&
          other.operacion == this.operacion &&
          other.payload == this.payload &&
          other.estado == this.estado &&
          other.intentos == this.intentos);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> tabla;
  final Value<String> registroId;
  final Value<OperacionSync> operacion;
  final Value<String> payload;
  final Value<EstadoSync> estado;
  final Value<int> intentos;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.tabla = const Value.absent(),
    this.registroId = const Value.absent(),
    this.operacion = const Value.absent(),
    this.payload = const Value.absent(),
    this.estado = const Value.absent(),
    this.intentos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    required String tabla,
    required String registroId,
    required OperacionSync operacion,
    required String payload,
    required EstadoSync estado,
    this.intentos = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tabla = Value(tabla),
       registroId = Value(registroId),
       operacion = Value(operacion),
       payload = Value(payload),
       estado = Value(estado);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? tabla,
    Expression<String>? registroId,
    Expression<String>? operacion,
    Expression<String>? payload,
    Expression<String>? estado,
    Expression<int>? intentos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (tabla != null) 'tabla': tabla,
      if (registroId != null) 'registro_id': registroId,
      if (operacion != null) 'operacion': operacion,
      if (payload != null) 'payload': payload,
      if (estado != null) 'estado': estado,
      if (intentos != null) 'intentos': intentos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? tabla,
    Value<String>? registroId,
    Value<OperacionSync>? operacion,
    Value<String>? payload,
    Value<EstadoSync>? estado,
    Value<int>? intentos,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tabla: tabla ?? this.tabla,
      registroId: registroId ?? this.registroId,
      operacion: operacion ?? this.operacion,
      payload: payload ?? this.payload,
      estado: estado ?? this.estado,
      intentos: intentos ?? this.intentos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (tabla.present) {
      map['tabla'] = Variable<String>(tabla.value);
    }
    if (registroId.present) {
      map['registro_id'] = Variable<String>(registroId.value);
    }
    if (operacion.present) {
      map['operacion'] = Variable<String>(
        $SyncQueueTable.$converteroperacion.toSql(operacion.value),
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(
        $SyncQueueTable.$converterestado.toSql(estado.value),
      );
    }
    if (intentos.present) {
      map['intentos'] = Variable<int>(intentos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('tabla: $tabla, ')
          ..write('registroId: $registroId, ')
          ..write('operacion: $operacion, ')
          ..write('payload: $payload, ')
          ..write('estado: $estado, ')
          ..write('intentos: $intentos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NegociosTable negocios = $NegociosTable(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $LicenciasCacheTable licenciasCache = $LicenciasCacheTable(this);
  late final $ConfiguracionesTable configuraciones = $ConfiguracionesTable(
    this,
  );
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $HistorialPreciosTable historialPrecios = $HistorialPreciosTable(
    this,
  );
  late final $ProveedoresTable proveedores = $ProveedoresTable(this);
  late final $MovimientosInventarioTable movimientosInventario =
      $MovimientosInventarioTable(this);
  late final $CajaSesionesTable cajaSesiones = $CajaSesionesTable(this);
  late final $CajaMovimientosTable cajaMovimientos = $CajaMovimientosTable(
    this,
  );
  late final $ComprasTable compras = $ComprasTable(this);
  late final $CompraItemsTable compraItems = $CompraItemsTable(this);
  late final $VentasTable ventas = $VentasTable(this);
  late final $VentaItemsTable ventaItems = $VentaItemsTable(this);
  late final $GastosTable gastos = $GastosTable(this);
  late final $EmpleadosTable empleados = $EmpleadosTable(this);
  late final $PagosEmpleadosTable pagosEmpleados = $PagosEmpleadosTable(this);
  late final $AuditoriaTable auditoria = $AuditoriaTable(this);
  late final $RespaldosTable respaldos = $RespaldosTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final Index idxUsuariosUsername = Index(
    'idx_usuarios_username',
    'CREATE UNIQUE INDEX idx_usuarios_username ON usuarios (username)',
  );
  late final Index idxProductosNombre = Index(
    'idx_productos_nombre',
    'CREATE INDEX idx_productos_nombre ON productos (nombre)',
  );
  late final Index idxProductosCategoria = Index(
    'idx_productos_categoria',
    'CREATE INDEX idx_productos_categoria ON productos (categoria_id)',
  );
  late final Index idxHistorialPreciosProducto = Index(
    'idx_historial_precios_producto',
    'CREATE INDEX idx_historial_precios_producto ON historial_precios (producto_id)',
  );
  late final Index idxMovimientosProducto = Index(
    'idx_movimientos_producto',
    'CREATE INDEX idx_movimientos_producto ON movimientos_inventario (producto_id)',
  );
  late final Index idxMovimientosFecha = Index(
    'idx_movimientos_fecha',
    'CREATE INDEX idx_movimientos_fecha ON movimientos_inventario (fecha)',
  );
  late final Index idxCajaMovimientosSesion = Index(
    'idx_caja_movimientos_sesion',
    'CREATE INDEX idx_caja_movimientos_sesion ON caja_movimientos (caja_sesion_id)',
  );
  late final Index idxComprasFecha = Index(
    'idx_compras_fecha',
    'CREATE INDEX idx_compras_fecha ON compras (fecha)',
  );
  late final Index idxVentasFecha = Index(
    'idx_ventas_fecha',
    'CREATE INDEX idx_ventas_fecha ON ventas (fecha)',
  );
  late final Index idxVentasSesion = Index(
    'idx_ventas_sesion',
    'CREATE INDEX idx_ventas_sesion ON ventas (caja_sesion_id)',
  );
  late final Index idxGastosFecha = Index(
    'idx_gastos_fecha',
    'CREATE INDEX idx_gastos_fecha ON gastos (fecha)',
  );
  late final Index idxPagosEmpleado = Index(
    'idx_pagos_empleado',
    'CREATE INDEX idx_pagos_empleado ON pagos_empleados (empleado_id)',
  );
  late final Index idxAuditoriaFecha = Index(
    'idx_auditoria_fecha',
    'CREATE INDEX idx_auditoria_fecha ON auditoria (fecha)',
  );
  late final Index idxAuditoriaModulo = Index(
    'idx_auditoria_modulo',
    'CREATE INDEX idx_auditoria_modulo ON auditoria (modulo)',
  );
  late final Index idxSyncEstado = Index(
    'idx_sync_estado',
    'CREATE INDEX idx_sync_estado ON sync_queue (estado)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    negocios,
    usuarios,
    licenciasCache,
    configuraciones,
    categorias,
    productos,
    historialPrecios,
    proveedores,
    movimientosInventario,
    cajaSesiones,
    cajaMovimientos,
    compras,
    compraItems,
    ventas,
    ventaItems,
    gastos,
    empleados,
    pagosEmpleados,
    auditoria,
    respaldos,
    syncQueue,
    idxUsuariosUsername,
    idxProductosNombre,
    idxProductosCategoria,
    idxHistorialPreciosProducto,
    idxMovimientosProducto,
    idxMovimientosFecha,
    idxCajaMovimientosSesion,
    idxComprasFecha,
    idxVentasFecha,
    idxVentasSesion,
    idxGastosFecha,
    idxPagosEmpleado,
    idxAuditoriaFecha,
    idxAuditoriaModulo,
    idxSyncEstado,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$NegociosTableCreateCompanionBuilder =
    NegociosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String nombre,
      Value<String?> identificacion,
      Value<String?> direccion,
      Value<String?> telefono,
      Value<String?> email,
      Value<String?> logoPath,
      Value<String> moneda,
      Value<int> rowid,
    });
typedef $$NegociosTableUpdateCompanionBuilder =
    NegociosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> nombre,
      Value<String?> identificacion,
      Value<String?> direccion,
      Value<String?> telefono,
      Value<String?> email,
      Value<String?> logoPath,
      Value<String> moneda,
      Value<int> rowid,
    });

final class $$NegociosTableReferences
    extends BaseReferences<_$AppDatabase, $NegociosTable, Negocio> {
  $$NegociosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UsuariosTable, List<Usuario>> _usuariosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.usuarios,
    aliasName: $_aliasNameGenerator(db.negocios.id, db.usuarios.negocioId),
  );

  $$UsuariosTableProcessedTableManager get usuariosRefs {
    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.negocioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_usuariosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NegociosTableFilterComposer
    extends Composer<_$AppDatabase, $NegociosTable> {
  $$NegociosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identificacion => $composableBuilder(
    column: $table.identificacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> usuariosRefs(
    Expression<bool> Function($$UsuariosTableFilterComposer f) f,
  ) {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.negocioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NegociosTableOrderingComposer
    extends Composer<_$AppDatabase, $NegociosTable> {
  $$NegociosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identificacion => $composableBuilder(
    column: $table.identificacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NegociosTableAnnotationComposer
    extends Composer<_$AppDatabase, $NegociosTable> {
  $$NegociosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get identificacion => $composableBuilder(
    column: $table.identificacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get moneda =>
      $composableBuilder(column: $table.moneda, builder: (column) => column);

  Expression<T> usuariosRefs<T extends Object>(
    Expression<T> Function($$UsuariosTableAnnotationComposer a) f,
  ) {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.negocioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NegociosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NegociosTable,
          Negocio,
          $$NegociosTableFilterComposer,
          $$NegociosTableOrderingComposer,
          $$NegociosTableAnnotationComposer,
          $$NegociosTableCreateCompanionBuilder,
          $$NegociosTableUpdateCompanionBuilder,
          (Negocio, $$NegociosTableReferences),
          Negocio,
          PrefetchHooks Function({bool usuariosRefs})
        > {
  $$NegociosTableTableManager(_$AppDatabase db, $NegociosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NegociosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NegociosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NegociosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> identificacion = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NegociosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nombre: nombre,
                identificacion: identificacion,
                direccion: direccion,
                telefono: telefono,
                email: email,
                logoPath: logoPath,
                moneda: moneda,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String nombre,
                Value<String?> identificacion = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NegociosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nombre: nombre,
                identificacion: identificacion,
                direccion: direccion,
                telefono: telefono,
                email: email,
                logoPath: logoPath,
                moneda: moneda,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NegociosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({usuariosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (usuariosRefs) db.usuarios],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (usuariosRefs)
                    await $_getPrefetchedData<Negocio, $NegociosTable, Usuario>(
                      currentTable: table,
                      referencedTable: $$NegociosTableReferences
                          ._usuariosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NegociosTableReferences(db, table, p0).usuariosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.negocioId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NegociosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NegociosTable,
      Negocio,
      $$NegociosTableFilterComposer,
      $$NegociosTableOrderingComposer,
      $$NegociosTableAnnotationComposer,
      $$NegociosTableCreateCompanionBuilder,
      $$NegociosTableUpdateCompanionBuilder,
      (Negocio, $$NegociosTableReferences),
      Negocio,
      PrefetchHooks Function({bool usuariosRefs})
    >;
typedef $$UsuariosTableCreateCompanionBuilder =
    UsuariosCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String negocioId,
      required String nombre,
      required String username,
      required String passwordHash,
      required String salt,
      required RolUsuario rol,
      Value<bool> activo,
      Value<int> rowid,
    });
typedef $$UsuariosTableUpdateCompanionBuilder =
    UsuariosCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> negocioId,
      Value<String> nombre,
      Value<String> username,
      Value<String> passwordHash,
      Value<String> salt,
      Value<RolUsuario> rol,
      Value<bool> activo,
      Value<int> rowid,
    });

final class $$UsuariosTableReferences
    extends BaseReferences<_$AppDatabase, $UsuariosTable, Usuario> {
  $$UsuariosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NegociosTable _negocioIdTable(_$AppDatabase db) => db.negocios
      .createAlias($_aliasNameGenerator(db.usuarios.negocioId, db.negocios.id));

  $$NegociosTableProcessedTableManager get negocioId {
    final $_column = $_itemColumn<String>('negocio_id')!;

    final manager = $$NegociosTableTableManager(
      $_db,
      $_db.negocios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_negocioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HistorialPreciosTable, List<HistorialPrecio>>
  _historialPreciosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.historialPrecios,
    aliasName: $_aliasNameGenerator(
      db.usuarios.id,
      db.historialPrecios.usuarioId,
    ),
  );

  $$HistorialPreciosTableProcessedTableManager get historialPreciosRefs {
    final manager = $$HistorialPreciosTableTableManager(
      $_db,
      $_db.historialPrecios,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _historialPreciosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MovimientosInventarioTable,
    List<MovimientosInventarioData>
  >
  _movimientosInventarioRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.movimientosInventario,
        aliasName: $_aliasNameGenerator(
          db.usuarios.id,
          db.movimientosInventario.usuarioId,
        ),
      );

  $$MovimientosInventarioTableProcessedTableManager
  get movimientosInventarioRefs {
    final manager = $$MovimientosInventarioTableTableManager(
      $_db,
      $_db.movimientosInventario,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _movimientosInventarioRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CajaSesionesTable, List<CajaSesione>>
  _sesionesAbiertasTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cajaSesiones,
    aliasName: $_aliasNameGenerator(
      db.usuarios.id,
      db.cajaSesiones.usuarioApertura,
    ),
  );

  $$CajaSesionesTableProcessedTableManager get sesionesAbiertas {
    final manager = $$CajaSesionesTableTableManager($_db, $_db.cajaSesiones)
        .filter(
          (f) => f.usuarioApertura.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_sesionesAbiertasTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CajaSesionesTable, List<CajaSesione>>
  _sesionesCerradasTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cajaSesiones,
    aliasName: $_aliasNameGenerator(
      db.usuarios.id,
      db.cajaSesiones.usuarioCierre,
    ),
  );

  $$CajaSesionesTableProcessedTableManager get sesionesCerradas {
    final manager = $$CajaSesionesTableTableManager(
      $_db,
      $_db.cajaSesiones,
    ).filter((f) => f.usuarioCierre.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sesionesCerradasTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CajaMovimientosTable, List<CajaMovimiento>>
  _cajaMovimientosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cajaMovimientos,
    aliasName: $_aliasNameGenerator(
      db.usuarios.id,
      db.cajaMovimientos.usuarioId,
    ),
  );

  $$CajaMovimientosTableProcessedTableManager get cajaMovimientosRefs {
    final manager = $$CajaMovimientosTableTableManager(
      $_db,
      $_db.cajaMovimientos,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cajaMovimientosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ComprasTable, List<Compra>> _comprasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.compras,
    aliasName: $_aliasNameGenerator(db.usuarios.id, db.compras.usuarioId),
  );

  $$ComprasTableProcessedTableManager get comprasRefs {
    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_comprasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VentasTable, List<Venta>> _ventasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ventas,
    aliasName: $_aliasNameGenerator(db.usuarios.id, db.ventas.usuarioId),
  );

  $$VentasTableProcessedTableManager get ventasRefs {
    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ventasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GastosTable, List<Gasto>> _gastosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gastos,
    aliasName: $_aliasNameGenerator(db.usuarios.id, db.gastos.usuarioId),
  );

  $$GastosTableProcessedTableManager get gastosRefs {
    final manager = $$GastosTableTableManager(
      $_db,
      $_db.gastos,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gastosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PagosEmpleadosTable, List<PagosEmpleado>>
  _pagosEmpleadosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pagosEmpleados,
    aliasName: $_aliasNameGenerator(
      db.usuarios.id,
      db.pagosEmpleados.usuarioId,
    ),
  );

  $$PagosEmpleadosTableProcessedTableManager get pagosEmpleadosRefs {
    final manager = $$PagosEmpleadosTableTableManager(
      $_db,
      $_db.pagosEmpleados,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosEmpleadosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuditoriaTable, List<AuditoriaData>>
  _auditoriaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.auditoria,
    aliasName: $_aliasNameGenerator(db.usuarios.id, db.auditoria.usuarioId),
  );

  $$AuditoriaTableProcessedTableManager get auditoriaRefs {
    final manager = $$AuditoriaTableTableManager(
      $_db,
      $_db.auditoria,
    ).filter((f) => f.usuarioId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditoriaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsuariosTableFilterComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RolUsuario, RolUsuario, String> get rol =>
      $composableBuilder(
        column: $table.rol,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  $$NegociosTableFilterComposer get negocioId {
    final $$NegociosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.negocioId,
      referencedTable: $db.negocios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NegociosTableFilterComposer(
            $db: $db,
            $table: $db.negocios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> historialPreciosRefs(
    Expression<bool> Function($$HistorialPreciosTableFilterComposer f) f,
  ) {
    final $$HistorialPreciosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historialPrecios,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorialPreciosTableFilterComposer(
            $db: $db,
            $table: $db.historialPrecios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> movimientosInventarioRefs(
    Expression<bool> Function($$MovimientosInventarioTableFilterComposer f) f,
  ) {
    final $$MovimientosInventarioTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.movimientosInventario,
          getReferencedColumn: (t) => t.usuarioId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MovimientosInventarioTableFilterComposer(
                $db: $db,
                $table: $db.movimientosInventario,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> sesionesAbiertas(
    Expression<bool> Function($$CajaSesionesTableFilterComposer f) f,
  ) {
    final $$CajaSesionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.usuarioApertura,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableFilterComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sesionesCerradas(
    Expression<bool> Function($$CajaSesionesTableFilterComposer f) f,
  ) {
    final $$CajaSesionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.usuarioCierre,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableFilterComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cajaMovimientosRefs(
    Expression<bool> Function($$CajaMovimientosTableFilterComposer f) f,
  ) {
    final $$CajaMovimientosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cajaMovimientos,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaMovimientosTableFilterComposer(
            $db: $db,
            $table: $db.cajaMovimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> comprasRefs(
    Expression<bool> Function($$ComprasTableFilterComposer f) f,
  ) {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ventasRefs(
    Expression<bool> Function($$VentasTableFilterComposer f) f,
  ) {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gastosRefs(
    Expression<bool> Function($$GastosTableFilterComposer f) f,
  ) {
    final $$GastosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableFilterComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pagosEmpleadosRefs(
    Expression<bool> Function($$PagosEmpleadosTableFilterComposer f) f,
  ) {
    final $$PagosEmpleadosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagosEmpleados,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosEmpleadosTableFilterComposer(
            $db: $db,
            $table: $db.pagosEmpleados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditoriaRefs(
    Expression<bool> Function($$AuditoriaTableFilterComposer f) f,
  ) {
    final $$AuditoriaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditoria,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditoriaTableFilterComposer(
            $db: $db,
            $table: $db.auditoria,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  $$NegociosTableOrderingComposer get negocioId {
    final $$NegociosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.negocioId,
      referencedTable: $db.negocios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NegociosTableOrderingComposer(
            $db: $db,
            $table: $db.negocios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RolUsuario, String> get rol =>
      $composableBuilder(column: $table.rol, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  $$NegociosTableAnnotationComposer get negocioId {
    final $$NegociosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.negocioId,
      referencedTable: $db.negocios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NegociosTableAnnotationComposer(
            $db: $db,
            $table: $db.negocios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> historialPreciosRefs<T extends Object>(
    Expression<T> Function($$HistorialPreciosTableAnnotationComposer a) f,
  ) {
    final $$HistorialPreciosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historialPrecios,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorialPreciosTableAnnotationComposer(
            $db: $db,
            $table: $db.historialPrecios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> movimientosInventarioRefs<T extends Object>(
    Expression<T> Function($$MovimientosInventarioTableAnnotationComposer a) f,
  ) {
    final $$MovimientosInventarioTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.movimientosInventario,
          getReferencedColumn: (t) => t.usuarioId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MovimientosInventarioTableAnnotationComposer(
                $db: $db,
                $table: $db.movimientosInventario,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> sesionesAbiertas<T extends Object>(
    Expression<T> Function($$CajaSesionesTableAnnotationComposer a) f,
  ) {
    final $$CajaSesionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.usuarioApertura,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableAnnotationComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sesionesCerradas<T extends Object>(
    Expression<T> Function($$CajaSesionesTableAnnotationComposer a) f,
  ) {
    final $$CajaSesionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.usuarioCierre,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableAnnotationComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cajaMovimientosRefs<T extends Object>(
    Expression<T> Function($$CajaMovimientosTableAnnotationComposer a) f,
  ) {
    final $$CajaMovimientosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cajaMovimientos,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaMovimientosTableAnnotationComposer(
            $db: $db,
            $table: $db.cajaMovimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> comprasRefs<T extends Object>(
    Expression<T> Function($$ComprasTableAnnotationComposer a) f,
  ) {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ventasRefs<T extends Object>(
    Expression<T> Function($$VentasTableAnnotationComposer a) f,
  ) {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gastosRefs<T extends Object>(
    Expression<T> Function($$GastosTableAnnotationComposer a) f,
  ) {
    final $$GastosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableAnnotationComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pagosEmpleadosRefs<T extends Object>(
    Expression<T> Function($$PagosEmpleadosTableAnnotationComposer a) f,
  ) {
    final $$PagosEmpleadosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagosEmpleados,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosEmpleadosTableAnnotationComposer(
            $db: $db,
            $table: $db.pagosEmpleados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auditoriaRefs<T extends Object>(
    Expression<T> Function($$AuditoriaTableAnnotationComposer a) f,
  ) {
    final $$AuditoriaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditoria,
      getReferencedColumn: (t) => t.usuarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditoriaTableAnnotationComposer(
            $db: $db,
            $table: $db.auditoria,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsuariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsuariosTable,
          Usuario,
          $$UsuariosTableFilterComposer,
          $$UsuariosTableOrderingComposer,
          $$UsuariosTableAnnotationComposer,
          $$UsuariosTableCreateCompanionBuilder,
          $$UsuariosTableUpdateCompanionBuilder,
          (Usuario, $$UsuariosTableReferences),
          Usuario,
          PrefetchHooks Function({
            bool negocioId,
            bool historialPreciosRefs,
            bool movimientosInventarioRefs,
            bool sesionesAbiertas,
            bool sesionesCerradas,
            bool cajaMovimientosRefs,
            bool comprasRefs,
            bool ventasRefs,
            bool gastosRefs,
            bool pagosEmpleadosRefs,
            bool auditoriaRefs,
          })
        > {
  $$UsuariosTableTableManager(_$AppDatabase db, $UsuariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> negocioId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> salt = const Value.absent(),
                Value<RolUsuario> rol = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsuariosCompanion(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                negocioId: negocioId,
                nombre: nombre,
                username: username,
                passwordHash: passwordHash,
                salt: salt,
                rol: rol,
                activo: activo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String negocioId,
                required String nombre,
                required String username,
                required String passwordHash,
                required String salt,
                required RolUsuario rol,
                Value<bool> activo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsuariosCompanion.insert(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                negocioId: negocioId,
                nombre: nombre,
                username: username,
                passwordHash: passwordHash,
                salt: salt,
                rol: rol,
                activo: activo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UsuariosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                negocioId = false,
                historialPreciosRefs = false,
                movimientosInventarioRefs = false,
                sesionesAbiertas = false,
                sesionesCerradas = false,
                cajaMovimientosRefs = false,
                comprasRefs = false,
                ventasRefs = false,
                gastosRefs = false,
                pagosEmpleadosRefs = false,
                auditoriaRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (historialPreciosRefs) db.historialPrecios,
                    if (movimientosInventarioRefs) db.movimientosInventario,
                    if (sesionesAbiertas) db.cajaSesiones,
                    if (sesionesCerradas) db.cajaSesiones,
                    if (cajaMovimientosRefs) db.cajaMovimientos,
                    if (comprasRefs) db.compras,
                    if (ventasRefs) db.ventas,
                    if (gastosRefs) db.gastos,
                    if (pagosEmpleadosRefs) db.pagosEmpleados,
                    if (auditoriaRefs) db.auditoria,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (negocioId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.negocioId,
                                    referencedTable: $$UsuariosTableReferences
                                        ._negocioIdTable(db),
                                    referencedColumn: $$UsuariosTableReferences
                                        ._negocioIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (historialPreciosRefs)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          HistorialPrecio
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._historialPreciosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).historialPreciosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (movimientosInventarioRefs)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          MovimientosInventarioData
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._movimientosInventarioRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).movimientosInventarioRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sesionesAbiertas)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          CajaSesione
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._sesionesAbiertasTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).sesionesAbiertas,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioApertura == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sesionesCerradas)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          CajaSesione
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._sesionesCerradasTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).sesionesCerradas,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioCierre == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cajaMovimientosRefs)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          CajaMovimiento
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._cajaMovimientosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).cajaMovimientosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (comprasRefs)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          Compra
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._comprasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).comprasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ventasRefs)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          Venta
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._ventasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).ventasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gastosRefs)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          Gasto
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._gastosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).gastosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pagosEmpleadosRefs)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          PagosEmpleado
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._pagosEmpleadosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).pagosEmpleadosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (auditoriaRefs)
                        await $_getPrefetchedData<
                          Usuario,
                          $UsuariosTable,
                          AuditoriaData
                        >(
                          currentTable: table,
                          referencedTable: $$UsuariosTableReferences
                              ._auditoriaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsuariosTableReferences(
                                db,
                                table,
                                p0,
                              ).auditoriaRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.usuarioId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsuariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsuariosTable,
      Usuario,
      $$UsuariosTableFilterComposer,
      $$UsuariosTableOrderingComposer,
      $$UsuariosTableAnnotationComposer,
      $$UsuariosTableCreateCompanionBuilder,
      $$UsuariosTableUpdateCompanionBuilder,
      (Usuario, $$UsuariosTableReferences),
      Usuario,
      PrefetchHooks Function({
        bool negocioId,
        bool historialPreciosRefs,
        bool movimientosInventarioRefs,
        bool sesionesAbiertas,
        bool sesionesCerradas,
        bool cajaMovimientosRefs,
        bool comprasRefs,
        bool ventasRefs,
        bool gastosRefs,
        bool pagosEmpleadosRefs,
        bool auditoriaRefs,
      })
    >;
typedef $$LicenciasCacheTableCreateCompanionBuilder =
    LicenciasCacheCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required TipoLicencia tipo,
      required EstadoLicencia estado,
      Value<String?> claveLicencia,
      required String deviceId,
      required DateTime fechaActivacion,
      Value<DateTime?> fechaVencimiento,
      required DateTime ultimaValidacion,
      Value<int> rowid,
    });
typedef $$LicenciasCacheTableUpdateCompanionBuilder =
    LicenciasCacheCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<TipoLicencia> tipo,
      Value<EstadoLicencia> estado,
      Value<String?> claveLicencia,
      Value<String> deviceId,
      Value<DateTime> fechaActivacion,
      Value<DateTime?> fechaVencimiento,
      Value<DateTime> ultimaValidacion,
      Value<int> rowid,
    });

class $$LicenciasCacheTableFilterComposer
    extends Composer<_$AppDatabase, $LicenciasCacheTable> {
  $$LicenciasCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoLicencia, TipoLicencia, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<EstadoLicencia, EstadoLicencia, String>
  get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get claveLicencia => $composableBuilder(
    column: $table.claveLicencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaActivacion => $composableBuilder(
    column: $table.fechaActivacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ultimaValidacion => $composableBuilder(
    column: $table.ultimaValidacion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LicenciasCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $LicenciasCacheTable> {
  $$LicenciasCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get claveLicencia => $composableBuilder(
    column: $table.claveLicencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaActivacion => $composableBuilder(
    column: $table.fechaActivacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ultimaValidacion => $composableBuilder(
    column: $table.ultimaValidacion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LicenciasCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $LicenciasCacheTable> {
  $$LicenciasCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoLicencia, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EstadoLicencia, String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get claveLicencia => $composableBuilder(
    column: $table.claveLicencia,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaActivacion => $composableBuilder(
    column: $table.fechaActivacion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaVencimiento => $composableBuilder(
    column: $table.fechaVencimiento,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get ultimaValidacion => $composableBuilder(
    column: $table.ultimaValidacion,
    builder: (column) => column,
  );
}

class $$LicenciasCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LicenciasCacheTable,
          LicenciasCacheData,
          $$LicenciasCacheTableFilterComposer,
          $$LicenciasCacheTableOrderingComposer,
          $$LicenciasCacheTableAnnotationComposer,
          $$LicenciasCacheTableCreateCompanionBuilder,
          $$LicenciasCacheTableUpdateCompanionBuilder,
          (
            LicenciasCacheData,
            BaseReferences<
              _$AppDatabase,
              $LicenciasCacheTable,
              LicenciasCacheData
            >,
          ),
          LicenciasCacheData,
          PrefetchHooks Function()
        > {
  $$LicenciasCacheTableTableManager(
    _$AppDatabase db,
    $LicenciasCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LicenciasCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LicenciasCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LicenciasCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<TipoLicencia> tipo = const Value.absent(),
                Value<EstadoLicencia> estado = const Value.absent(),
                Value<String?> claveLicencia = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> fechaActivacion = const Value.absent(),
                Value<DateTime?> fechaVencimiento = const Value.absent(),
                Value<DateTime> ultimaValidacion = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LicenciasCacheCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tipo: tipo,
                estado: estado,
                claveLicencia: claveLicencia,
                deviceId: deviceId,
                fechaActivacion: fechaActivacion,
                fechaVencimiento: fechaVencimiento,
                ultimaValidacion: ultimaValidacion,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required TipoLicencia tipo,
                required EstadoLicencia estado,
                Value<String?> claveLicencia = const Value.absent(),
                required String deviceId,
                required DateTime fechaActivacion,
                Value<DateTime?> fechaVencimiento = const Value.absent(),
                required DateTime ultimaValidacion,
                Value<int> rowid = const Value.absent(),
              }) => LicenciasCacheCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tipo: tipo,
                estado: estado,
                claveLicencia: claveLicencia,
                deviceId: deviceId,
                fechaActivacion: fechaActivacion,
                fechaVencimiento: fechaVencimiento,
                ultimaValidacion: ultimaValidacion,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LicenciasCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LicenciasCacheTable,
      LicenciasCacheData,
      $$LicenciasCacheTableFilterComposer,
      $$LicenciasCacheTableOrderingComposer,
      $$LicenciasCacheTableAnnotationComposer,
      $$LicenciasCacheTableCreateCompanionBuilder,
      $$LicenciasCacheTableUpdateCompanionBuilder,
      (
        LicenciasCacheData,
        BaseReferences<_$AppDatabase, $LicenciasCacheTable, LicenciasCacheData>,
      ),
      LicenciasCacheData,
      PrefetchHooks Function()
    >;
typedef $$ConfiguracionesTableCreateCompanionBuilder =
    ConfiguracionesCompanion Function({
      required String clave,
      required String valor,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ConfiguracionesTableUpdateCompanionBuilder =
    ConfiguracionesCompanion Function({
      Value<String> clave,
      Value<String> valor,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ConfiguracionesTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracionesTable> {
  $$ConfiguracionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfiguracionesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracionesTable> {
  $$ConfiguracionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clave => $composableBuilder(
    column: $table.clave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfiguracionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracionesTable> {
  $$ConfiguracionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clave =>
      $composableBuilder(column: $table.clave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ConfiguracionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfiguracionesTable,
          Configuracione,
          $$ConfiguracionesTableFilterComposer,
          $$ConfiguracionesTableOrderingComposer,
          $$ConfiguracionesTableAnnotationComposer,
          $$ConfiguracionesTableCreateCompanionBuilder,
          $$ConfiguracionesTableUpdateCompanionBuilder,
          (
            Configuracione,
            BaseReferences<
              _$AppDatabase,
              $ConfiguracionesTable,
              Configuracione
            >,
          ),
          Configuracione,
          PrefetchHooks Function()
        > {
  $$ConfiguracionesTableTableManager(
    _$AppDatabase db,
    $ConfiguracionesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clave = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracionesCompanion(
                clave: clave,
                valor: valor,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clave,
                required String valor,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracionesCompanion.insert(
                clave: clave,
                valor: valor,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfiguracionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfiguracionesTable,
      Configuracione,
      $$ConfiguracionesTableFilterComposer,
      $$ConfiguracionesTableOrderingComposer,
      $$ConfiguracionesTableAnnotationComposer,
      $$ConfiguracionesTableCreateCompanionBuilder,
      $$ConfiguracionesTableUpdateCompanionBuilder,
      (
        Configuracione,
        BaseReferences<_$AppDatabase, $ConfiguracionesTable, Configuracione>,
      ),
      Configuracione,
      PrefetchHooks Function()
    >;
typedef $$CategoriasTableCreateCompanionBuilder =
    CategoriasCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String nombre,
      Value<int> rowid,
    });
typedef $$CategoriasTableUpdateCompanionBuilder =
    CategoriasCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> nombre,
      Value<int> rowid,
    });

final class $$CategoriasTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriasTable, Categoria> {
  $$CategoriasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductosTable, List<Producto>>
  _productosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productos,
    aliasName: $_aliasNameGenerator(db.categorias.id, db.productos.categoriaId),
  );

  $$ProductosTableProcessedTableManager get productosRefs {
    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productosRefs(
    Expression<bool> Function($$ProductosTableFilterComposer f) f,
  ) {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  Expression<T> productosRefs<T extends Object>(
    Expression<T> Function($$ProductosTableAnnotationComposer a) f,
  ) {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (Categoria, $$CategoriasTableReferences),
          Categoria,
          PrefetchHooks Function({bool productosRefs})
        > {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriasCompanion(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nombre: nombre,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String nombre,
                Value<int> rowid = const Value.absent(),
              }) => CategoriasCompanion.insert(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nombre: nombre,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productosRefs) db.productos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productosRefs)
                    await $_getPrefetchedData<
                      Categoria,
                      $CategoriasTable,
                      Producto
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriasTableReferences
                          ._productosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriasTableReferences(
                            db,
                            table,
                            p0,
                          ).productosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.categoriaId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, $$CategoriasTableReferences),
      Categoria,
      PrefetchHooks Function({bool productosRefs})
    >;
typedef $$ProductosTableCreateCompanionBuilder =
    ProductosCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String nombre,
      Value<String?> categoriaId,
      Value<String> unidad,
      Value<int> precioCompra,
      Value<int> precioVenta,
      Value<double> stockActual,
      Value<double> stockMinimo,
      Value<bool> activo,
      Value<int> rowid,
    });
typedef $$ProductosTableUpdateCompanionBuilder =
    ProductosCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> nombre,
      Value<String?> categoriaId,
      Value<String> unidad,
      Value<int> precioCompra,
      Value<int> precioVenta,
      Value<double> stockActual,
      Value<double> stockMinimo,
      Value<bool> activo,
      Value<int> rowid,
    });

final class $$ProductosTableReferences
    extends BaseReferences<_$AppDatabase, $ProductosTable, Producto> {
  $$ProductosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriasTable _categoriaIdTable(_$AppDatabase db) =>
      db.categorias.createAlias(
        $_aliasNameGenerator(db.productos.categoriaId, db.categorias.id),
      );

  $$CategoriasTableProcessedTableManager? get categoriaId {
    final $_column = $_itemColumn<String>('categoria_id');
    if ($_column == null) return null;
    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$HistorialPreciosTable, List<HistorialPrecio>>
  _historialPreciosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.historialPrecios,
    aliasName: $_aliasNameGenerator(
      db.productos.id,
      db.historialPrecios.productoId,
    ),
  );

  $$HistorialPreciosTableProcessedTableManager get historialPreciosRefs {
    final manager = $$HistorialPreciosTableTableManager(
      $_db,
      $_db.historialPrecios,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _historialPreciosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MovimientosInventarioTable,
    List<MovimientosInventarioData>
  >
  _movimientosInventarioRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.movimientosInventario,
        aliasName: $_aliasNameGenerator(
          db.productos.id,
          db.movimientosInventario.productoId,
        ),
      );

  $$MovimientosInventarioTableProcessedTableManager
  get movimientosInventarioRefs {
    final manager = $$MovimientosInventarioTableTableManager(
      $_db,
      $_db.movimientosInventario,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _movimientosInventarioRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CompraItemsTable, List<CompraItem>>
  _compraItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.compraItems,
    aliasName: $_aliasNameGenerator(db.productos.id, db.compraItems.productoId),
  );

  $$CompraItemsTableProcessedTableManager get compraItemsRefs {
    final manager = $$CompraItemsTableTableManager(
      $_db,
      $_db.compraItems,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_compraItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VentaItemsTable, List<VentaItem>>
  _ventaItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ventaItems,
    aliasName: $_aliasNameGenerator(db.productos.id, db.ventaItems.productoId),
  );

  $$VentaItemsTableProcessedTableManager get ventaItemsRefs {
    final manager = $$VentaItemsTableTableManager(
      $_db,
      $_db.ventaItems,
    ).filter((f) => f.productoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ventaItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductosTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidad => $composableBuilder(
    column: $table.unidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> historialPreciosRefs(
    Expression<bool> Function($$HistorialPreciosTableFilterComposer f) f,
  ) {
    final $$HistorialPreciosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historialPrecios,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorialPreciosTableFilterComposer(
            $db: $db,
            $table: $db.historialPrecios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> movimientosInventarioRefs(
    Expression<bool> Function($$MovimientosInventarioTableFilterComposer f) f,
  ) {
    final $$MovimientosInventarioTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.movimientosInventario,
          getReferencedColumn: (t) => t.productoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MovimientosInventarioTableFilterComposer(
                $db: $db,
                $table: $db.movimientosInventario,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> compraItemsRefs(
    Expression<bool> Function($$CompraItemsTableFilterComposer f) f,
  ) {
    final $$CompraItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compraItems,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompraItemsTableFilterComposer(
            $db: $db,
            $table: $db.compraItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ventaItemsRefs(
    Expression<bool> Function($$VentaItemsTableFilterComposer f) f,
  ) {
    final $$VentaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventaItems,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentaItemsTableFilterComposer(
            $db: $db,
            $table: $db.ventaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidad => $composableBuilder(
    column: $table.unidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get unidad =>
      $composableBuilder(column: $table.unidad, builder: (column) => column);

  GeneratedColumn<int> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> historialPreciosRefs<T extends Object>(
    Expression<T> Function($$HistorialPreciosTableAnnotationComposer a) f,
  ) {
    final $$HistorialPreciosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historialPrecios,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorialPreciosTableAnnotationComposer(
            $db: $db,
            $table: $db.historialPrecios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> movimientosInventarioRefs<T extends Object>(
    Expression<T> Function($$MovimientosInventarioTableAnnotationComposer a) f,
  ) {
    final $$MovimientosInventarioTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.movimientosInventario,
          getReferencedColumn: (t) => t.productoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MovimientosInventarioTableAnnotationComposer(
                $db: $db,
                $table: $db.movimientosInventario,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> compraItemsRefs<T extends Object>(
    Expression<T> Function($$CompraItemsTableAnnotationComposer a) f,
  ) {
    final $$CompraItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compraItems,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompraItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.compraItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ventaItemsRefs<T extends Object>(
    Expression<T> Function($$VentaItemsTableAnnotationComposer a) f,
  ) {
    final $$VentaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventaItems,
      getReferencedColumn: (t) => t.productoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.ventaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosTable,
          Producto,
          $$ProductosTableFilterComposer,
          $$ProductosTableOrderingComposer,
          $$ProductosTableAnnotationComposer,
          $$ProductosTableCreateCompanionBuilder,
          $$ProductosTableUpdateCompanionBuilder,
          (Producto, $$ProductosTableReferences),
          Producto,
          PrefetchHooks Function({
            bool categoriaId,
            bool historialPreciosRefs,
            bool movimientosInventarioRefs,
            bool compraItemsRefs,
            bool ventaItemsRefs,
          })
        > {
  $$ProductosTableTableManager(_$AppDatabase db, $ProductosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> categoriaId = const Value.absent(),
                Value<String> unidad = const Value.absent(),
                Value<int> precioCompra = const Value.absent(),
                Value<int> precioVenta = const Value.absent(),
                Value<double> stockActual = const Value.absent(),
                Value<double> stockMinimo = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosCompanion(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nombre: nombre,
                categoriaId: categoriaId,
                unidad: unidad,
                precioCompra: precioCompra,
                precioVenta: precioVenta,
                stockActual: stockActual,
                stockMinimo: stockMinimo,
                activo: activo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String nombre,
                Value<String?> categoriaId = const Value.absent(),
                Value<String> unidad = const Value.absent(),
                Value<int> precioCompra = const Value.absent(),
                Value<int> precioVenta = const Value.absent(),
                Value<double> stockActual = const Value.absent(),
                Value<double> stockMinimo = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosCompanion.insert(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nombre: nombre,
                categoriaId: categoriaId,
                unidad: unidad,
                precioCompra: precioCompra,
                precioVenta: precioVenta,
                stockActual: stockActual,
                stockMinimo: stockMinimo,
                activo: activo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoriaId = false,
                historialPreciosRefs = false,
                movimientosInventarioRefs = false,
                compraItemsRefs = false,
                ventaItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (historialPreciosRefs) db.historialPrecios,
                    if (movimientosInventarioRefs) db.movimientosInventario,
                    if (compraItemsRefs) db.compraItems,
                    if (ventaItemsRefs) db.ventaItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoriaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoriaId,
                                    referencedTable: $$ProductosTableReferences
                                        ._categoriaIdTable(db),
                                    referencedColumn: $$ProductosTableReferences
                                        ._categoriaIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (historialPreciosRefs)
                        await $_getPrefetchedData<
                          Producto,
                          $ProductosTable,
                          HistorialPrecio
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._historialPreciosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).historialPreciosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (movimientosInventarioRefs)
                        await $_getPrefetchedData<
                          Producto,
                          $ProductosTable,
                          MovimientosInventarioData
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._movimientosInventarioRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).movimientosInventarioRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (compraItemsRefs)
                        await $_getPrefetchedData<
                          Producto,
                          $ProductosTable,
                          CompraItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._compraItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).compraItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ventaItemsRefs)
                        await $_getPrefetchedData<
                          Producto,
                          $ProductosTable,
                          VentaItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductosTableReferences
                              ._ventaItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductosTableReferences(
                                db,
                                table,
                                p0,
                              ).ventaItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosTable,
      Producto,
      $$ProductosTableFilterComposer,
      $$ProductosTableOrderingComposer,
      $$ProductosTableAnnotationComposer,
      $$ProductosTableCreateCompanionBuilder,
      $$ProductosTableUpdateCompanionBuilder,
      (Producto, $$ProductosTableReferences),
      Producto,
      PrefetchHooks Function({
        bool categoriaId,
        bool historialPreciosRefs,
        bool movimientosInventarioRefs,
        bool compraItemsRefs,
        bool ventaItemsRefs,
      })
    >;
typedef $$HistorialPreciosTableCreateCompanionBuilder =
    HistorialPreciosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String productoId,
      required TipoPrecio tipo,
      required int precioAnterior,
      required int precioNuevo,
      required String usuarioId,
      Value<DateTime> fecha,
      Value<int> rowid,
    });
typedef $$HistorialPreciosTableUpdateCompanionBuilder =
    HistorialPreciosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> productoId,
      Value<TipoPrecio> tipo,
      Value<int> precioAnterior,
      Value<int> precioNuevo,
      Value<String> usuarioId,
      Value<DateTime> fecha,
      Value<int> rowid,
    });

final class $$HistorialPreciosTableReferences
    extends
        BaseReferences<_$AppDatabase, $HistorialPreciosTable, HistorialPrecio> {
  $$HistorialPreciosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductosTable _productoIdTable(_$AppDatabase db) =>
      db.productos.createAlias(
        $_aliasNameGenerator(db.historialPrecios.productoId, db.productos.id),
      );

  $$ProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<String>('producto_id')!;

    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) =>
      db.usuarios.createAlias(
        $_aliasNameGenerator(db.historialPrecios.usuarioId, db.usuarios.id),
      );

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistorialPreciosTableFilterComposer
    extends Composer<_$AppDatabase, $HistorialPreciosTable> {
  $$HistorialPreciosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoPrecio, TipoPrecio, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get precioAnterior => $composableBuilder(
    column: $table.precioAnterior,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioNuevo => $composableBuilder(
    column: $table.precioNuevo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistorialPreciosTableOrderingComposer
    extends Composer<_$AppDatabase, $HistorialPreciosTable> {
  $$HistorialPreciosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioAnterior => $composableBuilder(
    column: $table.precioAnterior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioNuevo => $composableBuilder(
    column: $table.precioNuevo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistorialPreciosTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistorialPreciosTable> {
  $$HistorialPreciosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoPrecio, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get precioAnterior => $composableBuilder(
    column: $table.precioAnterior,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precioNuevo => $composableBuilder(
    column: $table.precioNuevo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistorialPreciosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistorialPreciosTable,
          HistorialPrecio,
          $$HistorialPreciosTableFilterComposer,
          $$HistorialPreciosTableOrderingComposer,
          $$HistorialPreciosTableAnnotationComposer,
          $$HistorialPreciosTableCreateCompanionBuilder,
          $$HistorialPreciosTableUpdateCompanionBuilder,
          (HistorialPrecio, $$HistorialPreciosTableReferences),
          HistorialPrecio,
          PrefetchHooks Function({bool productoId, bool usuarioId})
        > {
  $$HistorialPreciosTableTableManager(
    _$AppDatabase db,
    $HistorialPreciosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistorialPreciosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistorialPreciosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistorialPreciosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<TipoPrecio> tipo = const Value.absent(),
                Value<int> precioAnterior = const Value.absent(),
                Value<int> precioNuevo = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistorialPreciosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productoId: productoId,
                tipo: tipo,
                precioAnterior: precioAnterior,
                precioNuevo: precioNuevo,
                usuarioId: usuarioId,
                fecha: fecha,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String productoId,
                required TipoPrecio tipo,
                required int precioAnterior,
                required int precioNuevo,
                required String usuarioId,
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistorialPreciosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productoId: productoId,
                tipo: tipo,
                precioAnterior: precioAnterior,
                precioNuevo: precioNuevo,
                usuarioId: usuarioId,
                fecha: fecha,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HistorialPreciosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productoId = false, usuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable:
                                    $$HistorialPreciosTableReferences
                                        ._productoIdTable(db),
                                referencedColumn:
                                    $$HistorialPreciosTableReferences
                                        ._productoIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (usuarioId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.usuarioId,
                                referencedTable:
                                    $$HistorialPreciosTableReferences
                                        ._usuarioIdTable(db),
                                referencedColumn:
                                    $$HistorialPreciosTableReferences
                                        ._usuarioIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HistorialPreciosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistorialPreciosTable,
      HistorialPrecio,
      $$HistorialPreciosTableFilterComposer,
      $$HistorialPreciosTableOrderingComposer,
      $$HistorialPreciosTableAnnotationComposer,
      $$HistorialPreciosTableCreateCompanionBuilder,
      $$HistorialPreciosTableUpdateCompanionBuilder,
      (HistorialPrecio, $$HistorialPreciosTableReferences),
      HistorialPrecio,
      PrefetchHooks Function({bool productoId, bool usuarioId})
    >;
typedef $$ProveedoresTableCreateCompanionBuilder =
    ProveedoresCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String nombre,
      Value<String?> telefono,
      Value<int> rowid,
    });
typedef $$ProveedoresTableUpdateCompanionBuilder =
    ProveedoresCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> nombre,
      Value<String?> telefono,
      Value<int> rowid,
    });

final class $$ProveedoresTableReferences
    extends BaseReferences<_$AppDatabase, $ProveedoresTable, Proveedore> {
  $$ProveedoresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ComprasTable, List<Compra>> _comprasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.compras,
    aliasName: $_aliasNameGenerator(db.proveedores.id, db.compras.proveedorId),
  );

  $$ComprasTableProcessedTableManager get comprasRefs {
    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.proveedorId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_comprasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProveedoresTableFilterComposer
    extends Composer<_$AppDatabase, $ProveedoresTable> {
  $$ProveedoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> comprasRefs(
    Expression<bool> Function($$ComprasTableFilterComposer f) f,
  ) {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.proveedorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProveedoresTableOrderingComposer
    extends Composer<_$AppDatabase, $ProveedoresTable> {
  $$ProveedoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProveedoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProveedoresTable> {
  $$ProveedoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  Expression<T> comprasRefs<T extends Object>(
    Expression<T> Function($$ComprasTableAnnotationComposer a) f,
  ) {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.proveedorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProveedoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProveedoresTable,
          Proveedore,
          $$ProveedoresTableFilterComposer,
          $$ProveedoresTableOrderingComposer,
          $$ProveedoresTableAnnotationComposer,
          $$ProveedoresTableCreateCompanionBuilder,
          $$ProveedoresTableUpdateCompanionBuilder,
          (Proveedore, $$ProveedoresTableReferences),
          Proveedore,
          PrefetchHooks Function({bool comprasRefs})
        > {
  $$ProveedoresTableTableManager(_$AppDatabase db, $ProveedoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProveedoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProveedoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProveedoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProveedoresCompanion(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nombre: nombre,
                telefono: telefono,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String nombre,
                Value<String?> telefono = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProveedoresCompanion.insert(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                nombre: nombre,
                telefono: telefono,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProveedoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({comprasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (comprasRefs) db.compras],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (comprasRefs)
                    await $_getPrefetchedData<
                      Proveedore,
                      $ProveedoresTable,
                      Compra
                    >(
                      currentTable: table,
                      referencedTable: $$ProveedoresTableReferences
                          ._comprasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProveedoresTableReferences(
                            db,
                            table,
                            p0,
                          ).comprasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.proveedorId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProveedoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProveedoresTable,
      Proveedore,
      $$ProveedoresTableFilterComposer,
      $$ProveedoresTableOrderingComposer,
      $$ProveedoresTableAnnotationComposer,
      $$ProveedoresTableCreateCompanionBuilder,
      $$ProveedoresTableUpdateCompanionBuilder,
      (Proveedore, $$ProveedoresTableReferences),
      Proveedore,
      PrefetchHooks Function({bool comprasRefs})
    >;
typedef $$MovimientosInventarioTableCreateCompanionBuilder =
    MovimientosInventarioCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String productoId,
      required TipoMovimientoInventario tipo,
      required double cantidad,
      required double stockResultante,
      Value<String?> motivo,
      Value<String?> referenciaId,
      required String usuarioId,
      Value<DateTime> fecha,
      Value<int> rowid,
    });
typedef $$MovimientosInventarioTableUpdateCompanionBuilder =
    MovimientosInventarioCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> productoId,
      Value<TipoMovimientoInventario> tipo,
      Value<double> cantidad,
      Value<double> stockResultante,
      Value<String?> motivo,
      Value<String?> referenciaId,
      Value<String> usuarioId,
      Value<DateTime> fecha,
      Value<int> rowid,
    });

final class $$MovimientosInventarioTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MovimientosInventarioTable,
          MovimientosInventarioData
        > {
  $$MovimientosInventarioTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductosTable _productoIdTable(_$AppDatabase db) =>
      db.productos.createAlias(
        $_aliasNameGenerator(
          db.movimientosInventario.productoId,
          db.productos.id,
        ),
      );

  $$ProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<String>('producto_id')!;

    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) =>
      db.usuarios.createAlias(
        $_aliasNameGenerator(
          db.movimientosInventario.usuarioId,
          db.usuarios.id,
        ),
      );

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MovimientosInventarioTableFilterComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTable> {
  $$MovimientosInventarioTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    TipoMovimientoInventario,
    TipoMovimientoInventario,
    String
  >
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockResultante => $composableBuilder(
    column: $table.stockResultante,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovimientosInventarioTableOrderingComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTable> {
  $$MovimientosInventarioTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockResultante => $composableBuilder(
    column: $table.stockResultante,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovimientosInventarioTableAnnotationComposer
    extends Composer<_$AppDatabase, $MovimientosInventarioTable> {
  $$MovimientosInventarioTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoMovimientoInventario, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get stockResultante => $composableBuilder(
    column: $table.stockResultante,
    builder: (column) => column,
  );

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<String> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MovimientosInventarioTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MovimientosInventarioTable,
          MovimientosInventarioData,
          $$MovimientosInventarioTableFilterComposer,
          $$MovimientosInventarioTableOrderingComposer,
          $$MovimientosInventarioTableAnnotationComposer,
          $$MovimientosInventarioTableCreateCompanionBuilder,
          $$MovimientosInventarioTableUpdateCompanionBuilder,
          (MovimientosInventarioData, $$MovimientosInventarioTableReferences),
          MovimientosInventarioData,
          PrefetchHooks Function({bool productoId, bool usuarioId})
        > {
  $$MovimientosInventarioTableTableManager(
    _$AppDatabase db,
    $MovimientosInventarioTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MovimientosInventarioTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MovimientosInventarioTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MovimientosInventarioTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<TipoMovimientoInventario> tipo = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<double> stockResultante = const Value.absent(),
                Value<String?> motivo = const Value.absent(),
                Value<String?> referenciaId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimientosInventarioCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productoId: productoId,
                tipo: tipo,
                cantidad: cantidad,
                stockResultante: stockResultante,
                motivo: motivo,
                referenciaId: referenciaId,
                usuarioId: usuarioId,
                fecha: fecha,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String productoId,
                required TipoMovimientoInventario tipo,
                required double cantidad,
                required double stockResultante,
                Value<String?> motivo = const Value.absent(),
                Value<String?> referenciaId = const Value.absent(),
                required String usuarioId,
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MovimientosInventarioCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                productoId: productoId,
                tipo: tipo,
                cantidad: cantidad,
                stockResultante: stockResultante,
                motivo: motivo,
                referenciaId: referenciaId,
                usuarioId: usuarioId,
                fecha: fecha,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MovimientosInventarioTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productoId = false, usuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable:
                                    $$MovimientosInventarioTableReferences
                                        ._productoIdTable(db),
                                referencedColumn:
                                    $$MovimientosInventarioTableReferences
                                        ._productoIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (usuarioId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.usuarioId,
                                referencedTable:
                                    $$MovimientosInventarioTableReferences
                                        ._usuarioIdTable(db),
                                referencedColumn:
                                    $$MovimientosInventarioTableReferences
                                        ._usuarioIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MovimientosInventarioTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MovimientosInventarioTable,
      MovimientosInventarioData,
      $$MovimientosInventarioTableFilterComposer,
      $$MovimientosInventarioTableOrderingComposer,
      $$MovimientosInventarioTableAnnotationComposer,
      $$MovimientosInventarioTableCreateCompanionBuilder,
      $$MovimientosInventarioTableUpdateCompanionBuilder,
      (MovimientosInventarioData, $$MovimientosInventarioTableReferences),
      MovimientosInventarioData,
      PrefetchHooks Function({bool productoId, bool usuarioId})
    >;
typedef $$CajaSesionesTableCreateCompanionBuilder =
    CajaSesionesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required DateTime fechaApertura,
      required int montoApertura,
      Value<DateTime?> fechaCierre,
      Value<int?> montoEsperado,
      Value<int?> montoContado,
      Value<int?> diferencia,
      Value<int?> montoDejadoSiguiente,
      required String usuarioApertura,
      Value<String?> usuarioCierre,
      required EstadoCajaSesion estado,
      Value<int> rowid,
    });
typedef $$CajaSesionesTableUpdateCompanionBuilder =
    CajaSesionesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> fechaApertura,
      Value<int> montoApertura,
      Value<DateTime?> fechaCierre,
      Value<int?> montoEsperado,
      Value<int?> montoContado,
      Value<int?> diferencia,
      Value<int?> montoDejadoSiguiente,
      Value<String> usuarioApertura,
      Value<String?> usuarioCierre,
      Value<EstadoCajaSesion> estado,
      Value<int> rowid,
    });

final class $$CajaSesionesTableReferences
    extends BaseReferences<_$AppDatabase, $CajaSesionesTable, CajaSesione> {
  $$CajaSesionesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsuariosTable _usuarioAperturaTable(_$AppDatabase db) =>
      db.usuarios.createAlias(
        $_aliasNameGenerator(db.cajaSesiones.usuarioApertura, db.usuarios.id),
      );

  $$UsuariosTableProcessedTableManager get usuarioApertura {
    final $_column = $_itemColumn<String>('usuario_apertura')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioAperturaTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioCierreTable(_$AppDatabase db) =>
      db.usuarios.createAlias(
        $_aliasNameGenerator(db.cajaSesiones.usuarioCierre, db.usuarios.id),
      );

  $$UsuariosTableProcessedTableManager? get usuarioCierre {
    final $_column = $_itemColumn<String>('usuario_cierre');
    if ($_column == null) return null;
    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioCierreTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CajaMovimientosTable, List<CajaMovimiento>>
  _cajaMovimientosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cajaMovimientos,
    aliasName: $_aliasNameGenerator(
      db.cajaSesiones.id,
      db.cajaMovimientos.cajaSesionId,
    ),
  );

  $$CajaMovimientosTableProcessedTableManager get cajaMovimientosRefs {
    final manager = $$CajaMovimientosTableTableManager(
      $_db,
      $_db.cajaMovimientos,
    ).filter((f) => f.cajaSesionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cajaMovimientosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VentasTable, List<Venta>> _ventasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.ventas,
    aliasName: $_aliasNameGenerator(db.cajaSesiones.id, db.ventas.cajaSesionId),
  );

  $$VentasTableProcessedTableManager get ventasRefs {
    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.cajaSesionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ventasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GastosTable, List<Gasto>> _gastosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.gastos,
    aliasName: $_aliasNameGenerator(db.cajaSesiones.id, db.gastos.cajaSesionId),
  );

  $$GastosTableProcessedTableManager get gastosRefs {
    final manager = $$GastosTableTableManager(
      $_db,
      $_db.gastos,
    ).filter((f) => f.cajaSesionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gastosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PagosEmpleadosTable, List<PagosEmpleado>>
  _pagosEmpleadosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pagosEmpleados,
    aliasName: $_aliasNameGenerator(
      db.cajaSesiones.id,
      db.pagosEmpleados.cajaSesionId,
    ),
  );

  $$PagosEmpleadosTableProcessedTableManager get pagosEmpleadosRefs {
    final manager = $$PagosEmpleadosTableTableManager(
      $_db,
      $_db.pagosEmpleados,
    ).filter((f) => f.cajaSesionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosEmpleadosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CajaSesionesTableFilterComposer
    extends Composer<_$AppDatabase, $CajaSesionesTable> {
  $$CajaSesionesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoApertura => $composableBuilder(
    column: $table.montoApertura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoEsperado => $composableBuilder(
    column: $table.montoEsperado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoContado => $composableBuilder(
    column: $table.montoContado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diferencia => $composableBuilder(
    column: $table.diferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoDejadoSiguiente => $composableBuilder(
    column: $table.montoDejadoSiguiente,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EstadoCajaSesion, EstadoCajaSesion, String>
  get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$UsuariosTableFilterComposer get usuarioApertura {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioApertura,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioCierre {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioCierre,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cajaMovimientosRefs(
    Expression<bool> Function($$CajaMovimientosTableFilterComposer f) f,
  ) {
    final $$CajaMovimientosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cajaMovimientos,
      getReferencedColumn: (t) => t.cajaSesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaMovimientosTableFilterComposer(
            $db: $db,
            $table: $db.cajaMovimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> ventasRefs(
    Expression<bool> Function($$VentasTableFilterComposer f) f,
  ) {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.cajaSesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> gastosRefs(
    Expression<bool> Function($$GastosTableFilterComposer f) f,
  ) {
    final $$GastosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.cajaSesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableFilterComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pagosEmpleadosRefs(
    Expression<bool> Function($$PagosEmpleadosTableFilterComposer f) f,
  ) {
    final $$PagosEmpleadosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagosEmpleados,
      getReferencedColumn: (t) => t.cajaSesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosEmpleadosTableFilterComposer(
            $db: $db,
            $table: $db.pagosEmpleados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CajaSesionesTableOrderingComposer
    extends Composer<_$AppDatabase, $CajaSesionesTable> {
  $$CajaSesionesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoApertura => $composableBuilder(
    column: $table.montoApertura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoEsperado => $composableBuilder(
    column: $table.montoEsperado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoContado => $composableBuilder(
    column: $table.montoContado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diferencia => $composableBuilder(
    column: $table.diferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoDejadoSiguiente => $composableBuilder(
    column: $table.montoDejadoSiguiente,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsuariosTableOrderingComposer get usuarioApertura {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioApertura,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioCierre {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioCierre,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CajaSesionesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CajaSesionesTable> {
  $$CajaSesionesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaApertura => $composableBuilder(
    column: $table.fechaApertura,
    builder: (column) => column,
  );

  GeneratedColumn<int> get montoApertura => $composableBuilder(
    column: $table.montoApertura,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaCierre => $composableBuilder(
    column: $table.fechaCierre,
    builder: (column) => column,
  );

  GeneratedColumn<int> get montoEsperado => $composableBuilder(
    column: $table.montoEsperado,
    builder: (column) => column,
  );

  GeneratedColumn<int> get montoContado => $composableBuilder(
    column: $table.montoContado,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diferencia => $composableBuilder(
    column: $table.diferencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get montoDejadoSiguiente => $composableBuilder(
    column: $table.montoDejadoSiguiente,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EstadoCajaSesion, String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  $$UsuariosTableAnnotationComposer get usuarioApertura {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioApertura,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioCierre {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioCierre,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cajaMovimientosRefs<T extends Object>(
    Expression<T> Function($$CajaMovimientosTableAnnotationComposer a) f,
  ) {
    final $$CajaMovimientosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cajaMovimientos,
      getReferencedColumn: (t) => t.cajaSesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaMovimientosTableAnnotationComposer(
            $db: $db,
            $table: $db.cajaMovimientos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> ventasRefs<T extends Object>(
    Expression<T> Function($$VentasTableAnnotationComposer a) f,
  ) {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.cajaSesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> gastosRefs<T extends Object>(
    Expression<T> Function($$GastosTableAnnotationComposer a) f,
  ) {
    final $$GastosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.cajaSesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableAnnotationComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pagosEmpleadosRefs<T extends Object>(
    Expression<T> Function($$PagosEmpleadosTableAnnotationComposer a) f,
  ) {
    final $$PagosEmpleadosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagosEmpleados,
      getReferencedColumn: (t) => t.cajaSesionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosEmpleadosTableAnnotationComposer(
            $db: $db,
            $table: $db.pagosEmpleados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CajaSesionesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CajaSesionesTable,
          CajaSesione,
          $$CajaSesionesTableFilterComposer,
          $$CajaSesionesTableOrderingComposer,
          $$CajaSesionesTableAnnotationComposer,
          $$CajaSesionesTableCreateCompanionBuilder,
          $$CajaSesionesTableUpdateCompanionBuilder,
          (CajaSesione, $$CajaSesionesTableReferences),
          CajaSesione,
          PrefetchHooks Function({
            bool usuarioApertura,
            bool usuarioCierre,
            bool cajaMovimientosRefs,
            bool ventasRefs,
            bool gastosRefs,
            bool pagosEmpleadosRefs,
          })
        > {
  $$CajaSesionesTableTableManager(_$AppDatabase db, $CajaSesionesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CajaSesionesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CajaSesionesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CajaSesionesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> fechaApertura = const Value.absent(),
                Value<int> montoApertura = const Value.absent(),
                Value<DateTime?> fechaCierre = const Value.absent(),
                Value<int?> montoEsperado = const Value.absent(),
                Value<int?> montoContado = const Value.absent(),
                Value<int?> diferencia = const Value.absent(),
                Value<int?> montoDejadoSiguiente = const Value.absent(),
                Value<String> usuarioApertura = const Value.absent(),
                Value<String?> usuarioCierre = const Value.absent(),
                Value<EstadoCajaSesion> estado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CajaSesionesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fechaApertura: fechaApertura,
                montoApertura: montoApertura,
                fechaCierre: fechaCierre,
                montoEsperado: montoEsperado,
                montoContado: montoContado,
                diferencia: diferencia,
                montoDejadoSiguiente: montoDejadoSiguiente,
                usuarioApertura: usuarioApertura,
                usuarioCierre: usuarioCierre,
                estado: estado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required DateTime fechaApertura,
                required int montoApertura,
                Value<DateTime?> fechaCierre = const Value.absent(),
                Value<int?> montoEsperado = const Value.absent(),
                Value<int?> montoContado = const Value.absent(),
                Value<int?> diferencia = const Value.absent(),
                Value<int?> montoDejadoSiguiente = const Value.absent(),
                required String usuarioApertura,
                Value<String?> usuarioCierre = const Value.absent(),
                required EstadoCajaSesion estado,
                Value<int> rowid = const Value.absent(),
              }) => CajaSesionesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fechaApertura: fechaApertura,
                montoApertura: montoApertura,
                fechaCierre: fechaCierre,
                montoEsperado: montoEsperado,
                montoContado: montoContado,
                diferencia: diferencia,
                montoDejadoSiguiente: montoDejadoSiguiente,
                usuarioApertura: usuarioApertura,
                usuarioCierre: usuarioCierre,
                estado: estado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CajaSesionesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                usuarioApertura = false,
                usuarioCierre = false,
                cajaMovimientosRefs = false,
                ventasRefs = false,
                gastosRefs = false,
                pagosEmpleadosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cajaMovimientosRefs) db.cajaMovimientos,
                    if (ventasRefs) db.ventas,
                    if (gastosRefs) db.gastos,
                    if (pagosEmpleadosRefs) db.pagosEmpleados,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (usuarioApertura) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.usuarioApertura,
                                    referencedTable:
                                        $$CajaSesionesTableReferences
                                            ._usuarioAperturaTable(db),
                                    referencedColumn:
                                        $$CajaSesionesTableReferences
                                            ._usuarioAperturaTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (usuarioCierre) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.usuarioCierre,
                                    referencedTable:
                                        $$CajaSesionesTableReferences
                                            ._usuarioCierreTable(db),
                                    referencedColumn:
                                        $$CajaSesionesTableReferences
                                            ._usuarioCierreTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cajaMovimientosRefs)
                        await $_getPrefetchedData<
                          CajaSesione,
                          $CajaSesionesTable,
                          CajaMovimiento
                        >(
                          currentTable: table,
                          referencedTable: $$CajaSesionesTableReferences
                              ._cajaMovimientosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CajaSesionesTableReferences(
                                db,
                                table,
                                p0,
                              ).cajaMovimientosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cajaSesionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (ventasRefs)
                        await $_getPrefetchedData<
                          CajaSesione,
                          $CajaSesionesTable,
                          Venta
                        >(
                          currentTable: table,
                          referencedTable: $$CajaSesionesTableReferences
                              ._ventasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CajaSesionesTableReferences(
                                db,
                                table,
                                p0,
                              ).ventasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cajaSesionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (gastosRefs)
                        await $_getPrefetchedData<
                          CajaSesione,
                          $CajaSesionesTable,
                          Gasto
                        >(
                          currentTable: table,
                          referencedTable: $$CajaSesionesTableReferences
                              ._gastosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CajaSesionesTableReferences(
                                db,
                                table,
                                p0,
                              ).gastosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cajaSesionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pagosEmpleadosRefs)
                        await $_getPrefetchedData<
                          CajaSesione,
                          $CajaSesionesTable,
                          PagosEmpleado
                        >(
                          currentTable: table,
                          referencedTable: $$CajaSesionesTableReferences
                              ._pagosEmpleadosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CajaSesionesTableReferences(
                                db,
                                table,
                                p0,
                              ).pagosEmpleadosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cajaSesionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CajaSesionesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CajaSesionesTable,
      CajaSesione,
      $$CajaSesionesTableFilterComposer,
      $$CajaSesionesTableOrderingComposer,
      $$CajaSesionesTableAnnotationComposer,
      $$CajaSesionesTableCreateCompanionBuilder,
      $$CajaSesionesTableUpdateCompanionBuilder,
      (CajaSesione, $$CajaSesionesTableReferences),
      CajaSesione,
      PrefetchHooks Function({
        bool usuarioApertura,
        bool usuarioCierre,
        bool cajaMovimientosRefs,
        bool ventasRefs,
        bool gastosRefs,
        bool pagosEmpleadosRefs,
      })
    >;
typedef $$CajaMovimientosTableCreateCompanionBuilder =
    CajaMovimientosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String cajaSesionId,
      required TipoCajaMovimiento tipo,
      required int monto,
      Value<String?> motivo,
      Value<String?> referenciaId,
      required String usuarioId,
      Value<DateTime> fecha,
      Value<int> rowid,
    });
typedef $$CajaMovimientosTableUpdateCompanionBuilder =
    CajaMovimientosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> cajaSesionId,
      Value<TipoCajaMovimiento> tipo,
      Value<int> monto,
      Value<String?> motivo,
      Value<String?> referenciaId,
      Value<String> usuarioId,
      Value<DateTime> fecha,
      Value<int> rowid,
    });

final class $$CajaMovimientosTableReferences
    extends
        BaseReferences<_$AppDatabase, $CajaMovimientosTable, CajaMovimiento> {
  $$CajaMovimientosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CajaSesionesTable _cajaSesionIdTable(_$AppDatabase db) =>
      db.cajaSesiones.createAlias(
        $_aliasNameGenerator(
          db.cajaMovimientos.cajaSesionId,
          db.cajaSesiones.id,
        ),
      );

  $$CajaSesionesTableProcessedTableManager get cajaSesionId {
    final $_column = $_itemColumn<String>('caja_sesion_id')!;

    final manager = $$CajaSesionesTableTableManager(
      $_db,
      $_db.cajaSesiones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cajaSesionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) =>
      db.usuarios.createAlias(
        $_aliasNameGenerator(db.cajaMovimientos.usuarioId, db.usuarios.id),
      );

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CajaMovimientosTableFilterComposer
    extends Composer<_$AppDatabase, $CajaMovimientosTable> {
  $$CajaMovimientosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoCajaMovimiento, TipoCajaMovimiento, String>
  get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  $$CajaSesionesTableFilterComposer get cajaSesionId {
    final $$CajaSesionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableFilterComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CajaMovimientosTableOrderingComposer
    extends Composer<_$AppDatabase, $CajaMovimientosTable> {
  $$CajaMovimientosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get motivo => $composableBuilder(
    column: $table.motivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  $$CajaSesionesTableOrderingComposer get cajaSesionId {
    final $$CajaSesionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableOrderingComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CajaMovimientosTableAnnotationComposer
    extends Composer<_$AppDatabase, $CajaMovimientosTable> {
  $$CajaMovimientosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoCajaMovimiento, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get motivo =>
      $composableBuilder(column: $table.motivo, builder: (column) => column);

  GeneratedColumn<String> get referenciaId => $composableBuilder(
    column: $table.referenciaId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  $$CajaSesionesTableAnnotationComposer get cajaSesionId {
    final $$CajaSesionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableAnnotationComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CajaMovimientosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CajaMovimientosTable,
          CajaMovimiento,
          $$CajaMovimientosTableFilterComposer,
          $$CajaMovimientosTableOrderingComposer,
          $$CajaMovimientosTableAnnotationComposer,
          $$CajaMovimientosTableCreateCompanionBuilder,
          $$CajaMovimientosTableUpdateCompanionBuilder,
          (CajaMovimiento, $$CajaMovimientosTableReferences),
          CajaMovimiento,
          PrefetchHooks Function({bool cajaSesionId, bool usuarioId})
        > {
  $$CajaMovimientosTableTableManager(
    _$AppDatabase db,
    $CajaMovimientosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CajaMovimientosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CajaMovimientosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CajaMovimientosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> cajaSesionId = const Value.absent(),
                Value<TipoCajaMovimiento> tipo = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<String?> motivo = const Value.absent(),
                Value<String?> referenciaId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CajaMovimientosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cajaSesionId: cajaSesionId,
                tipo: tipo,
                monto: monto,
                motivo: motivo,
                referenciaId: referenciaId,
                usuarioId: usuarioId,
                fecha: fecha,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String cajaSesionId,
                required TipoCajaMovimiento tipo,
                required int monto,
                Value<String?> motivo = const Value.absent(),
                Value<String?> referenciaId = const Value.absent(),
                required String usuarioId,
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CajaMovimientosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                cajaSesionId: cajaSesionId,
                tipo: tipo,
                monto: monto,
                motivo: motivo,
                referenciaId: referenciaId,
                usuarioId: usuarioId,
                fecha: fecha,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CajaMovimientosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cajaSesionId = false, usuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cajaSesionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cajaSesionId,
                                referencedTable:
                                    $$CajaMovimientosTableReferences
                                        ._cajaSesionIdTable(db),
                                referencedColumn:
                                    $$CajaMovimientosTableReferences
                                        ._cajaSesionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (usuarioId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.usuarioId,
                                referencedTable:
                                    $$CajaMovimientosTableReferences
                                        ._usuarioIdTable(db),
                                referencedColumn:
                                    $$CajaMovimientosTableReferences
                                        ._usuarioIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CajaMovimientosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CajaMovimientosTable,
      CajaMovimiento,
      $$CajaMovimientosTableFilterComposer,
      $$CajaMovimientosTableOrderingComposer,
      $$CajaMovimientosTableAnnotationComposer,
      $$CajaMovimientosTableCreateCompanionBuilder,
      $$CajaMovimientosTableUpdateCompanionBuilder,
      (CajaMovimiento, $$CajaMovimientosTableReferences),
      CajaMovimiento,
      PrefetchHooks Function({bool cajaSesionId, bool usuarioId})
    >;
typedef $$ComprasTableCreateCompanionBuilder =
    ComprasCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> proveedorId,
      Value<String?> numeroFactura,
      Value<String?> fotoFacturaPath,
      required int total,
      Value<bool> pagadaDeCaja,
      required EstadoCompra estado,
      required String usuarioId,
      required DateTime fecha,
      Value<int> rowid,
    });
typedef $$ComprasTableUpdateCompanionBuilder =
    ComprasCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> proveedorId,
      Value<String?> numeroFactura,
      Value<String?> fotoFacturaPath,
      Value<int> total,
      Value<bool> pagadaDeCaja,
      Value<EstadoCompra> estado,
      Value<String> usuarioId,
      Value<DateTime> fecha,
      Value<int> rowid,
    });

final class $$ComprasTableReferences
    extends BaseReferences<_$AppDatabase, $ComprasTable, Compra> {
  $$ComprasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProveedoresTable _proveedorIdTable(_$AppDatabase db) =>
      db.proveedores.createAlias(
        $_aliasNameGenerator(db.compras.proveedorId, db.proveedores.id),
      );

  $$ProveedoresTableProcessedTableManager? get proveedorId {
    final $_column = $_itemColumn<String>('proveedor_id');
    if ($_column == null) return null;
    final manager = $$ProveedoresTableTableManager(
      $_db,
      $_db.proveedores,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_proveedorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) => db.usuarios
      .createAlias($_aliasNameGenerator(db.compras.usuarioId, db.usuarios.id));

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CompraItemsTable, List<CompraItem>>
  _compraItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.compraItems,
    aliasName: $_aliasNameGenerator(db.compras.id, db.compraItems.compraId),
  );

  $$CompraItemsTableProcessedTableManager get compraItemsRefs {
    final manager = $$CompraItemsTableTableManager(
      $_db,
      $_db.compraItems,
    ).filter((f) => f.compraId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_compraItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ComprasTableFilterComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numeroFactura => $composableBuilder(
    column: $table.numeroFactura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoFacturaPath => $composableBuilder(
    column: $table.fotoFacturaPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pagadaDeCaja => $composableBuilder(
    column: $table.pagadaDeCaja,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EstadoCompra, EstadoCompra, String>
  get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  $$ProveedoresTableFilterComposer get proveedorId {
    final $$ProveedoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.proveedorId,
      referencedTable: $db.proveedores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProveedoresTableFilterComposer(
            $db: $db,
            $table: $db.proveedores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> compraItemsRefs(
    Expression<bool> Function($$CompraItemsTableFilterComposer f) f,
  ) {
    final $$CompraItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compraItems,
      getReferencedColumn: (t) => t.compraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompraItemsTableFilterComposer(
            $db: $db,
            $table: $db.compraItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComprasTableOrderingComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numeroFactura => $composableBuilder(
    column: $table.numeroFactura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoFacturaPath => $composableBuilder(
    column: $table.fotoFacturaPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pagadaDeCaja => $composableBuilder(
    column: $table.pagadaDeCaja,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProveedoresTableOrderingComposer get proveedorId {
    final $$ProveedoresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.proveedorId,
      referencedTable: $db.proveedores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProveedoresTableOrderingComposer(
            $db: $db,
            $table: $db.proveedores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get numeroFactura => $composableBuilder(
    column: $table.numeroFactura,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoFacturaPath => $composableBuilder(
    column: $table.fotoFacturaPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<bool> get pagadaDeCaja => $composableBuilder(
    column: $table.pagadaDeCaja,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EstadoCompra, String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  $$ProveedoresTableAnnotationComposer get proveedorId {
    final $$ProveedoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.proveedorId,
      referencedTable: $db.proveedores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProveedoresTableAnnotationComposer(
            $db: $db,
            $table: $db.proveedores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> compraItemsRefs<T extends Object>(
    Expression<T> Function($$CompraItemsTableAnnotationComposer a) f,
  ) {
    final $$CompraItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compraItems,
      getReferencedColumn: (t) => t.compraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompraItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.compraItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComprasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComprasTable,
          Compra,
          $$ComprasTableFilterComposer,
          $$ComprasTableOrderingComposer,
          $$ComprasTableAnnotationComposer,
          $$ComprasTableCreateCompanionBuilder,
          $$ComprasTableUpdateCompanionBuilder,
          (Compra, $$ComprasTableReferences),
          Compra,
          PrefetchHooks Function({
            bool proveedorId,
            bool usuarioId,
            bool compraItemsRefs,
          })
        > {
  $$ComprasTableTableManager(_$AppDatabase db, $ComprasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> proveedorId = const Value.absent(),
                Value<String?> numeroFactura = const Value.absent(),
                Value<String?> fotoFacturaPath = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<bool> pagadaDeCaja = const Value.absent(),
                Value<EstadoCompra> estado = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ComprasCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                proveedorId: proveedorId,
                numeroFactura: numeroFactura,
                fotoFacturaPath: fotoFacturaPath,
                total: total,
                pagadaDeCaja: pagadaDeCaja,
                estado: estado,
                usuarioId: usuarioId,
                fecha: fecha,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> proveedorId = const Value.absent(),
                Value<String?> numeroFactura = const Value.absent(),
                Value<String?> fotoFacturaPath = const Value.absent(),
                required int total,
                Value<bool> pagadaDeCaja = const Value.absent(),
                required EstadoCompra estado,
                required String usuarioId,
                required DateTime fecha,
                Value<int> rowid = const Value.absent(),
              }) => ComprasCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                proveedorId: proveedorId,
                numeroFactura: numeroFactura,
                fotoFacturaPath: fotoFacturaPath,
                total: total,
                pagadaDeCaja: pagadaDeCaja,
                estado: estado,
                usuarioId: usuarioId,
                fecha: fecha,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComprasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                proveedorId = false,
                usuarioId = false,
                compraItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (compraItemsRefs) db.compraItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (proveedorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.proveedorId,
                                    referencedTable: $$ComprasTableReferences
                                        ._proveedorIdTable(db),
                                    referencedColumn: $$ComprasTableReferences
                                        ._proveedorIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (usuarioId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.usuarioId,
                                    referencedTable: $$ComprasTableReferences
                                        ._usuarioIdTable(db),
                                    referencedColumn: $$ComprasTableReferences
                                        ._usuarioIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (compraItemsRefs)
                        await $_getPrefetchedData<
                          Compra,
                          $ComprasTable,
                          CompraItem
                        >(
                          currentTable: table,
                          referencedTable: $$ComprasTableReferences
                              ._compraItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComprasTableReferences(
                                db,
                                table,
                                p0,
                              ).compraItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.compraId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ComprasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComprasTable,
      Compra,
      $$ComprasTableFilterComposer,
      $$ComprasTableOrderingComposer,
      $$ComprasTableAnnotationComposer,
      $$ComprasTableCreateCompanionBuilder,
      $$ComprasTableUpdateCompanionBuilder,
      (Compra, $$ComprasTableReferences),
      Compra,
      PrefetchHooks Function({
        bool proveedorId,
        bool usuarioId,
        bool compraItemsRefs,
      })
    >;
typedef $$CompraItemsTableCreateCompanionBuilder =
    CompraItemsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String compraId,
      required String productoId,
      required double cantidad,
      required int costoUnitario,
      Value<int> rowid,
    });
typedef $$CompraItemsTableUpdateCompanionBuilder =
    CompraItemsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> compraId,
      Value<String> productoId,
      Value<double> cantidad,
      Value<int> costoUnitario,
      Value<int> rowid,
    });

final class $$CompraItemsTableReferences
    extends BaseReferences<_$AppDatabase, $CompraItemsTable, CompraItem> {
  $$CompraItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ComprasTable _compraIdTable(_$AppDatabase db) =>
      db.compras.createAlias(
        $_aliasNameGenerator(db.compraItems.compraId, db.compras.id),
      );

  $$ComprasTableProcessedTableManager get compraId {
    final $_column = $_itemColumn<String>('compra_id')!;

    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_compraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductosTable _productoIdTable(_$AppDatabase db) =>
      db.productos.createAlias(
        $_aliasNameGenerator(db.compraItems.productoId, db.productos.id),
      );

  $$ProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<String>('producto_id')!;

    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CompraItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CompraItemsTable> {
  $$CompraItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnFilters(column),
  );

  $$ComprasTableFilterComposer get compraId {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompraItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompraItemsTable> {
  $$CompraItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  $$ComprasTableOrderingComposer get compraId {
    final $$ComprasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableOrderingComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompraItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompraItemsTable> {
  $$CompraItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => column,
  );

  $$ComprasTableAnnotationComposer get compraId {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compraId,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompraItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompraItemsTable,
          CompraItem,
          $$CompraItemsTableFilterComposer,
          $$CompraItemsTableOrderingComposer,
          $$CompraItemsTableAnnotationComposer,
          $$CompraItemsTableCreateCompanionBuilder,
          $$CompraItemsTableUpdateCompanionBuilder,
          (CompraItem, $$CompraItemsTableReferences),
          CompraItem,
          PrefetchHooks Function({bool compraId, bool productoId})
        > {
  $$CompraItemsTableTableManager(_$AppDatabase db, $CompraItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompraItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompraItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompraItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> compraId = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<int> costoUnitario = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompraItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                compraId: compraId,
                productoId: productoId,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String compraId,
                required String productoId,
                required double cantidad,
                required int costoUnitario,
                Value<int> rowid = const Value.absent(),
              }) => CompraItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                compraId: compraId,
                productoId: productoId,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CompraItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compraId = false, productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (compraId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.compraId,
                                referencedTable: $$CompraItemsTableReferences
                                    ._compraIdTable(db),
                                referencedColumn: $$CompraItemsTableReferences
                                    ._compraIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable: $$CompraItemsTableReferences
                                    ._productoIdTable(db),
                                referencedColumn: $$CompraItemsTableReferences
                                    ._productoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CompraItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompraItemsTable,
      CompraItem,
      $$CompraItemsTableFilterComposer,
      $$CompraItemsTableOrderingComposer,
      $$CompraItemsTableAnnotationComposer,
      $$CompraItemsTableCreateCompanionBuilder,
      $$CompraItemsTableUpdateCompanionBuilder,
      (CompraItem, $$CompraItemsTableReferences),
      CompraItem,
      PrefetchHooks Function({bool compraId, bool productoId})
    >;
typedef $$VentasTableCreateCompanionBuilder =
    VentasCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required TipoVenta tipo,
      required int total,
      required int ganancia,
      required String cajaSesionId,
      required String usuarioId,
      required EstadoVenta estado,
      Value<String?> nota,
      required DateTime fecha,
      Value<int> rowid,
    });
typedef $$VentasTableUpdateCompanionBuilder =
    VentasCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<TipoVenta> tipo,
      Value<int> total,
      Value<int> ganancia,
      Value<String> cajaSesionId,
      Value<String> usuarioId,
      Value<EstadoVenta> estado,
      Value<String?> nota,
      Value<DateTime> fecha,
      Value<int> rowid,
    });

final class $$VentasTableReferences
    extends BaseReferences<_$AppDatabase, $VentasTable, Venta> {
  $$VentasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CajaSesionesTable _cajaSesionIdTable(_$AppDatabase db) =>
      db.cajaSesiones.createAlias(
        $_aliasNameGenerator(db.ventas.cajaSesionId, db.cajaSesiones.id),
      );

  $$CajaSesionesTableProcessedTableManager get cajaSesionId {
    final $_column = $_itemColumn<String>('caja_sesion_id')!;

    final manager = $$CajaSesionesTableTableManager(
      $_db,
      $_db.cajaSesiones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cajaSesionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) => db.usuarios
      .createAlias($_aliasNameGenerator(db.ventas.usuarioId, db.usuarios.id));

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VentaItemsTable, List<VentaItem>>
  _ventaItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.ventaItems,
    aliasName: $_aliasNameGenerator(db.ventas.id, db.ventaItems.ventaId),
  );

  $$VentaItemsTableProcessedTableManager get ventaItemsRefs {
    final manager = $$VentaItemsTableTableManager(
      $_db,
      $_db.ventaItems,
    ).filter((f) => f.ventaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ventaItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VentasTableFilterComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoVenta, TipoVenta, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ganancia => $composableBuilder(
    column: $table.ganancia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EstadoVenta, EstadoVenta, String> get estado =>
      $composableBuilder(
        column: $table.estado,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  $$CajaSesionesTableFilterComposer get cajaSesionId {
    final $$CajaSesionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableFilterComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> ventaItemsRefs(
    Expression<bool> Function($$VentaItemsTableFilterComposer f) f,
  ) {
    final $$VentaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventaItems,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentaItemsTableFilterComposer(
            $db: $db,
            $table: $db.ventaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentasTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ganancia => $composableBuilder(
    column: $table.ganancia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nota => $composableBuilder(
    column: $table.nota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  $$CajaSesionesTableOrderingComposer get cajaSesionId {
    final $$CajaSesionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableOrderingComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VentasTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasTable> {
  $$VentasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoVenta, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get ganancia =>
      $composableBuilder(column: $table.ganancia, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EstadoVenta, String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<String> get nota =>
      $composableBuilder(column: $table.nota, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  $$CajaSesionesTableAnnotationComposer get cajaSesionId {
    final $$CajaSesionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableAnnotationComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> ventaItemsRefs<T extends Object>(
    Expression<T> Function($$VentaItemsTableAnnotationComposer a) f,
  ) {
    final $$VentaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ventaItems,
      getReferencedColumn: (t) => t.ventaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.ventaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VentasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasTable,
          Venta,
          $$VentasTableFilterComposer,
          $$VentasTableOrderingComposer,
          $$VentasTableAnnotationComposer,
          $$VentasTableCreateCompanionBuilder,
          $$VentasTableUpdateCompanionBuilder,
          (Venta, $$VentasTableReferences),
          Venta,
          PrefetchHooks Function({
            bool cajaSesionId,
            bool usuarioId,
            bool ventaItemsRefs,
          })
        > {
  $$VentasTableTableManager(_$AppDatabase db, $VentasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<TipoVenta> tipo = const Value.absent(),
                Value<int> total = const Value.absent(),
                Value<int> ganancia = const Value.absent(),
                Value<String> cajaSesionId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<EstadoVenta> estado = const Value.absent(),
                Value<String?> nota = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tipo: tipo,
                total: total,
                ganancia: ganancia,
                cajaSesionId: cajaSesionId,
                usuarioId: usuarioId,
                estado: estado,
                nota: nota,
                fecha: fecha,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required TipoVenta tipo,
                required int total,
                required int ganancia,
                required String cajaSesionId,
                required String usuarioId,
                required EstadoVenta estado,
                Value<String?> nota = const Value.absent(),
                required DateTime fecha,
                Value<int> rowid = const Value.absent(),
              }) => VentasCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tipo: tipo,
                total: total,
                ganancia: ganancia,
                cajaSesionId: cajaSesionId,
                usuarioId: usuarioId,
                estado: estado,
                nota: nota,
                fecha: fecha,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VentasTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cajaSesionId = false,
                usuarioId = false,
                ventaItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (ventaItemsRefs) db.ventaItems],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (cajaSesionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.cajaSesionId,
                                    referencedTable: $$VentasTableReferences
                                        ._cajaSesionIdTable(db),
                                    referencedColumn: $$VentasTableReferences
                                        ._cajaSesionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (usuarioId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.usuarioId,
                                    referencedTable: $$VentasTableReferences
                                        ._usuarioIdTable(db),
                                    referencedColumn: $$VentasTableReferences
                                        ._usuarioIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ventaItemsRefs)
                        await $_getPrefetchedData<
                          Venta,
                          $VentasTable,
                          VentaItem
                        >(
                          currentTable: table,
                          referencedTable: $$VentasTableReferences
                              ._ventaItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VentasTableReferences(
                                db,
                                table,
                                p0,
                              ).ventaItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ventaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VentasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasTable,
      Venta,
      $$VentasTableFilterComposer,
      $$VentasTableOrderingComposer,
      $$VentasTableAnnotationComposer,
      $$VentasTableCreateCompanionBuilder,
      $$VentasTableUpdateCompanionBuilder,
      (Venta, $$VentasTableReferences),
      Venta,
      PrefetchHooks Function({
        bool cajaSesionId,
        bool usuarioId,
        bool ventaItemsRefs,
      })
    >;
typedef $$VentaItemsTableCreateCompanionBuilder =
    VentaItemsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String ventaId,
      required String productoId,
      required double cantidad,
      required int precioUnitario,
      required int costoUnitario,
      Value<int> rowid,
    });
typedef $$VentaItemsTableUpdateCompanionBuilder =
    VentaItemsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> ventaId,
      Value<String> productoId,
      Value<double> cantidad,
      Value<int> precioUnitario,
      Value<int> costoUnitario,
      Value<int> rowid,
    });

final class $$VentaItemsTableReferences
    extends BaseReferences<_$AppDatabase, $VentaItemsTable, VentaItem> {
  $$VentaItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VentasTable _ventaIdTable(_$AppDatabase db) => db.ventas.createAlias(
    $_aliasNameGenerator(db.ventaItems.ventaId, db.ventas.id),
  );

  $$VentasTableProcessedTableManager get ventaId {
    final $_column = $_itemColumn<String>('venta_id')!;

    final manager = $$VentasTableTableManager(
      $_db,
      $_db.ventas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ventaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductosTable _productoIdTable(_$AppDatabase db) =>
      db.productos.createAlias(
        $_aliasNameGenerator(db.ventaItems.productoId, db.productos.id),
      );

  $$ProductosTableProcessedTableManager get productoId {
    final $_column = $_itemColumn<String>('producto_id')!;

    final manager = $$ProductosTableTableManager(
      $_db,
      $_db.productos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VentaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $VentaItemsTable> {
  $$VentaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnFilters(column),
  );

  $$VentasTableFilterComposer get ventaId {
    final $$VentasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableFilterComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableFilterComposer get productoId {
    final $$ProductosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableFilterComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VentaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $VentaItemsTable> {
  $$VentaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  $$VentasTableOrderingComposer get ventaId {
    final $$VentasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableOrderingComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableOrderingComposer get productoId {
    final $$ProductosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableOrderingComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VentaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentaItemsTable> {
  $$VentaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<double> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<int> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<int> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => column,
  );

  $$VentasTableAnnotationComposer get ventaId {
    final $$VentasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ventaId,
      referencedTable: $db.ventas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VentasTableAnnotationComposer(
            $db: $db,
            $table: $db.ventas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductosTableAnnotationComposer get productoId {
    final $$ProductosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productoId,
      referencedTable: $db.productos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductosTableAnnotationComposer(
            $db: $db,
            $table: $db.productos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VentaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentaItemsTable,
          VentaItem,
          $$VentaItemsTableFilterComposer,
          $$VentaItemsTableOrderingComposer,
          $$VentaItemsTableAnnotationComposer,
          $$VentaItemsTableCreateCompanionBuilder,
          $$VentaItemsTableUpdateCompanionBuilder,
          (VentaItem, $$VentaItemsTableReferences),
          VentaItem,
          PrefetchHooks Function({bool ventaId, bool productoId})
        > {
  $$VentaItemsTableTableManager(_$AppDatabase db, $VentaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> ventaId = const Value.absent(),
                Value<String> productoId = const Value.absent(),
                Value<double> cantidad = const Value.absent(),
                Value<int> precioUnitario = const Value.absent(),
                Value<int> costoUnitario = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentaItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                ventaId: ventaId,
                productoId: productoId,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                costoUnitario: costoUnitario,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String ventaId,
                required String productoId,
                required double cantidad,
                required int precioUnitario,
                required int costoUnitario,
                Value<int> rowid = const Value.absent(),
              }) => VentaItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                ventaId: ventaId,
                productoId: productoId,
                cantidad: cantidad,
                precioUnitario: precioUnitario,
                costoUnitario: costoUnitario,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VentaItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ventaId = false, productoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ventaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ventaId,
                                referencedTable: $$VentaItemsTableReferences
                                    ._ventaIdTable(db),
                                referencedColumn: $$VentaItemsTableReferences
                                    ._ventaIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productoId,
                                referencedTable: $$VentaItemsTableReferences
                                    ._productoIdTable(db),
                                referencedColumn: $$VentaItemsTableReferences
                                    ._productoIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VentaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentaItemsTable,
      VentaItem,
      $$VentaItemsTableFilterComposer,
      $$VentaItemsTableOrderingComposer,
      $$VentaItemsTableAnnotationComposer,
      $$VentaItemsTableCreateCompanionBuilder,
      $$VentaItemsTableUpdateCompanionBuilder,
      (VentaItem, $$VentaItemsTableReferences),
      VentaItem,
      PrefetchHooks Function({bool ventaId, bool productoId})
    >;
typedef $$GastosTableCreateCompanionBuilder =
    GastosCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String categoria,
      required String concepto,
      required DateTime fecha,
      required int monto,
      Value<String?> cajaSesionId,
      required String usuarioId,
      Value<int> rowid,
    });
typedef $$GastosTableUpdateCompanionBuilder =
    GastosCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> categoria,
      Value<String> concepto,
      Value<DateTime> fecha,
      Value<int> monto,
      Value<String?> cajaSesionId,
      Value<String> usuarioId,
      Value<int> rowid,
    });

final class $$GastosTableReferences
    extends BaseReferences<_$AppDatabase, $GastosTable, Gasto> {
  $$GastosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CajaSesionesTable _cajaSesionIdTable(_$AppDatabase db) =>
      db.cajaSesiones.createAlias(
        $_aliasNameGenerator(db.gastos.cajaSesionId, db.cajaSesiones.id),
      );

  $$CajaSesionesTableProcessedTableManager? get cajaSesionId {
    final $_column = $_itemColumn<String>('caja_sesion_id');
    if ($_column == null) return null;
    final manager = $$CajaSesionesTableTableManager(
      $_db,
      $_db.cajaSesiones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cajaSesionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) => db.usuarios
      .createAlias($_aliasNameGenerator(db.gastos.usuarioId, db.usuarios.id));

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GastosTableFilterComposer
    extends Composer<_$AppDatabase, $GastosTable> {
  $$GastosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  $$CajaSesionesTableFilterComposer get cajaSesionId {
    final $$CajaSesionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableFilterComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableOrderingComposer
    extends Composer<_$AppDatabase, $GastosTable> {
  $$GastosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  $$CajaSesionesTableOrderingComposer get cajaSesionId {
    final $$CajaSesionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableOrderingComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableAnnotationComposer
    extends Composer<_$AppDatabase, $GastosTable> {
  $$GastosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  $$CajaSesionesTableAnnotationComposer get cajaSesionId {
    final $$CajaSesionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableAnnotationComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GastosTable,
          Gasto,
          $$GastosTableFilterComposer,
          $$GastosTableOrderingComposer,
          $$GastosTableAnnotationComposer,
          $$GastosTableCreateCompanionBuilder,
          $$GastosTableUpdateCompanionBuilder,
          (Gasto, $$GastosTableReferences),
          Gasto,
          PrefetchHooks Function({bool cajaSesionId, bool usuarioId})
        > {
  $$GastosTableTableManager(_$AppDatabase db, $GastosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GastosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GastosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GastosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<String> concepto = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<String?> cajaSesionId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GastosCompanion(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                categoria: categoria,
                concepto: concepto,
                fecha: fecha,
                monto: monto,
                cajaSesionId: cajaSesionId,
                usuarioId: usuarioId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String categoria,
                required String concepto,
                required DateTime fecha,
                required int monto,
                Value<String?> cajaSesionId = const Value.absent(),
                required String usuarioId,
                Value<int> rowid = const Value.absent(),
              }) => GastosCompanion.insert(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                categoria: categoria,
                concepto: concepto,
                fecha: fecha,
                monto: monto,
                cajaSesionId: cajaSesionId,
                usuarioId: usuarioId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GastosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cajaSesionId = false, usuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cajaSesionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cajaSesionId,
                                referencedTable: $$GastosTableReferences
                                    ._cajaSesionIdTable(db),
                                referencedColumn: $$GastosTableReferences
                                    ._cajaSesionIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (usuarioId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.usuarioId,
                                referencedTable: $$GastosTableReferences
                                    ._usuarioIdTable(db),
                                referencedColumn: $$GastosTableReferences
                                    ._usuarioIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GastosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GastosTable,
      Gasto,
      $$GastosTableFilterComposer,
      $$GastosTableOrderingComposer,
      $$GastosTableAnnotationComposer,
      $$GastosTableCreateCompanionBuilder,
      $$GastosTableUpdateCompanionBuilder,
      (Gasto, $$GastosTableReferences),
      Gasto,
      PrefetchHooks Function({bool cajaSesionId, bool usuarioId})
    >;
typedef $$EmpleadosTableCreateCompanionBuilder =
    EmpleadosCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required TipoEmpleado tipo,
      Value<String?> fotoPath,
      required String nombre,
      Value<String?> cedula,
      Value<String?> direccion,
      Value<String?> telefono,
      required DateTime fechaIngreso,
      Value<bool> activo,
      Value<int?> salario,
      Value<String?> frecuenciaPago,
      Value<int> rowid,
    });
typedef $$EmpleadosTableUpdateCompanionBuilder =
    EmpleadosCompanion Function({
      Value<DateTime?> deletedAt,
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<TipoEmpleado> tipo,
      Value<String?> fotoPath,
      Value<String> nombre,
      Value<String?> cedula,
      Value<String?> direccion,
      Value<String?> telefono,
      Value<DateTime> fechaIngreso,
      Value<bool> activo,
      Value<int?> salario,
      Value<String?> frecuenciaPago,
      Value<int> rowid,
    });

final class $$EmpleadosTableReferences
    extends BaseReferences<_$AppDatabase, $EmpleadosTable, Empleado> {
  $$EmpleadosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PagosEmpleadosTable, List<PagosEmpleado>>
  _pagosEmpleadosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pagosEmpleados,
    aliasName: $_aliasNameGenerator(
      db.empleados.id,
      db.pagosEmpleados.empleadoId,
    ),
  );

  $$PagosEmpleadosTableProcessedTableManager get pagosEmpleadosRefs {
    final manager = $$PagosEmpleadosTableTableManager(
      $_db,
      $_db.pagosEmpleados,
    ).filter((f) => f.empleadoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pagosEmpleadosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EmpleadosTableFilterComposer
    extends Composer<_$AppDatabase, $EmpleadosTable> {
  $$EmpleadosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoEmpleado, TipoEmpleado, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cedula => $composableBuilder(
    column: $table.cedula,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaIngreso => $composableBuilder(
    column: $table.fechaIngreso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salario => $composableBuilder(
    column: $table.salario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frecuenciaPago => $composableBuilder(
    column: $table.frecuenciaPago,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pagosEmpleadosRefs(
    Expression<bool> Function($$PagosEmpleadosTableFilterComposer f) f,
  ) {
    final $$PagosEmpleadosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagosEmpleados,
      getReferencedColumn: (t) => t.empleadoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosEmpleadosTableFilterComposer(
            $db: $db,
            $table: $db.pagosEmpleados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmpleadosTableOrderingComposer
    extends Composer<_$AppDatabase, $EmpleadosTable> {
  $$EmpleadosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoPath => $composableBuilder(
    column: $table.fotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cedula => $composableBuilder(
    column: $table.cedula,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccion => $composableBuilder(
    column: $table.direccion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefono => $composableBuilder(
    column: $table.telefono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaIngreso => $composableBuilder(
    column: $table.fechaIngreso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salario => $composableBuilder(
    column: $table.salario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frecuenciaPago => $composableBuilder(
    column: $table.frecuenciaPago,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmpleadosTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmpleadosTable> {
  $$EmpleadosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TipoEmpleado, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get fotoPath =>
      $composableBuilder(column: $table.fotoPath, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get cedula =>
      $composableBuilder(column: $table.cedula, builder: (column) => column);

  GeneratedColumn<String> get direccion =>
      $composableBuilder(column: $table.direccion, builder: (column) => column);

  GeneratedColumn<String> get telefono =>
      $composableBuilder(column: $table.telefono, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaIngreso => $composableBuilder(
    column: $table.fechaIngreso,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<int> get salario =>
      $composableBuilder(column: $table.salario, builder: (column) => column);

  GeneratedColumn<String> get frecuenciaPago => $composableBuilder(
    column: $table.frecuenciaPago,
    builder: (column) => column,
  );

  Expression<T> pagosEmpleadosRefs<T extends Object>(
    Expression<T> Function($$PagosEmpleadosTableAnnotationComposer a) f,
  ) {
    final $$PagosEmpleadosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pagosEmpleados,
      getReferencedColumn: (t) => t.empleadoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PagosEmpleadosTableAnnotationComposer(
            $db: $db,
            $table: $db.pagosEmpleados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmpleadosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmpleadosTable,
          Empleado,
          $$EmpleadosTableFilterComposer,
          $$EmpleadosTableOrderingComposer,
          $$EmpleadosTableAnnotationComposer,
          $$EmpleadosTableCreateCompanionBuilder,
          $$EmpleadosTableUpdateCompanionBuilder,
          (Empleado, $$EmpleadosTableReferences),
          Empleado,
          PrefetchHooks Function({bool pagosEmpleadosRefs})
        > {
  $$EmpleadosTableTableManager(_$AppDatabase db, $EmpleadosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmpleadosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmpleadosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmpleadosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<TipoEmpleado> tipo = const Value.absent(),
                Value<String?> fotoPath = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> cedula = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                Value<DateTime> fechaIngreso = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<int?> salario = const Value.absent(),
                Value<String?> frecuenciaPago = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmpleadosCompanion(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tipo: tipo,
                fotoPath: fotoPath,
                nombre: nombre,
                cedula: cedula,
                direccion: direccion,
                telefono: telefono,
                fechaIngreso: fechaIngreso,
                activo: activo,
                salario: salario,
                frecuenciaPago: frecuenciaPago,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required TipoEmpleado tipo,
                Value<String?> fotoPath = const Value.absent(),
                required String nombre,
                Value<String?> cedula = const Value.absent(),
                Value<String?> direccion = const Value.absent(),
                Value<String?> telefono = const Value.absent(),
                required DateTime fechaIngreso,
                Value<bool> activo = const Value.absent(),
                Value<int?> salario = const Value.absent(),
                Value<String?> frecuenciaPago = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmpleadosCompanion.insert(
                deletedAt: deletedAt,
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tipo: tipo,
                fotoPath: fotoPath,
                nombre: nombre,
                cedula: cedula,
                direccion: direccion,
                telefono: telefono,
                fechaIngreso: fechaIngreso,
                activo: activo,
                salario: salario,
                frecuenciaPago: frecuenciaPago,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmpleadosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pagosEmpleadosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pagosEmpleadosRefs) db.pagosEmpleados,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pagosEmpleadosRefs)
                    await $_getPrefetchedData<
                      Empleado,
                      $EmpleadosTable,
                      PagosEmpleado
                    >(
                      currentTable: table,
                      referencedTable: $$EmpleadosTableReferences
                          ._pagosEmpleadosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EmpleadosTableReferences(
                            db,
                            table,
                            p0,
                          ).pagosEmpleadosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.empleadoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EmpleadosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmpleadosTable,
      Empleado,
      $$EmpleadosTableFilterComposer,
      $$EmpleadosTableOrderingComposer,
      $$EmpleadosTableAnnotationComposer,
      $$EmpleadosTableCreateCompanionBuilder,
      $$EmpleadosTableUpdateCompanionBuilder,
      (Empleado, $$EmpleadosTableReferences),
      Empleado,
      PrefetchHooks Function({bool pagosEmpleadosRefs})
    >;
typedef $$PagosEmpleadosTableCreateCompanionBuilder =
    PagosEmpleadosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String empleadoId,
      required DateTime fecha,
      required int monto,
      Value<String?> periodo,
      Value<String?> cajaSesionId,
      required String usuarioId,
      Value<int> rowid,
    });
typedef $$PagosEmpleadosTableUpdateCompanionBuilder =
    PagosEmpleadosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> empleadoId,
      Value<DateTime> fecha,
      Value<int> monto,
      Value<String?> periodo,
      Value<String?> cajaSesionId,
      Value<String> usuarioId,
      Value<int> rowid,
    });

final class $$PagosEmpleadosTableReferences
    extends BaseReferences<_$AppDatabase, $PagosEmpleadosTable, PagosEmpleado> {
  $$PagosEmpleadosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EmpleadosTable _empleadoIdTable(_$AppDatabase db) =>
      db.empleados.createAlias(
        $_aliasNameGenerator(db.pagosEmpleados.empleadoId, db.empleados.id),
      );

  $$EmpleadosTableProcessedTableManager get empleadoId {
    final $_column = $_itemColumn<String>('empleado_id')!;

    final manager = $$EmpleadosTableTableManager(
      $_db,
      $_db.empleados,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_empleadoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CajaSesionesTable _cajaSesionIdTable(_$AppDatabase db) =>
      db.cajaSesiones.createAlias(
        $_aliasNameGenerator(
          db.pagosEmpleados.cajaSesionId,
          db.cajaSesiones.id,
        ),
      );

  $$CajaSesionesTableProcessedTableManager? get cajaSesionId {
    final $_column = $_itemColumn<String>('caja_sesion_id');
    if ($_column == null) return null;
    final manager = $$CajaSesionesTableTableManager(
      $_db,
      $_db.cajaSesiones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cajaSesionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) =>
      db.usuarios.createAlias(
        $_aliasNameGenerator(db.pagosEmpleados.usuarioId, db.usuarios.id),
      );

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PagosEmpleadosTableFilterComposer
    extends Composer<_$AppDatabase, $PagosEmpleadosTable> {
  $$PagosEmpleadosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodo => $composableBuilder(
    column: $table.periodo,
    builder: (column) => ColumnFilters(column),
  );

  $$EmpleadosTableFilterComposer get empleadoId {
    final $$EmpleadosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.empleadoId,
      referencedTable: $db.empleados,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmpleadosTableFilterComposer(
            $db: $db,
            $table: $db.empleados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CajaSesionesTableFilterComposer get cajaSesionId {
    final $$CajaSesionesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableFilterComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosEmpleadosTableOrderingComposer
    extends Composer<_$AppDatabase, $PagosEmpleadosTable> {
  $$PagosEmpleadosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monto => $composableBuilder(
    column: $table.monto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodo => $composableBuilder(
    column: $table.periodo,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmpleadosTableOrderingComposer get empleadoId {
    final $$EmpleadosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.empleadoId,
      referencedTable: $db.empleados,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmpleadosTableOrderingComposer(
            $db: $db,
            $table: $db.empleados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CajaSesionesTableOrderingComposer get cajaSesionId {
    final $$CajaSesionesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableOrderingComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosEmpleadosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PagosEmpleadosTable> {
  $$PagosEmpleadosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<int> get monto =>
      $composableBuilder(column: $table.monto, builder: (column) => column);

  GeneratedColumn<String> get periodo =>
      $composableBuilder(column: $table.periodo, builder: (column) => column);

  $$EmpleadosTableAnnotationComposer get empleadoId {
    final $$EmpleadosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.empleadoId,
      referencedTable: $db.empleados,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmpleadosTableAnnotationComposer(
            $db: $db,
            $table: $db.empleados,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CajaSesionesTableAnnotationComposer get cajaSesionId {
    final $$CajaSesionesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cajaSesionId,
      referencedTable: $db.cajaSesiones,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CajaSesionesTableAnnotationComposer(
            $db: $db,
            $table: $db.cajaSesiones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PagosEmpleadosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PagosEmpleadosTable,
          PagosEmpleado,
          $$PagosEmpleadosTableFilterComposer,
          $$PagosEmpleadosTableOrderingComposer,
          $$PagosEmpleadosTableAnnotationComposer,
          $$PagosEmpleadosTableCreateCompanionBuilder,
          $$PagosEmpleadosTableUpdateCompanionBuilder,
          (PagosEmpleado, $$PagosEmpleadosTableReferences),
          PagosEmpleado,
          PrefetchHooks Function({
            bool empleadoId,
            bool cajaSesionId,
            bool usuarioId,
          })
        > {
  $$PagosEmpleadosTableTableManager(
    _$AppDatabase db,
    $PagosEmpleadosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagosEmpleadosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagosEmpleadosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagosEmpleadosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> empleadoId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> monto = const Value.absent(),
                Value<String?> periodo = const Value.absent(),
                Value<String?> cajaSesionId = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PagosEmpleadosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                empleadoId: empleadoId,
                fecha: fecha,
                monto: monto,
                periodo: periodo,
                cajaSesionId: cajaSesionId,
                usuarioId: usuarioId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String empleadoId,
                required DateTime fecha,
                required int monto,
                Value<String?> periodo = const Value.absent(),
                Value<String?> cajaSesionId = const Value.absent(),
                required String usuarioId,
                Value<int> rowid = const Value.absent(),
              }) => PagosEmpleadosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                empleadoId: empleadoId,
                fecha: fecha,
                monto: monto,
                periodo: periodo,
                cajaSesionId: cajaSesionId,
                usuarioId: usuarioId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PagosEmpleadosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({empleadoId = false, cajaSesionId = false, usuarioId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (empleadoId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.empleadoId,
                                    referencedTable:
                                        $$PagosEmpleadosTableReferences
                                            ._empleadoIdTable(db),
                                    referencedColumn:
                                        $$PagosEmpleadosTableReferences
                                            ._empleadoIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (cajaSesionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.cajaSesionId,
                                    referencedTable:
                                        $$PagosEmpleadosTableReferences
                                            ._cajaSesionIdTable(db),
                                    referencedColumn:
                                        $$PagosEmpleadosTableReferences
                                            ._cajaSesionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (usuarioId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.usuarioId,
                                    referencedTable:
                                        $$PagosEmpleadosTableReferences
                                            ._usuarioIdTable(db),
                                    referencedColumn:
                                        $$PagosEmpleadosTableReferences
                                            ._usuarioIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PagosEmpleadosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PagosEmpleadosTable,
      PagosEmpleado,
      $$PagosEmpleadosTableFilterComposer,
      $$PagosEmpleadosTableOrderingComposer,
      $$PagosEmpleadosTableAnnotationComposer,
      $$PagosEmpleadosTableCreateCompanionBuilder,
      $$PagosEmpleadosTableUpdateCompanionBuilder,
      (PagosEmpleado, $$PagosEmpleadosTableReferences),
      PagosEmpleado,
      PrefetchHooks Function({
        bool empleadoId,
        bool cajaSesionId,
        bool usuarioId,
      })
    >;
typedef $$AuditoriaTableCreateCompanionBuilder =
    AuditoriaCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String usuarioId,
      required String accion,
      required String modulo,
      Value<String?> entidadId,
      Value<String?> datosAntes,
      Value<String?> datosDespues,
      Value<DateTime> fecha,
      Value<int> rowid,
    });
typedef $$AuditoriaTableUpdateCompanionBuilder =
    AuditoriaCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> usuarioId,
      Value<String> accion,
      Value<String> modulo,
      Value<String?> entidadId,
      Value<String?> datosAntes,
      Value<String?> datosDespues,
      Value<DateTime> fecha,
      Value<int> rowid,
    });

final class $$AuditoriaTableReferences
    extends BaseReferences<_$AppDatabase, $AuditoriaTable, AuditoriaData> {
  $$AuditoriaTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsuariosTable _usuarioIdTable(_$AppDatabase db) =>
      db.usuarios.createAlias(
        $_aliasNameGenerator(db.auditoria.usuarioId, db.usuarios.id),
      );

  $$UsuariosTableProcessedTableManager get usuarioId {
    final $_column = $_itemColumn<String>('usuario_id')!;

    final manager = $$UsuariosTableTableManager(
      $_db,
      $_db.usuarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_usuarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuditoriaTableFilterComposer
    extends Composer<_$AppDatabase, $AuditoriaTable> {
  $$AuditoriaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modulo => $composableBuilder(
    column: $table.modulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entidadId => $composableBuilder(
    column: $table.entidadId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datosAntes => $composableBuilder(
    column: $table.datosAntes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datosDespues => $composableBuilder(
    column: $table.datosDespues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  $$UsuariosTableFilterComposer get usuarioId {
    final $$UsuariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableFilterComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditoriaTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditoriaTable> {
  $$AuditoriaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accion => $composableBuilder(
    column: $table.accion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modulo => $composableBuilder(
    column: $table.modulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entidadId => $composableBuilder(
    column: $table.entidadId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datosAntes => $composableBuilder(
    column: $table.datosAntes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datosDespues => $composableBuilder(
    column: $table.datosDespues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsuariosTableOrderingComposer get usuarioId {
    final $$UsuariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableOrderingComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditoriaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditoriaTable> {
  $$AuditoriaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get accion =>
      $composableBuilder(column: $table.accion, builder: (column) => column);

  GeneratedColumn<String> get modulo =>
      $composableBuilder(column: $table.modulo, builder: (column) => column);

  GeneratedColumn<String> get entidadId =>
      $composableBuilder(column: $table.entidadId, builder: (column) => column);

  GeneratedColumn<String> get datosAntes => $composableBuilder(
    column: $table.datosAntes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datosDespues => $composableBuilder(
    column: $table.datosDespues,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  $$UsuariosTableAnnotationComposer get usuarioId {
    final $$UsuariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.usuarioId,
      referencedTable: $db.usuarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsuariosTableAnnotationComposer(
            $db: $db,
            $table: $db.usuarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditoriaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditoriaTable,
          AuditoriaData,
          $$AuditoriaTableFilterComposer,
          $$AuditoriaTableOrderingComposer,
          $$AuditoriaTableAnnotationComposer,
          $$AuditoriaTableCreateCompanionBuilder,
          $$AuditoriaTableUpdateCompanionBuilder,
          (AuditoriaData, $$AuditoriaTableReferences),
          AuditoriaData,
          PrefetchHooks Function({bool usuarioId})
        > {
  $$AuditoriaTableTableManager(_$AppDatabase db, $AuditoriaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditoriaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditoriaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditoriaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> usuarioId = const Value.absent(),
                Value<String> accion = const Value.absent(),
                Value<String> modulo = const Value.absent(),
                Value<String?> entidadId = const Value.absent(),
                Value<String?> datosAntes = const Value.absent(),
                Value<String?> datosDespues = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditoriaCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                usuarioId: usuarioId,
                accion: accion,
                modulo: modulo,
                entidadId: entidadId,
                datosAntes: datosAntes,
                datosDespues: datosDespues,
                fecha: fecha,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String usuarioId,
                required String accion,
                required String modulo,
                Value<String?> entidadId = const Value.absent(),
                Value<String?> datosAntes = const Value.absent(),
                Value<String?> datosDespues = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditoriaCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                usuarioId: usuarioId,
                accion: accion,
                modulo: modulo,
                entidadId: entidadId,
                datosAntes: datosAntes,
                datosDespues: datosDespues,
                fecha: fecha,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AuditoriaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({usuarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (usuarioId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.usuarioId,
                                referencedTable: $$AuditoriaTableReferences
                                    ._usuarioIdTable(db),
                                referencedColumn: $$AuditoriaTableReferences
                                    ._usuarioIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AuditoriaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditoriaTable,
      AuditoriaData,
      $$AuditoriaTableFilterComposer,
      $$AuditoriaTableOrderingComposer,
      $$AuditoriaTableAnnotationComposer,
      $$AuditoriaTableCreateCompanionBuilder,
      $$AuditoriaTableUpdateCompanionBuilder,
      (AuditoriaData, $$AuditoriaTableReferences),
      AuditoriaData,
      PrefetchHooks Function({bool usuarioId})
    >;
typedef $$RespaldosTableCreateCompanionBuilder =
    RespaldosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required DateTime fecha,
      required String archivo,
      required int tamanoBytes,
      required TipoRespaldo tipo,
      required String resultado,
      Value<int> rowid,
    });
typedef $$RespaldosTableUpdateCompanionBuilder =
    RespaldosCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime> fecha,
      Value<String> archivo,
      Value<int> tamanoBytes,
      Value<TipoRespaldo> tipo,
      Value<String> resultado,
      Value<int> rowid,
    });

class $$RespaldosTableFilterComposer
    extends Composer<_$AppDatabase, $RespaldosTable> {
  $$RespaldosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivo => $composableBuilder(
    column: $table.archivo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tamanoBytes => $composableBuilder(
    column: $table.tamanoBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TipoRespaldo, TipoRespaldo, String> get tipo =>
      $composableBuilder(
        column: $table.tipo,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get resultado => $composableBuilder(
    column: $table.resultado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RespaldosTableOrderingComposer
    extends Composer<_$AppDatabase, $RespaldosTable> {
  $$RespaldosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivo => $composableBuilder(
    column: $table.archivo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tamanoBytes => $composableBuilder(
    column: $table.tamanoBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultado => $composableBuilder(
    column: $table.resultado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RespaldosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RespaldosTable> {
  $$RespaldosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get archivo =>
      $composableBuilder(column: $table.archivo, builder: (column) => column);

  GeneratedColumn<int> get tamanoBytes => $composableBuilder(
    column: $table.tamanoBytes,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TipoRespaldo, String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get resultado =>
      $composableBuilder(column: $table.resultado, builder: (column) => column);
}

class $$RespaldosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RespaldosTable,
          Respaldo,
          $$RespaldosTableFilterComposer,
          $$RespaldosTableOrderingComposer,
          $$RespaldosTableAnnotationComposer,
          $$RespaldosTableCreateCompanionBuilder,
          $$RespaldosTableUpdateCompanionBuilder,
          (Respaldo, BaseReferences<_$AppDatabase, $RespaldosTable, Respaldo>),
          Respaldo,
          PrefetchHooks Function()
        > {
  $$RespaldosTableTableManager(_$AppDatabase db, $RespaldosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RespaldosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RespaldosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RespaldosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String> archivo = const Value.absent(),
                Value<int> tamanoBytes = const Value.absent(),
                Value<TipoRespaldo> tipo = const Value.absent(),
                Value<String> resultado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RespaldosCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fecha: fecha,
                archivo: archivo,
                tamanoBytes: tamanoBytes,
                tipo: tipo,
                resultado: resultado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required DateTime fecha,
                required String archivo,
                required int tamanoBytes,
                required TipoRespaldo tipo,
                required String resultado,
                Value<int> rowid = const Value.absent(),
              }) => RespaldosCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fecha: fecha,
                archivo: archivo,
                tamanoBytes: tamanoBytes,
                tipo: tipo,
                resultado: resultado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RespaldosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RespaldosTable,
      Respaldo,
      $$RespaldosTableFilterComposer,
      $$RespaldosTableOrderingComposer,
      $$RespaldosTableAnnotationComposer,
      $$RespaldosTableCreateCompanionBuilder,
      $$RespaldosTableUpdateCompanionBuilder,
      (Respaldo, BaseReferences<_$AppDatabase, $RespaldosTable, Respaldo>),
      Respaldo,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      required String tabla,
      required String registroId,
      required OperacionSync operacion,
      required String payload,
      required EstadoSync estado,
      Value<int> intentos,
      Value<int> rowid,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> tabla,
      Value<String> registroId,
      Value<OperacionSync> operacion,
      Value<String> payload,
      Value<EstadoSync> estado,
      Value<int> intentos,
      Value<int> rowid,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tabla => $composableBuilder(
    column: $table.tabla,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OperacionSync, OperacionSync, String>
  get operacion => $composableBuilder(
    column: $table.operacion,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EstadoSync, EstadoSync, String> get estado =>
      $composableBuilder(
        column: $table.estado,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tabla => $composableBuilder(
    column: $table.tabla,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operacion => $composableBuilder(
    column: $table.operacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intentos => $composableBuilder(
    column: $table.intentos,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get tabla =>
      $composableBuilder(column: $table.tabla, builder: (column) => column);

  GeneratedColumn<String> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<OperacionSync, String> get operacion =>
      $composableBuilder(column: $table.operacion, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EstadoSync, String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get intentos =>
      $composableBuilder(column: $table.intentos, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> tabla = const Value.absent(),
                Value<String> registroId = const Value.absent(),
                Value<OperacionSync> operacion = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<EstadoSync> estado = const Value.absent(),
                Value<int> intentos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tabla: tabla,
                registroId: registroId,
                operacion: operacion,
                payload: payload,
                estado: estado,
                intentos: intentos,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                required String tabla,
                required String registroId,
                required OperacionSync operacion,
                required String payload,
                required EstadoSync estado,
                Value<int> intentos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                tabla: tabla,
                registroId: registroId,
                operacion: operacion,
                payload: payload,
                estado: estado,
                intentos: intentos,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NegociosTableTableManager get negocios =>
      $$NegociosTableTableManager(_db, _db.negocios);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
  $$LicenciasCacheTableTableManager get licenciasCache =>
      $$LicenciasCacheTableTableManager(_db, _db.licenciasCache);
  $$ConfiguracionesTableTableManager get configuraciones =>
      $$ConfiguracionesTableTableManager(_db, _db.configuraciones);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$HistorialPreciosTableTableManager get historialPrecios =>
      $$HistorialPreciosTableTableManager(_db, _db.historialPrecios);
  $$ProveedoresTableTableManager get proveedores =>
      $$ProveedoresTableTableManager(_db, _db.proveedores);
  $$MovimientosInventarioTableTableManager get movimientosInventario =>
      $$MovimientosInventarioTableTableManager(_db, _db.movimientosInventario);
  $$CajaSesionesTableTableManager get cajaSesiones =>
      $$CajaSesionesTableTableManager(_db, _db.cajaSesiones);
  $$CajaMovimientosTableTableManager get cajaMovimientos =>
      $$CajaMovimientosTableTableManager(_db, _db.cajaMovimientos);
  $$ComprasTableTableManager get compras =>
      $$ComprasTableTableManager(_db, _db.compras);
  $$CompraItemsTableTableManager get compraItems =>
      $$CompraItemsTableTableManager(_db, _db.compraItems);
  $$VentasTableTableManager get ventas =>
      $$VentasTableTableManager(_db, _db.ventas);
  $$VentaItemsTableTableManager get ventaItems =>
      $$VentaItemsTableTableManager(_db, _db.ventaItems);
  $$GastosTableTableManager get gastos =>
      $$GastosTableTableManager(_db, _db.gastos);
  $$EmpleadosTableTableManager get empleados =>
      $$EmpleadosTableTableManager(_db, _db.empleados);
  $$PagosEmpleadosTableTableManager get pagosEmpleados =>
      $$PagosEmpleadosTableTableManager(_db, _db.pagosEmpleados);
  $$AuditoriaTableTableManager get auditoria =>
      $$AuditoriaTableTableManager(_db, _db.auditoria);
  $$RespaldosTableTableManager get respaldos =>
      $$RespaldosTableTableManager(_db, _db.respaldos);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
