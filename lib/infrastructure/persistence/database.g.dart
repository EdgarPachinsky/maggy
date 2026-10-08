// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppsTable extends Apps with TableInfo<$AppsTable, App> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bundleIdentifierMeta = const VerificationMeta(
    'bundleIdentifier',
  );
  @override
  late final GeneratedColumn<String> bundleIdentifier = GeneratedColumn<String>(
    'bundle_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appPathMeta = const VerificationMeta(
    'appPath',
  );
  @override
  late final GeneratedColumn<String> appPath = GeneratedColumn<String>(
    'app_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconPathMeta = const VerificationMeta(
    'iconPath',
  );
  @override
  late final GeneratedColumn<String> iconPath = GeneratedColumn<String>(
    'icon_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _executablePathMeta = const VerificationMeta(
    'executablePath',
  );
  @override
  late final GeneratedColumn<String> executablePath = GeneratedColumn<String>(
    'executable_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adapterIDMeta = const VerificationMeta(
    'adapterID',
  );
  @override
  late final GeneratedColumn<String> adapterID = GeneratedColumn<String>(
    'adapter_i_d',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _compatibilityStatusMeta =
      const VerificationMeta('compatibilityStatus');
  @override
  late final GeneratedColumn<String> compatibilityStatus =
      GeneratedColumn<String>(
        'compatibility_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('unknown'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    bundleIdentifier,
    displayName,
    appPath,
    version,
    iconPath,
    executablePath,
    adapterID,
    compatibilityStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<App> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bundle_identifier')) {
      context.handle(
        _bundleIdentifierMeta,
        bundleIdentifier.isAcceptableOrUnknown(
          data['bundle_identifier']!,
          _bundleIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bundleIdentifierMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('app_path')) {
      context.handle(
        _appPathMeta,
        appPath.isAcceptableOrUnknown(data['app_path']!, _appPathMeta),
      );
    } else if (isInserting) {
      context.missing(_appPathMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('icon_path')) {
      context.handle(
        _iconPathMeta,
        iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta),
      );
    }
    if (data.containsKey('executable_path')) {
      context.handle(
        _executablePathMeta,
        executablePath.isAcceptableOrUnknown(
          data['executable_path']!,
          _executablePathMeta,
        ),
      );
    }
    if (data.containsKey('adapter_i_d')) {
      context.handle(
        _adapterIDMeta,
        adapterID.isAcceptableOrUnknown(data['adapter_i_d']!, _adapterIDMeta),
      );
    }
    if (data.containsKey('compatibility_status')) {
      context.handle(
        _compatibilityStatusMeta,
        compatibilityStatus.isAcceptableOrUnknown(
          data['compatibility_status']!,
          _compatibilityStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bundleIdentifier};
  @override
  App map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return App(
      bundleIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_identifier'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      appPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_path'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      ),
      iconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_path'],
      ),
      executablePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}executable_path'],
      ),
      adapterID: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adapter_i_d'],
      ),
      compatibilityStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compatibility_status'],
      )!,
    );
  }

  @override
  $AppsTable createAlias(String alias) {
    return $AppsTable(attachedDatabase, alias);
  }
}

class App extends DataClass implements Insertable<App> {
  final String bundleIdentifier;
  final String displayName;
  final String appPath;
  final String? version;
  final String? iconPath;
  final String? executablePath;
  final String? adapterID;
  final String compatibilityStatus;
  const App({
    required this.bundleIdentifier,
    required this.displayName,
    required this.appPath,
    this.version,
    this.iconPath,
    this.executablePath,
    this.adapterID,
    required this.compatibilityStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bundle_identifier'] = Variable<String>(bundleIdentifier);
    map['display_name'] = Variable<String>(displayName);
    map['app_path'] = Variable<String>(appPath);
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<String>(version);
    }
    if (!nullToAbsent || iconPath != null) {
      map['icon_path'] = Variable<String>(iconPath);
    }
    if (!nullToAbsent || executablePath != null) {
      map['executable_path'] = Variable<String>(executablePath);
    }
    if (!nullToAbsent || adapterID != null) {
      map['adapter_i_d'] = Variable<String>(adapterID);
    }
    map['compatibility_status'] = Variable<String>(compatibilityStatus);
    return map;
  }

  AppsCompanion toCompanion(bool nullToAbsent) {
    return AppsCompanion(
      bundleIdentifier: Value(bundleIdentifier),
      displayName: Value(displayName),
      appPath: Value(appPath),
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      iconPath: iconPath == null && nullToAbsent
          ? const Value.absent()
          : Value(iconPath),
      executablePath: executablePath == null && nullToAbsent
          ? const Value.absent()
          : Value(executablePath),
      adapterID: adapterID == null && nullToAbsent
          ? const Value.absent()
          : Value(adapterID),
      compatibilityStatus: Value(compatibilityStatus),
    );
  }

  factory App.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return App(
      bundleIdentifier: serializer.fromJson<String>(json['bundleIdentifier']),
      displayName: serializer.fromJson<String>(json['displayName']),
      appPath: serializer.fromJson<String>(json['appPath']),
      version: serializer.fromJson<String?>(json['version']),
      iconPath: serializer.fromJson<String?>(json['iconPath']),
      executablePath: serializer.fromJson<String?>(json['executablePath']),
      adapterID: serializer.fromJson<String?>(json['adapterID']),
      compatibilityStatus: serializer.fromJson<String>(
        json['compatibilityStatus'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bundleIdentifier': serializer.toJson<String>(bundleIdentifier),
      'displayName': serializer.toJson<String>(displayName),
      'appPath': serializer.toJson<String>(appPath),
      'version': serializer.toJson<String?>(version),
      'iconPath': serializer.toJson<String?>(iconPath),
      'executablePath': serializer.toJson<String?>(executablePath),
      'adapterID': serializer.toJson<String?>(adapterID),
      'compatibilityStatus': serializer.toJson<String>(compatibilityStatus),
    };
  }

  App copyWith({
    String? bundleIdentifier,
    String? displayName,
    String? appPath,
    Value<String?> version = const Value.absent(),
    Value<String?> iconPath = const Value.absent(),
    Value<String?> executablePath = const Value.absent(),
    Value<String?> adapterID = const Value.absent(),
    String? compatibilityStatus,
  }) => App(
    bundleIdentifier: bundleIdentifier ?? this.bundleIdentifier,
    displayName: displayName ?? this.displayName,
    appPath: appPath ?? this.appPath,
    version: version.present ? version.value : this.version,
    iconPath: iconPath.present ? iconPath.value : this.iconPath,
    executablePath: executablePath.present
        ? executablePath.value
        : this.executablePath,
    adapterID: adapterID.present ? adapterID.value : this.adapterID,
    compatibilityStatus: compatibilityStatus ?? this.compatibilityStatus,
  );
  App copyWithCompanion(AppsCompanion data) {
    return App(
      bundleIdentifier: data.bundleIdentifier.present
          ? data.bundleIdentifier.value
          : this.bundleIdentifier,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      appPath: data.appPath.present ? data.appPath.value : this.appPath,
      version: data.version.present ? data.version.value : this.version,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
      executablePath: data.executablePath.present
          ? data.executablePath.value
          : this.executablePath,
      adapterID: data.adapterID.present ? data.adapterID.value : this.adapterID,
      compatibilityStatus: data.compatibilityStatus.present
          ? data.compatibilityStatus.value
          : this.compatibilityStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('App(')
          ..write('bundleIdentifier: $bundleIdentifier, ')
          ..write('displayName: $displayName, ')
          ..write('appPath: $appPath, ')
          ..write('version: $version, ')
          ..write('iconPath: $iconPath, ')
          ..write('executablePath: $executablePath, ')
          ..write('adapterID: $adapterID, ')
          ..write('compatibilityStatus: $compatibilityStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    bundleIdentifier,
    displayName,
    appPath,
    version,
    iconPath,
    executablePath,
    adapterID,
    compatibilityStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is App &&
          other.bundleIdentifier == this.bundleIdentifier &&
          other.displayName == this.displayName &&
          other.appPath == this.appPath &&
          other.version == this.version &&
          other.iconPath == this.iconPath &&
          other.executablePath == this.executablePath &&
          other.adapterID == this.adapterID &&
          other.compatibilityStatus == this.compatibilityStatus);
}

class AppsCompanion extends UpdateCompanion<App> {
  final Value<String> bundleIdentifier;
  final Value<String> displayName;
  final Value<String> appPath;
  final Value<String?> version;
  final Value<String?> iconPath;
  final Value<String?> executablePath;
  final Value<String?> adapterID;
  final Value<String> compatibilityStatus;
  final Value<int> rowid;
  const AppsCompanion({
    this.bundleIdentifier = const Value.absent(),
    this.displayName = const Value.absent(),
    this.appPath = const Value.absent(),
    this.version = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.executablePath = const Value.absent(),
    this.adapterID = const Value.absent(),
    this.compatibilityStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppsCompanion.insert({
    required String bundleIdentifier,
    required String displayName,
    required String appPath,
    this.version = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.executablePath = const Value.absent(),
    this.adapterID = const Value.absent(),
    this.compatibilityStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bundleIdentifier = Value(bundleIdentifier),
       displayName = Value(displayName),
       appPath = Value(appPath);
  static Insertable<App> custom({
    Expression<String>? bundleIdentifier,
    Expression<String>? displayName,
    Expression<String>? appPath,
    Expression<String>? version,
    Expression<String>? iconPath,
    Expression<String>? executablePath,
    Expression<String>? adapterID,
    Expression<String>? compatibilityStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bundleIdentifier != null) 'bundle_identifier': bundleIdentifier,
      if (displayName != null) 'display_name': displayName,
      if (appPath != null) 'app_path': appPath,
      if (version != null) 'version': version,
      if (iconPath != null) 'icon_path': iconPath,
      if (executablePath != null) 'executable_path': executablePath,
      if (adapterID != null) 'adapter_i_d': adapterID,
      if (compatibilityStatus != null)
        'compatibility_status': compatibilityStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppsCompanion copyWith({
    Value<String>? bundleIdentifier,
    Value<String>? displayName,
    Value<String>? appPath,
    Value<String?>? version,
    Value<String?>? iconPath,
    Value<String?>? executablePath,
    Value<String?>? adapterID,
    Value<String>? compatibilityStatus,
    Value<int>? rowid,
  }) {
    return AppsCompanion(
      bundleIdentifier: bundleIdentifier ?? this.bundleIdentifier,
      displayName: displayName ?? this.displayName,
      appPath: appPath ?? this.appPath,
      version: version ?? this.version,
      iconPath: iconPath ?? this.iconPath,
      executablePath: executablePath ?? this.executablePath,
      adapterID: adapterID ?? this.adapterID,
      compatibilityStatus: compatibilityStatus ?? this.compatibilityStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bundleIdentifier.present) {
      map['bundle_identifier'] = Variable<String>(bundleIdentifier.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (appPath.present) {
      map['app_path'] = Variable<String>(appPath.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (executablePath.present) {
      map['executable_path'] = Variable<String>(executablePath.value);
    }
    if (adapterID.present) {
      map['adapter_i_d'] = Variable<String>(adapterID.value);
    }
    if (compatibilityStatus.present) {
      map['compatibility_status'] = Variable<String>(compatibilityStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppsCompanion(')
          ..write('bundleIdentifier: $bundleIdentifier, ')
          ..write('displayName: $displayName, ')
          ..write('appPath: $appPath, ')
          ..write('version: $version, ')
          ..write('iconPath: $iconPath, ')
          ..write('executablePath: $executablePath, ')
          ..write('adapterID: $adapterID, ')
          ..write('compatibilityStatus: $compatibilityStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appBundleIdentifierMeta =
      const VerificationMeta('appBundleIdentifier');
  @override
  late final GeneratedColumn<String> appBundleIdentifier =
      GeneratedColumn<String>(
        'app_bundle_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES apps (bundle_identifier)',
        ),
      );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataDirectoryMeta = const VerificationMeta(
    'dataDirectory',
  );
  @override
  late final GeneratedColumn<String> dataDirectory = GeneratedColumn<String>(
    'data_directory',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _launchArgumentsMeta = const VerificationMeta(
    'launchArguments',
  );
  @override
  late final GeneratedColumn<String> launchArguments = GeneratedColumn<String>(
    'launch_arguments',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _environmentVariablesMeta =
      const VerificationMeta('environmentVariables');
  @override
  late final GeneratedColumn<String> environmentVariables =
      GeneratedColumn<String>(
        'environment_variables',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ready'),
  );
  static const VerificationMeta _storageBytesMeta = const VerificationMeta(
    'storageBytes',
  );
  @override
  late final GeneratedColumn<int> storageBytes = GeneratedColumn<int>(
    'storage_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adapterVersionMeta = const VerificationMeta(
    'adapterVersion',
  );
  @override
  late final GeneratedColumn<String> adapterVersion = GeneratedColumn<String>(
    'adapter_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
    'emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _launchAtLoginMeta = const VerificationMeta(
    'launchAtLogin',
  );
  @override
  late final GeneratedColumn<bool> launchAtLogin = GeneratedColumn<bool>(
    'launch_at_login',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("launch_at_login" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    appBundleIdentifier,
    name,
    createdAt,
    updatedAt,
    dataDirectory,
    launchArguments,
    environmentVariables,
    status,
    storageBytes,
    adapterVersion,
    color,
    emoji,
    launchAtLogin,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('app_bundle_identifier')) {
      context.handle(
        _appBundleIdentifierMeta,
        appBundleIdentifier.isAcceptableOrUnknown(
          data['app_bundle_identifier']!,
          _appBundleIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appBundleIdentifierMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('data_directory')) {
      context.handle(
        _dataDirectoryMeta,
        dataDirectory.isAcceptableOrUnknown(
          data['data_directory']!,
          _dataDirectoryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataDirectoryMeta);
    }
    if (data.containsKey('launch_arguments')) {
      context.handle(
        _launchArgumentsMeta,
        launchArguments.isAcceptableOrUnknown(
          data['launch_arguments']!,
          _launchArgumentsMeta,
        ),
      );
    }
    if (data.containsKey('environment_variables')) {
      context.handle(
        _environmentVariablesMeta,
        environmentVariables.isAcceptableOrUnknown(
          data['environment_variables']!,
          _environmentVariablesMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('storage_bytes')) {
      context.handle(
        _storageBytesMeta,
        storageBytes.isAcceptableOrUnknown(
          data['storage_bytes']!,
          _storageBytesMeta,
        ),
      );
    }
    if (data.containsKey('adapter_version')) {
      context.handle(
        _adapterVersionMeta,
        adapterVersion.isAcceptableOrUnknown(
          data['adapter_version']!,
          _adapterVersionMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('launch_at_login')) {
      context.handle(
        _launchAtLoginMeta,
        launchAtLogin.isAcceptableOrUnknown(
          data['launch_at_login']!,
          _launchAtLoginMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      appBundleIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_bundle_identifier'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      dataDirectory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_directory'],
      )!,
      launchArguments: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}launch_arguments'],
      )!,
      environmentVariables: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environment_variables'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      storageBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}storage_bytes'],
      ),
      adapterVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adapter_version'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emoji'],
      ),
      launchAtLogin: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}launch_at_login'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final String appBundleIdentifier;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String dataDirectory;
  final String launchArguments;
  final String environmentVariables;
  final String status;
  final int? storageBytes;
  final String? adapterVersion;

  /// Added in schema 2: profile colour (ARGB) and emoji.
  final int? color;
  final String? emoji;

  /// Added in schema 3: open this profile when the user logs in.
  final bool launchAtLogin;
  const Profile({
    required this.id,
    required this.appBundleIdentifier,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.dataDirectory,
    required this.launchArguments,
    required this.environmentVariables,
    required this.status,
    this.storageBytes,
    this.adapterVersion,
    this.color,
    this.emoji,
    required this.launchAtLogin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['app_bundle_identifier'] = Variable<String>(appBundleIdentifier);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['data_directory'] = Variable<String>(dataDirectory);
    map['launch_arguments'] = Variable<String>(launchArguments);
    map['environment_variables'] = Variable<String>(environmentVariables);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || storageBytes != null) {
      map['storage_bytes'] = Variable<int>(storageBytes);
    }
    if (!nullToAbsent || adapterVersion != null) {
      map['adapter_version'] = Variable<String>(adapterVersion);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    if (!nullToAbsent || emoji != null) {
      map['emoji'] = Variable<String>(emoji);
    }
    map['launch_at_login'] = Variable<bool>(launchAtLogin);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      appBundleIdentifier: Value(appBundleIdentifier),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      dataDirectory: Value(dataDirectory),
      launchArguments: Value(launchArguments),
      environmentVariables: Value(environmentVariables),
      status: Value(status),
      storageBytes: storageBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(storageBytes),
      adapterVersion: adapterVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(adapterVersion),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      emoji: emoji == null && nullToAbsent
          ? const Value.absent()
          : Value(emoji),
      launchAtLogin: Value(launchAtLogin),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      appBundleIdentifier: serializer.fromJson<String>(
        json['appBundleIdentifier'],
      ),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dataDirectory: serializer.fromJson<String>(json['dataDirectory']),
      launchArguments: serializer.fromJson<String>(json['launchArguments']),
      environmentVariables: serializer.fromJson<String>(
        json['environmentVariables'],
      ),
      status: serializer.fromJson<String>(json['status']),
      storageBytes: serializer.fromJson<int?>(json['storageBytes']),
      adapterVersion: serializer.fromJson<String?>(json['adapterVersion']),
      color: serializer.fromJson<int?>(json['color']),
      emoji: serializer.fromJson<String?>(json['emoji']),
      launchAtLogin: serializer.fromJson<bool>(json['launchAtLogin']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'appBundleIdentifier': serializer.toJson<String>(appBundleIdentifier),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dataDirectory': serializer.toJson<String>(dataDirectory),
      'launchArguments': serializer.toJson<String>(launchArguments),
      'environmentVariables': serializer.toJson<String>(environmentVariables),
      'status': serializer.toJson<String>(status),
      'storageBytes': serializer.toJson<int?>(storageBytes),
      'adapterVersion': serializer.toJson<String?>(adapterVersion),
      'color': serializer.toJson<int?>(color),
      'emoji': serializer.toJson<String?>(emoji),
      'launchAtLogin': serializer.toJson<bool>(launchAtLogin),
    };
  }

  Profile copyWith({
    String? id,
    String? appBundleIdentifier,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? dataDirectory,
    String? launchArguments,
    String? environmentVariables,
    String? status,
    Value<int?> storageBytes = const Value.absent(),
    Value<String?> adapterVersion = const Value.absent(),
    Value<int?> color = const Value.absent(),
    Value<String?> emoji = const Value.absent(),
    bool? launchAtLogin,
  }) => Profile(
    id: id ?? this.id,
    appBundleIdentifier: appBundleIdentifier ?? this.appBundleIdentifier,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dataDirectory: dataDirectory ?? this.dataDirectory,
    launchArguments: launchArguments ?? this.launchArguments,
    environmentVariables: environmentVariables ?? this.environmentVariables,
    status: status ?? this.status,
    storageBytes: storageBytes.present ? storageBytes.value : this.storageBytes,
    adapterVersion: adapterVersion.present
        ? adapterVersion.value
        : this.adapterVersion,
    color: color.present ? color.value : this.color,
    emoji: emoji.present ? emoji.value : this.emoji,
    launchAtLogin: launchAtLogin ?? this.launchAtLogin,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      appBundleIdentifier: data.appBundleIdentifier.present
          ? data.appBundleIdentifier.value
          : this.appBundleIdentifier,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dataDirectory: data.dataDirectory.present
          ? data.dataDirectory.value
          : this.dataDirectory,
      launchArguments: data.launchArguments.present
          ? data.launchArguments.value
          : this.launchArguments,
      environmentVariables: data.environmentVariables.present
          ? data.environmentVariables.value
          : this.environmentVariables,
      status: data.status.present ? data.status.value : this.status,
      storageBytes: data.storageBytes.present
          ? data.storageBytes.value
          : this.storageBytes,
      adapterVersion: data.adapterVersion.present
          ? data.adapterVersion.value
          : this.adapterVersion,
      color: data.color.present ? data.color.value : this.color,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      launchAtLogin: data.launchAtLogin.present
          ? data.launchAtLogin.value
          : this.launchAtLogin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('appBundleIdentifier: $appBundleIdentifier, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dataDirectory: $dataDirectory, ')
          ..write('launchArguments: $launchArguments, ')
          ..write('environmentVariables: $environmentVariables, ')
          ..write('status: $status, ')
          ..write('storageBytes: $storageBytes, ')
          ..write('adapterVersion: $adapterVersion, ')
          ..write('color: $color, ')
          ..write('emoji: $emoji, ')
          ..write('launchAtLogin: $launchAtLogin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    appBundleIdentifier,
    name,
    createdAt,
    updatedAt,
    dataDirectory,
    launchArguments,
    environmentVariables,
    status,
    storageBytes,
    adapterVersion,
    color,
    emoji,
    launchAtLogin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.appBundleIdentifier == this.appBundleIdentifier &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.dataDirectory == this.dataDirectory &&
          other.launchArguments == this.launchArguments &&
          other.environmentVariables == this.environmentVariables &&
          other.status == this.status &&
          other.storageBytes == this.storageBytes &&
          other.adapterVersion == this.adapterVersion &&
          other.color == this.color &&
          other.emoji == this.emoji &&
          other.launchAtLogin == this.launchAtLogin);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<String> appBundleIdentifier;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> dataDirectory;
  final Value<String> launchArguments;
  final Value<String> environmentVariables;
  final Value<String> status;
  final Value<int?> storageBytes;
  final Value<String?> adapterVersion;
  final Value<int?> color;
  final Value<String?> emoji;
  final Value<bool> launchAtLogin;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.appBundleIdentifier = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dataDirectory = const Value.absent(),
    this.launchArguments = const Value.absent(),
    this.environmentVariables = const Value.absent(),
    this.status = const Value.absent(),
    this.storageBytes = const Value.absent(),
    this.adapterVersion = const Value.absent(),
    this.color = const Value.absent(),
    this.emoji = const Value.absent(),
    this.launchAtLogin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required String appBundleIdentifier,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String dataDirectory,
    this.launchArguments = const Value.absent(),
    this.environmentVariables = const Value.absent(),
    this.status = const Value.absent(),
    this.storageBytes = const Value.absent(),
    this.adapterVersion = const Value.absent(),
    this.color = const Value.absent(),
    this.emoji = const Value.absent(),
    this.launchAtLogin = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       appBundleIdentifier = Value(appBundleIdentifier),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       dataDirectory = Value(dataDirectory);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<String>? appBundleIdentifier,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? dataDirectory,
    Expression<String>? launchArguments,
    Expression<String>? environmentVariables,
    Expression<String>? status,
    Expression<int>? storageBytes,
    Expression<String>? adapterVersion,
    Expression<int>? color,
    Expression<String>? emoji,
    Expression<bool>? launchAtLogin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (appBundleIdentifier != null)
        'app_bundle_identifier': appBundleIdentifier,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dataDirectory != null) 'data_directory': dataDirectory,
      if (launchArguments != null) 'launch_arguments': launchArguments,
      if (environmentVariables != null)
        'environment_variables': environmentVariables,
      if (status != null) 'status': status,
      if (storageBytes != null) 'storage_bytes': storageBytes,
      if (adapterVersion != null) 'adapter_version': adapterVersion,
      if (color != null) 'color': color,
      if (emoji != null) 'emoji': emoji,
      if (launchAtLogin != null) 'launch_at_login': launchAtLogin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? appBundleIdentifier,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? dataDirectory,
    Value<String>? launchArguments,
    Value<String>? environmentVariables,
    Value<String>? status,
    Value<int?>? storageBytes,
    Value<String?>? adapterVersion,
    Value<int?>? color,
    Value<String?>? emoji,
    Value<bool>? launchAtLogin,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      appBundleIdentifier: appBundleIdentifier ?? this.appBundleIdentifier,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dataDirectory: dataDirectory ?? this.dataDirectory,
      launchArguments: launchArguments ?? this.launchArguments,
      environmentVariables: environmentVariables ?? this.environmentVariables,
      status: status ?? this.status,
      storageBytes: storageBytes ?? this.storageBytes,
      adapterVersion: adapterVersion ?? this.adapterVersion,
      color: color ?? this.color,
      emoji: emoji ?? this.emoji,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (appBundleIdentifier.present) {
      map['app_bundle_identifier'] = Variable<String>(
        appBundleIdentifier.value,
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dataDirectory.present) {
      map['data_directory'] = Variable<String>(dataDirectory.value);
    }
    if (launchArguments.present) {
      map['launch_arguments'] = Variable<String>(launchArguments.value);
    }
    if (environmentVariables.present) {
      map['environment_variables'] = Variable<String>(
        environmentVariables.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (storageBytes.present) {
      map['storage_bytes'] = Variable<int>(storageBytes.value);
    }
    if (adapterVersion.present) {
      map['adapter_version'] = Variable<String>(adapterVersion.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (launchAtLogin.present) {
      map['launch_at_login'] = Variable<bool>(launchAtLogin.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('appBundleIdentifier: $appBundleIdentifier, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dataDirectory: $dataDirectory, ')
          ..write('launchArguments: $launchArguments, ')
          ..write('environmentVariables: $environmentVariables, ')
          ..write('status: $status, ')
          ..write('storageBytes: $storageBytes, ')
          ..write('adapterVersion: $adapterVersion, ')
          ..write('color: $color, ')
          ..write('emoji: $emoji, ')
          ..write('launchAtLogin: $launchAtLogin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PinnedAppsTable extends PinnedApps
    with TableInfo<$PinnedAppsTable, PinnedApp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PinnedAppsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bundleIdentifierMeta = const VerificationMeta(
    'bundleIdentifier',
  );
  @override
  late final GeneratedColumn<String> bundleIdentifier = GeneratedColumn<String>(
    'bundle_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinnedAtMeta = const VerificationMeta(
    'pinnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pinnedAt = GeneratedColumn<DateTime>(
    'pinned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bundleIdentifier, pinnedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pinned_apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<PinnedApp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bundle_identifier')) {
      context.handle(
        _bundleIdentifierMeta,
        bundleIdentifier.isAcceptableOrUnknown(
          data['bundle_identifier']!,
          _bundleIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bundleIdentifierMeta);
    }
    if (data.containsKey('pinned_at')) {
      context.handle(
        _pinnedAtMeta,
        pinnedAt.isAcceptableOrUnknown(data['pinned_at']!, _pinnedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_pinnedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bundleIdentifier};
  @override
  PinnedApp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PinnedApp(
      bundleIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_identifier'],
      )!,
      pinnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pinned_at'],
      )!,
    );
  }

  @override
  $PinnedAppsTable createAlias(String alias) {
    return $PinnedAppsTable(attachedDatabase, alias);
  }
}

class PinnedApp extends DataClass implements Insertable<PinnedApp> {
  final String bundleIdentifier;
  final DateTime pinnedAt;
  const PinnedApp({required this.bundleIdentifier, required this.pinnedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bundle_identifier'] = Variable<String>(bundleIdentifier);
    map['pinned_at'] = Variable<DateTime>(pinnedAt);
    return map;
  }

  PinnedAppsCompanion toCompanion(bool nullToAbsent) {
    return PinnedAppsCompanion(
      bundleIdentifier: Value(bundleIdentifier),
      pinnedAt: Value(pinnedAt),
    );
  }

  factory PinnedApp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PinnedApp(
      bundleIdentifier: serializer.fromJson<String>(json['bundleIdentifier']),
      pinnedAt: serializer.fromJson<DateTime>(json['pinnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bundleIdentifier': serializer.toJson<String>(bundleIdentifier),
      'pinnedAt': serializer.toJson<DateTime>(pinnedAt),
    };
  }

  PinnedApp copyWith({String? bundleIdentifier, DateTime? pinnedAt}) =>
      PinnedApp(
        bundleIdentifier: bundleIdentifier ?? this.bundleIdentifier,
        pinnedAt: pinnedAt ?? this.pinnedAt,
      );
  PinnedApp copyWithCompanion(PinnedAppsCompanion data) {
    return PinnedApp(
      bundleIdentifier: data.bundleIdentifier.present
          ? data.bundleIdentifier.value
          : this.bundleIdentifier,
      pinnedAt: data.pinnedAt.present ? data.pinnedAt.value : this.pinnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PinnedApp(')
          ..write('bundleIdentifier: $bundleIdentifier, ')
          ..write('pinnedAt: $pinnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bundleIdentifier, pinnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PinnedApp &&
          other.bundleIdentifier == this.bundleIdentifier &&
          other.pinnedAt == this.pinnedAt);
}

class PinnedAppsCompanion extends UpdateCompanion<PinnedApp> {
  final Value<String> bundleIdentifier;
  final Value<DateTime> pinnedAt;
  final Value<int> rowid;
  const PinnedAppsCompanion({
    this.bundleIdentifier = const Value.absent(),
    this.pinnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PinnedAppsCompanion.insert({
    required String bundleIdentifier,
    required DateTime pinnedAt,
    this.rowid = const Value.absent(),
  }) : bundleIdentifier = Value(bundleIdentifier),
       pinnedAt = Value(pinnedAt);
  static Insertable<PinnedApp> custom({
    Expression<String>? bundleIdentifier,
    Expression<DateTime>? pinnedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bundleIdentifier != null) 'bundle_identifier': bundleIdentifier,
      if (pinnedAt != null) 'pinned_at': pinnedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PinnedAppsCompanion copyWith({
    Value<String>? bundleIdentifier,
    Value<DateTime>? pinnedAt,
    Value<int>? rowid,
  }) {
    return PinnedAppsCompanion(
      bundleIdentifier: bundleIdentifier ?? this.bundleIdentifier,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bundleIdentifier.present) {
      map['bundle_identifier'] = Variable<String>(bundleIdentifier.value);
    }
    if (pinnedAt.present) {
      map['pinned_at'] = Variable<DateTime>(pinnedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PinnedAppsCompanion(')
          ..write('bundleIdentifier: $bundleIdentifier, ')
          ..write('pinnedAt: $pinnedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$MagicDatabase extends GeneratedDatabase {
  _$MagicDatabase(QueryExecutor e) : super(e);
  $MagicDatabaseManager get managers => $MagicDatabaseManager(this);
  late final $AppsTable apps = $AppsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $PinnedAppsTable pinnedApps = $PinnedAppsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    apps,
    profiles,
    pinnedApps,
  ];
}

typedef $$AppsTableCreateCompanionBuilder =
    AppsCompanion Function({
      required String bundleIdentifier,
      required String displayName,
      required String appPath,
      Value<String?> version,
      Value<String?> iconPath,
      Value<String?> executablePath,
      Value<String?> adapterID,
      Value<String> compatibilityStatus,
      Value<int> rowid,
    });
typedef $$AppsTableUpdateCompanionBuilder =
    AppsCompanion Function({
      Value<String> bundleIdentifier,
      Value<String> displayName,
      Value<String> appPath,
      Value<String?> version,
      Value<String?> iconPath,
      Value<String?> executablePath,
      Value<String?> adapterID,
      Value<String> compatibilityStatus,
      Value<int> rowid,
    });

final class $$AppsTableReferences
    extends BaseReferences<_$MagicDatabase, $AppsTable, App> {
  $$AppsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfilesTable, List<Profile>> _profilesRefsTable(
    _$MagicDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.profiles,
    aliasName: $_aliasNameGenerator(
      db.apps.bundleIdentifier,
      db.profiles.appBundleIdentifier,
    ),
  );

  $$ProfilesTableProcessedTableManager get profilesRefs {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles).filter(
      (f) => f.appBundleIdentifier.bundleIdentifier.sqlEquals(
        $_itemColumn<String>('bundle_identifier')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_profilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AppsTableFilterComposer extends Composer<_$MagicDatabase, $AppsTable> {
  $$AppsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bundleIdentifier => $composableBuilder(
    column: $table.bundleIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appPath => $composableBuilder(
    column: $table.appPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get executablePath => $composableBuilder(
    column: $table.executablePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adapterID => $composableBuilder(
    column: $table.adapterID,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get compatibilityStatus => $composableBuilder(
    column: $table.compatibilityStatus,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> profilesRefs(
    Expression<bool> Function($$ProfilesTableFilterComposer f) f,
  ) {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bundleIdentifier,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.appBundleIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableFilterComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppsTableOrderingComposer
    extends Composer<_$MagicDatabase, $AppsTable> {
  $$AppsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bundleIdentifier => $composableBuilder(
    column: $table.bundleIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appPath => $composableBuilder(
    column: $table.appPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get executablePath => $composableBuilder(
    column: $table.executablePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adapterID => $composableBuilder(
    column: $table.adapterID,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compatibilityStatus => $composableBuilder(
    column: $table.compatibilityStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppsTableAnnotationComposer
    extends Composer<_$MagicDatabase, $AppsTable> {
  $$AppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bundleIdentifier => $composableBuilder(
    column: $table.bundleIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appPath =>
      $composableBuilder(column: $table.appPath, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);

  GeneratedColumn<String> get executablePath => $composableBuilder(
    column: $table.executablePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adapterID =>
      $composableBuilder(column: $table.adapterID, builder: (column) => column);

  GeneratedColumn<String> get compatibilityStatus => $composableBuilder(
    column: $table.compatibilityStatus,
    builder: (column) => column,
  );

  Expression<T> profilesRefs<T extends Object>(
    Expression<T> Function($$ProfilesTableAnnotationComposer a) f,
  ) {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bundleIdentifier,
      referencedTable: $db.profiles,
      getReferencedColumn: (t) => t.appBundleIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.profiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppsTableTableManager
    extends
        RootTableManager<
          _$MagicDatabase,
          $AppsTable,
          App,
          $$AppsTableFilterComposer,
          $$AppsTableOrderingComposer,
          $$AppsTableAnnotationComposer,
          $$AppsTableCreateCompanionBuilder,
          $$AppsTableUpdateCompanionBuilder,
          (App, $$AppsTableReferences),
          App,
          PrefetchHooks Function({bool profilesRefs})
        > {
  $$AppsTableTableManager(_$MagicDatabase db, $AppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bundleIdentifier = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> appPath = const Value.absent(),
                Value<String?> version = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<String?> executablePath = const Value.absent(),
                Value<String?> adapterID = const Value.absent(),
                Value<String> compatibilityStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppsCompanion(
                bundleIdentifier: bundleIdentifier,
                displayName: displayName,
                appPath: appPath,
                version: version,
                iconPath: iconPath,
                executablePath: executablePath,
                adapterID: adapterID,
                compatibilityStatus: compatibilityStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bundleIdentifier,
                required String displayName,
                required String appPath,
                Value<String?> version = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<String?> executablePath = const Value.absent(),
                Value<String?> adapterID = const Value.absent(),
                Value<String> compatibilityStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppsCompanion.insert(
                bundleIdentifier: bundleIdentifier,
                displayName: displayName,
                appPath: appPath,
                version: version,
                iconPath: iconPath,
                executablePath: executablePath,
                adapterID: adapterID,
                compatibilityStatus: compatibilityStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AppsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({profilesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (profilesRefs) db.profiles],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profilesRefs)
                    await $_getPrefetchedData<App, $AppsTable, Profile>(
                      currentTable: table,
                      referencedTable: $$AppsTableReferences._profilesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$AppsTableReferences(db, table, p0).profilesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) =>
                                e.appBundleIdentifier == item.bundleIdentifier,
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

typedef $$AppsTableProcessedTableManager =
    ProcessedTableManager<
      _$MagicDatabase,
      $AppsTable,
      App,
      $$AppsTableFilterComposer,
      $$AppsTableOrderingComposer,
      $$AppsTableAnnotationComposer,
      $$AppsTableCreateCompanionBuilder,
      $$AppsTableUpdateCompanionBuilder,
      (App, $$AppsTableReferences),
      App,
      PrefetchHooks Function({bool profilesRefs})
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      required String appBundleIdentifier,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String dataDirectory,
      Value<String> launchArguments,
      Value<String> environmentVariables,
      Value<String> status,
      Value<int?> storageBytes,
      Value<String?> adapterVersion,
      Value<int?> color,
      Value<String?> emoji,
      Value<bool> launchAtLogin,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String> appBundleIdentifier,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> dataDirectory,
      Value<String> launchArguments,
      Value<String> environmentVariables,
      Value<String> status,
      Value<int?> storageBytes,
      Value<String?> adapterVersion,
      Value<int?> color,
      Value<String?> emoji,
      Value<bool> launchAtLogin,
      Value<int> rowid,
    });

final class $$ProfilesTableReferences
    extends BaseReferences<_$MagicDatabase, $ProfilesTable, Profile> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppsTable _appBundleIdentifierTable(_$MagicDatabase db) =>
      db.apps.createAlias(
        $_aliasNameGenerator(
          db.profiles.appBundleIdentifier,
          db.apps.bundleIdentifier,
        ),
      );

  $$AppsTableProcessedTableManager get appBundleIdentifier {
    final $_column = $_itemColumn<String>('app_bundle_identifier')!;

    final manager = $$AppsTableTableManager(
      $_db,
      $_db.apps,
    ).filter((f) => f.bundleIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_appBundleIdentifierTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$MagicDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnFilters<String> get dataDirectory => $composableBuilder(
    column: $table.dataDirectory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get launchArguments => $composableBuilder(
    column: $table.launchArguments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get environmentVariables => $composableBuilder(
    column: $table.environmentVariables,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get storageBytes => $composableBuilder(
    column: $table.storageBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adapterVersion => $composableBuilder(
    column: $table.adapterVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnFilters(column),
  );

  $$AppsTableFilterComposer get appBundleIdentifier {
    final $$AppsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appBundleIdentifier,
      referencedTable: $db.apps,
      getReferencedColumn: (t) => t.bundleIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppsTableFilterComposer(
            $db: $db,
            $table: $db.apps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$MagicDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
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

  ColumnOrderings<String> get dataDirectory => $composableBuilder(
    column: $table.dataDirectory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get launchArguments => $composableBuilder(
    column: $table.launchArguments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get environmentVariables => $composableBuilder(
    column: $table.environmentVariables,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storageBytes => $composableBuilder(
    column: $table.storageBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adapterVersion => $composableBuilder(
    column: $table.adapterVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppsTableOrderingComposer get appBundleIdentifier {
    final $$AppsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appBundleIdentifier,
      referencedTable: $db.apps,
      getReferencedColumn: (t) => t.bundleIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppsTableOrderingComposer(
            $db: $db,
            $table: $db.apps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$MagicDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get dataDirectory => $composableBuilder(
    column: $table.dataDirectory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get launchArguments => $composableBuilder(
    column: $table.launchArguments,
    builder: (column) => column,
  );

  GeneratedColumn<String> get environmentVariables => $composableBuilder(
    column: $table.environmentVariables,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get storageBytes => $composableBuilder(
    column: $table.storageBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adapterVersion => $composableBuilder(
    column: $table.adapterVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<bool> get launchAtLogin => $composableBuilder(
    column: $table.launchAtLogin,
    builder: (column) => column,
  );

  $$AppsTableAnnotationComposer get appBundleIdentifier {
    final $$AppsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.appBundleIdentifier,
      referencedTable: $db.apps,
      getReferencedColumn: (t) => t.bundleIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppsTableAnnotationComposer(
            $db: $db,
            $table: $db.apps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$MagicDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, $$ProfilesTableReferences),
          Profile,
          PrefetchHooks Function({bool appBundleIdentifier})
        > {
  $$ProfilesTableTableManager(_$MagicDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> appBundleIdentifier = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> dataDirectory = const Value.absent(),
                Value<String> launchArguments = const Value.absent(),
                Value<String> environmentVariables = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> storageBytes = const Value.absent(),
                Value<String?> adapterVersion = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<bool> launchAtLogin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                appBundleIdentifier: appBundleIdentifier,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dataDirectory: dataDirectory,
                launchArguments: launchArguments,
                environmentVariables: environmentVariables,
                status: status,
                storageBytes: storageBytes,
                adapterVersion: adapterVersion,
                color: color,
                emoji: emoji,
                launchAtLogin: launchAtLogin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String appBundleIdentifier,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String dataDirectory,
                Value<String> launchArguments = const Value.absent(),
                Value<String> environmentVariables = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> storageBytes = const Value.absent(),
                Value<String?> adapterVersion = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> emoji = const Value.absent(),
                Value<bool> launchAtLogin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                appBundleIdentifier: appBundleIdentifier,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                dataDirectory: dataDirectory,
                launchArguments: launchArguments,
                environmentVariables: environmentVariables,
                status: status,
                storageBytes: storageBytes,
                adapterVersion: adapterVersion,
                color: color,
                emoji: emoji,
                launchAtLogin: launchAtLogin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({appBundleIdentifier = false}) {
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
                    if (appBundleIdentifier) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.appBundleIdentifier,
                                referencedTable: $$ProfilesTableReferences
                                    ._appBundleIdentifierTable(db),
                                referencedColumn: $$ProfilesTableReferences
                                    ._appBundleIdentifierTable(db)
                                    .bundleIdentifier,
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

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$MagicDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, $$ProfilesTableReferences),
      Profile,
      PrefetchHooks Function({bool appBundleIdentifier})
    >;
typedef $$PinnedAppsTableCreateCompanionBuilder =
    PinnedAppsCompanion Function({
      required String bundleIdentifier,
      required DateTime pinnedAt,
      Value<int> rowid,
    });
typedef $$PinnedAppsTableUpdateCompanionBuilder =
    PinnedAppsCompanion Function({
      Value<String> bundleIdentifier,
      Value<DateTime> pinnedAt,
      Value<int> rowid,
    });

class $$PinnedAppsTableFilterComposer
    extends Composer<_$MagicDatabase, $PinnedAppsTable> {
  $$PinnedAppsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bundleIdentifier => $composableBuilder(
    column: $table.bundleIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PinnedAppsTableOrderingComposer
    extends Composer<_$MagicDatabase, $PinnedAppsTable> {
  $$PinnedAppsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bundleIdentifier => $composableBuilder(
    column: $table.bundleIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pinnedAt => $composableBuilder(
    column: $table.pinnedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PinnedAppsTableAnnotationComposer
    extends Composer<_$MagicDatabase, $PinnedAppsTable> {
  $$PinnedAppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bundleIdentifier => $composableBuilder(
    column: $table.bundleIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pinnedAt =>
      $composableBuilder(column: $table.pinnedAt, builder: (column) => column);
}

class $$PinnedAppsTableTableManager
    extends
        RootTableManager<
          _$MagicDatabase,
          $PinnedAppsTable,
          PinnedApp,
          $$PinnedAppsTableFilterComposer,
          $$PinnedAppsTableOrderingComposer,
          $$PinnedAppsTableAnnotationComposer,
          $$PinnedAppsTableCreateCompanionBuilder,
          $$PinnedAppsTableUpdateCompanionBuilder,
          (
            PinnedApp,
            BaseReferences<_$MagicDatabase, $PinnedAppsTable, PinnedApp>,
          ),
          PinnedApp,
          PrefetchHooks Function()
        > {
  $$PinnedAppsTableTableManager(_$MagicDatabase db, $PinnedAppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PinnedAppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PinnedAppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PinnedAppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bundleIdentifier = const Value.absent(),
                Value<DateTime> pinnedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PinnedAppsCompanion(
                bundleIdentifier: bundleIdentifier,
                pinnedAt: pinnedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bundleIdentifier,
                required DateTime pinnedAt,
                Value<int> rowid = const Value.absent(),
              }) => PinnedAppsCompanion.insert(
                bundleIdentifier: bundleIdentifier,
                pinnedAt: pinnedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PinnedAppsTableProcessedTableManager =
    ProcessedTableManager<
      _$MagicDatabase,
      $PinnedAppsTable,
      PinnedApp,
      $$PinnedAppsTableFilterComposer,
      $$PinnedAppsTableOrderingComposer,
      $$PinnedAppsTableAnnotationComposer,
      $$PinnedAppsTableCreateCompanionBuilder,
      $$PinnedAppsTableUpdateCompanionBuilder,
      (PinnedApp, BaseReferences<_$MagicDatabase, $PinnedAppsTable, PinnedApp>),
      PinnedApp,
      PrefetchHooks Function()
    >;

class $MagicDatabaseManager {
  final _$MagicDatabase _db;
  $MagicDatabaseManager(this._db);
  $$AppsTableTableManager get apps => $$AppsTableTableManager(_db, _db.apps);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$PinnedAppsTableTableManager get pinnedApps =>
      $$PinnedAppsTableTableManager(_db, _db.pinnedApps);
}
