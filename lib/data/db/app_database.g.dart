// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#FF5A1F'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    iconKey,
    colorHex,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final String description;

  /// Clave del icono. Se guarda el nombre y no el codigo numerico porque
  /// Flutter necesita iconos constantes para poder optimizar el tamano final.
  final String iconKey;

  /// Color en formato hexadecimal, por ejemplo `#E03131`.
  final String colorHex;
  final int sortOrder;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.description,
    required this.iconKey,
    required this.colorHex,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['icon_key'] = Variable<String>(iconKey);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      iconKey: Value(iconKey),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    String? description,
    String? iconKey,
    String? colorHex,
    int? sortOrder,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    iconKey: iconKey ?? this.iconKey,
    colorHex: colorHex ?? this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, iconKey, colorHex, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.iconKey == this.iconKey &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> iconKey;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? iconKey,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? iconKey,
    Value<String>? colorHex,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PartBrandsTable extends PartBrands
    with TableInfo<$PartBrandsTable, PartBrandRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartBrandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('homologada'),
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, country, tier, logoUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'part_brands';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartBrandRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartBrandRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartBrandRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tier'],
      )!,
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
    );
  }

  @override
  $PartBrandsTable createAlias(String alias) {
    return $PartBrandsTable(attachedDatabase, alias);
  }
}

class PartBrandRow extends DataClass implements Insertable<PartBrandRow> {
  final String id;
  final String name;
  final String country;

  /// `original`, `homologada` o `alternativa`.
  final String tier;
  final String? logoUrl;
  const PartBrandRow({
    required this.id,
    required this.name,
    required this.country,
    required this.tier,
    this.logoUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['country'] = Variable<String>(country);
    map['tier'] = Variable<String>(tier);
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    return map;
  }

  PartBrandsCompanion toCompanion(bool nullToAbsent) {
    return PartBrandsCompanion(
      id: Value(id),
      name: Value(name),
      country: Value(country),
      tier: Value(tier),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
    );
  }

  factory PartBrandRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartBrandRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      country: serializer.fromJson<String>(json['country']),
      tier: serializer.fromJson<String>(json['tier']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'country': serializer.toJson<String>(country),
      'tier': serializer.toJson<String>(tier),
      'logoUrl': serializer.toJson<String?>(logoUrl),
    };
  }

  PartBrandRow copyWith({
    String? id,
    String? name,
    String? country,
    String? tier,
    Value<String?> logoUrl = const Value.absent(),
  }) => PartBrandRow(
    id: id ?? this.id,
    name: name ?? this.name,
    country: country ?? this.country,
    tier: tier ?? this.tier,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
  );
  PartBrandRow copyWithCompanion(PartBrandsCompanion data) {
    return PartBrandRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      country: data.country.present ? data.country.value : this.country,
      tier: data.tier.present ? data.tier.value : this.tier,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartBrandRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country, ')
          ..write('tier: $tier, ')
          ..write('logoUrl: $logoUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, country, tier, logoUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartBrandRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.country == this.country &&
          other.tier == this.tier &&
          other.logoUrl == this.logoUrl);
}

class PartBrandsCompanion extends UpdateCompanion<PartBrandRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> country;
  final Value<String> tier;
  final Value<String?> logoUrl;
  final Value<int> rowid;
  const PartBrandsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.country = const Value.absent(),
    this.tier = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PartBrandsCompanion.insert({
    required String id,
    required String name,
    this.country = const Value.absent(),
    this.tier = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<PartBrandRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? country,
    Expression<String>? tier,
    Expression<String>? logoUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (country != null) 'country': country,
      if (tier != null) 'tier': tier,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PartBrandsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? country,
    Value<String>? tier,
    Value<String?>? logoUrl,
    Value<int>? rowid,
  }) {
    return PartBrandsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      tier: tier ?? this.tier,
      logoUrl: logoUrl ?? this.logoUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartBrandsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country, ')
          ..write('tier: $tier, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehicleMakesTable extends VehicleMakes
    with TableInfo<$VehicleMakesTable, VehicleMakeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleMakesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, country];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_makes';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleMakeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleMakeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleMakeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
    );
  }

  @override
  $VehicleMakesTable createAlias(String alias) {
    return $VehicleMakesTable(attachedDatabase, alias);
  }
}

class VehicleMakeRow extends DataClass implements Insertable<VehicleMakeRow> {
  final String id;
  final String name;
  final String country;
  const VehicleMakeRow({
    required this.id,
    required this.name,
    required this.country,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['country'] = Variable<String>(country);
    return map;
  }

  VehicleMakesCompanion toCompanion(bool nullToAbsent) {
    return VehicleMakesCompanion(
      id: Value(id),
      name: Value(name),
      country: Value(country),
    );
  }

  factory VehicleMakeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleMakeRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      country: serializer.fromJson<String>(json['country']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'country': serializer.toJson<String>(country),
    };
  }

  VehicleMakeRow copyWith({String? id, String? name, String? country}) =>
      VehicleMakeRow(
        id: id ?? this.id,
        name: name ?? this.name,
        country: country ?? this.country,
      );
  VehicleMakeRow copyWithCompanion(VehicleMakesCompanion data) {
    return VehicleMakeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      country: data.country.present ? data.country.value : this.country,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleMakeRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, country);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleMakeRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.country == this.country);
}

class VehicleMakesCompanion extends UpdateCompanion<VehicleMakeRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> country;
  final Value<int> rowid;
  const VehicleMakesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.country = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleMakesCompanion.insert({
    required String id,
    required String name,
    this.country = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<VehicleMakeRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? country,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (country != null) 'country': country,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleMakesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? country,
    Value<int>? rowid,
  }) {
    return VehicleMakesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleMakesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('country: $country, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehicleModelsTable extends VehicleModels
    with TableInfo<$VehicleModelsTable, VehicleModelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehicleModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _makeIdMeta = const VerificationMeta('makeId');
  @override
  late final GeneratedColumn<String> makeId = GeneratedColumn<String>(
    'make_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicle_makes (id) ON DELETE CASCADE',
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
  static const VerificationMeta _bodyTypeMeta = const VerificationMeta(
    'bodyType',
  );
  @override
  late final GeneratedColumn<String> bodyType = GeneratedColumn<String>(
    'body_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearFromMeta = const VerificationMeta(
    'yearFrom',
  );
  @override
  late final GeneratedColumn<int> yearFrom = GeneratedColumn<int>(
    'year_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearToMeta = const VerificationMeta('yearTo');
  @override
  late final GeneratedColumn<int> yearTo = GeneratedColumn<int>(
    'year_to',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    makeId,
    name,
    bodyType,
    yearFrom,
    yearTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicle_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<VehicleModelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('make_id')) {
      context.handle(
        _makeIdMeta,
        makeId.isAcceptableOrUnknown(data['make_id']!, _makeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_makeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('body_type')) {
      context.handle(
        _bodyTypeMeta,
        bodyType.isAcceptableOrUnknown(data['body_type']!, _bodyTypeMeta),
      );
    }
    if (data.containsKey('year_from')) {
      context.handle(
        _yearFromMeta,
        yearFrom.isAcceptableOrUnknown(data['year_from']!, _yearFromMeta),
      );
    } else if (isInserting) {
      context.missing(_yearFromMeta);
    }
    if (data.containsKey('year_to')) {
      context.handle(
        _yearToMeta,
        yearTo.isAcceptableOrUnknown(data['year_to']!, _yearToMeta),
      );
    } else if (isInserting) {
      context.missing(_yearToMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VehicleModelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VehicleModelRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      makeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bodyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_type'],
      )!,
      yearFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_from'],
      )!,
      yearTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_to'],
      )!,
    );
  }

  @override
  $VehicleModelsTable createAlias(String alias) {
    return $VehicleModelsTable(attachedDatabase, alias);
  }
}

class VehicleModelRow extends DataClass implements Insertable<VehicleModelRow> {
  final String id;
  final String makeId;
  final String name;

  /// Hatchback, sedan, SUV, pickup...
  final String bodyType;
  final int yearFrom;
  final int yearTo;
  const VehicleModelRow({
    required this.id,
    required this.makeId,
    required this.name,
    required this.bodyType,
    required this.yearFrom,
    required this.yearTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['make_id'] = Variable<String>(makeId);
    map['name'] = Variable<String>(name);
    map['body_type'] = Variable<String>(bodyType);
    map['year_from'] = Variable<int>(yearFrom);
    map['year_to'] = Variable<int>(yearTo);
    return map;
  }

  VehicleModelsCompanion toCompanion(bool nullToAbsent) {
    return VehicleModelsCompanion(
      id: Value(id),
      makeId: Value(makeId),
      name: Value(name),
      bodyType: Value(bodyType),
      yearFrom: Value(yearFrom),
      yearTo: Value(yearTo),
    );
  }

  factory VehicleModelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VehicleModelRow(
      id: serializer.fromJson<String>(json['id']),
      makeId: serializer.fromJson<String>(json['makeId']),
      name: serializer.fromJson<String>(json['name']),
      bodyType: serializer.fromJson<String>(json['bodyType']),
      yearFrom: serializer.fromJson<int>(json['yearFrom']),
      yearTo: serializer.fromJson<int>(json['yearTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'makeId': serializer.toJson<String>(makeId),
      'name': serializer.toJson<String>(name),
      'bodyType': serializer.toJson<String>(bodyType),
      'yearFrom': serializer.toJson<int>(yearFrom),
      'yearTo': serializer.toJson<int>(yearTo),
    };
  }

  VehicleModelRow copyWith({
    String? id,
    String? makeId,
    String? name,
    String? bodyType,
    int? yearFrom,
    int? yearTo,
  }) => VehicleModelRow(
    id: id ?? this.id,
    makeId: makeId ?? this.makeId,
    name: name ?? this.name,
    bodyType: bodyType ?? this.bodyType,
    yearFrom: yearFrom ?? this.yearFrom,
    yearTo: yearTo ?? this.yearTo,
  );
  VehicleModelRow copyWithCompanion(VehicleModelsCompanion data) {
    return VehicleModelRow(
      id: data.id.present ? data.id.value : this.id,
      makeId: data.makeId.present ? data.makeId.value : this.makeId,
      name: data.name.present ? data.name.value : this.name,
      bodyType: data.bodyType.present ? data.bodyType.value : this.bodyType,
      yearFrom: data.yearFrom.present ? data.yearFrom.value : this.yearFrom,
      yearTo: data.yearTo.present ? data.yearTo.value : this.yearTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VehicleModelRow(')
          ..write('id: $id, ')
          ..write('makeId: $makeId, ')
          ..write('name: $name, ')
          ..write('bodyType: $bodyType, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('yearTo: $yearTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, makeId, name, bodyType, yearFrom, yearTo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VehicleModelRow &&
          other.id == this.id &&
          other.makeId == this.makeId &&
          other.name == this.name &&
          other.bodyType == this.bodyType &&
          other.yearFrom == this.yearFrom &&
          other.yearTo == this.yearTo);
}

class VehicleModelsCompanion extends UpdateCompanion<VehicleModelRow> {
  final Value<String> id;
  final Value<String> makeId;
  final Value<String> name;
  final Value<String> bodyType;
  final Value<int> yearFrom;
  final Value<int> yearTo;
  final Value<int> rowid;
  const VehicleModelsCompanion({
    this.id = const Value.absent(),
    this.makeId = const Value.absent(),
    this.name = const Value.absent(),
    this.bodyType = const Value.absent(),
    this.yearFrom = const Value.absent(),
    this.yearTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehicleModelsCompanion.insert({
    required String id,
    required String makeId,
    required String name,
    this.bodyType = const Value.absent(),
    required int yearFrom,
    required int yearTo,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       makeId = Value(makeId),
       name = Value(name),
       yearFrom = Value(yearFrom),
       yearTo = Value(yearTo);
  static Insertable<VehicleModelRow> custom({
    Expression<String>? id,
    Expression<String>? makeId,
    Expression<String>? name,
    Expression<String>? bodyType,
    Expression<int>? yearFrom,
    Expression<int>? yearTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (makeId != null) 'make_id': makeId,
      if (name != null) 'name': name,
      if (bodyType != null) 'body_type': bodyType,
      if (yearFrom != null) 'year_from': yearFrom,
      if (yearTo != null) 'year_to': yearTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehicleModelsCompanion copyWith({
    Value<String>? id,
    Value<String>? makeId,
    Value<String>? name,
    Value<String>? bodyType,
    Value<int>? yearFrom,
    Value<int>? yearTo,
    Value<int>? rowid,
  }) {
    return VehicleModelsCompanion(
      id: id ?? this.id,
      makeId: makeId ?? this.makeId,
      name: name ?? this.name,
      bodyType: bodyType ?? this.bodyType,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (makeId.present) {
      map['make_id'] = Variable<String>(makeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bodyType.present) {
      map['body_type'] = Variable<String>(bodyType.value);
    }
    if (yearFrom.present) {
      map['year_from'] = Variable<int>(yearFrom.value);
    }
    if (yearTo.present) {
      map['year_to'] = Variable<int>(yearTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehicleModelsCompanion(')
          ..write('id: $id, ')
          ..write('makeId: $makeId, ')
          ..write('name: $name, ')
          ..write('bodyType: $bodyType, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('yearTo: $yearTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnginesTable extends Engines with TableInfo<$EnginesTable, EngineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnginesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicle_models (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _displacementMeta = const VerificationMeta(
    'displacement',
  );
  @override
  late final GeneratedColumn<double> displacement = GeneratedColumn<double>(
    'displacement',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fuelMeta = const VerificationMeta('fuel');
  @override
  late final GeneratedColumn<String> fuel = GeneratedColumn<String>(
    'fuel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Gasolina'),
  );
  static const VerificationMeta _horsepowerMeta = const VerificationMeta(
    'horsepower',
  );
  @override
  late final GeneratedColumn<int> horsepower = GeneratedColumn<int>(
    'horsepower',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _yearFromMeta = const VerificationMeta(
    'yearFrom',
  );
  @override
  late final GeneratedColumn<int> yearFrom = GeneratedColumn<int>(
    'year_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearToMeta = const VerificationMeta('yearTo');
  @override
  late final GeneratedColumn<int> yearTo = GeneratedColumn<int>(
    'year_to',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelId,
    code,
    name,
    displacement,
    fuel,
    horsepower,
    yearFrom,
    yearTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'engines';
  @override
  VerificationContext validateIntegrity(
    Insertable<EngineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('displacement')) {
      context.handle(
        _displacementMeta,
        displacement.isAcceptableOrUnknown(
          data['displacement']!,
          _displacementMeta,
        ),
      );
    }
    if (data.containsKey('fuel')) {
      context.handle(
        _fuelMeta,
        fuel.isAcceptableOrUnknown(data['fuel']!, _fuelMeta),
      );
    }
    if (data.containsKey('horsepower')) {
      context.handle(
        _horsepowerMeta,
        horsepower.isAcceptableOrUnknown(data['horsepower']!, _horsepowerMeta),
      );
    }
    if (data.containsKey('year_from')) {
      context.handle(
        _yearFromMeta,
        yearFrom.isAcceptableOrUnknown(data['year_from']!, _yearFromMeta),
      );
    } else if (isInserting) {
      context.missing(_yearFromMeta);
    }
    if (data.containsKey('year_to')) {
      context.handle(
        _yearToMeta,
        yearTo.isAcceptableOrUnknown(data['year_to']!, _yearToMeta),
      );
    } else if (isInserting) {
      context.missing(_yearToMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EngineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EngineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      displacement: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}displacement'],
      )!,
      fuel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel'],
      )!,
      horsepower: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}horsepower'],
      )!,
      yearFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_from'],
      )!,
      yearTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_to'],
      )!,
    );
  }

  @override
  $EnginesTable createAlias(String alias) {
    return $EnginesTable(attachedDatabase, alias);
  }
}

class EngineRow extends DataClass implements Insertable<EngineRow> {
  final String id;
  final String modelId;

  /// Codigo de fabrica del motor, por ejemplo `G4LC`.
  final String code;
  final String name;

  /// Cilindrada en litros.
  final double displacement;

  /// Gasolina, diesel, hibrido...
  final String fuel;
  final int horsepower;
  final int yearFrom;
  final int yearTo;
  const EngineRow({
    required this.id,
    required this.modelId,
    required this.code,
    required this.name,
    required this.displacement,
    required this.fuel,
    required this.horsepower,
    required this.yearFrom,
    required this.yearTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['model_id'] = Variable<String>(modelId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['displacement'] = Variable<double>(displacement);
    map['fuel'] = Variable<String>(fuel);
    map['horsepower'] = Variable<int>(horsepower);
    map['year_from'] = Variable<int>(yearFrom);
    map['year_to'] = Variable<int>(yearTo);
    return map;
  }

  EnginesCompanion toCompanion(bool nullToAbsent) {
    return EnginesCompanion(
      id: Value(id),
      modelId: Value(modelId),
      code: Value(code),
      name: Value(name),
      displacement: Value(displacement),
      fuel: Value(fuel),
      horsepower: Value(horsepower),
      yearFrom: Value(yearFrom),
      yearTo: Value(yearTo),
    );
  }

  factory EngineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EngineRow(
      id: serializer.fromJson<String>(json['id']),
      modelId: serializer.fromJson<String>(json['modelId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      displacement: serializer.fromJson<double>(json['displacement']),
      fuel: serializer.fromJson<String>(json['fuel']),
      horsepower: serializer.fromJson<int>(json['horsepower']),
      yearFrom: serializer.fromJson<int>(json['yearFrom']),
      yearTo: serializer.fromJson<int>(json['yearTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'modelId': serializer.toJson<String>(modelId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'displacement': serializer.toJson<double>(displacement),
      'fuel': serializer.toJson<String>(fuel),
      'horsepower': serializer.toJson<int>(horsepower),
      'yearFrom': serializer.toJson<int>(yearFrom),
      'yearTo': serializer.toJson<int>(yearTo),
    };
  }

  EngineRow copyWith({
    String? id,
    String? modelId,
    String? code,
    String? name,
    double? displacement,
    String? fuel,
    int? horsepower,
    int? yearFrom,
    int? yearTo,
  }) => EngineRow(
    id: id ?? this.id,
    modelId: modelId ?? this.modelId,
    code: code ?? this.code,
    name: name ?? this.name,
    displacement: displacement ?? this.displacement,
    fuel: fuel ?? this.fuel,
    horsepower: horsepower ?? this.horsepower,
    yearFrom: yearFrom ?? this.yearFrom,
    yearTo: yearTo ?? this.yearTo,
  );
  EngineRow copyWithCompanion(EnginesCompanion data) {
    return EngineRow(
      id: data.id.present ? data.id.value : this.id,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      displacement: data.displacement.present
          ? data.displacement.value
          : this.displacement,
      fuel: data.fuel.present ? data.fuel.value : this.fuel,
      horsepower: data.horsepower.present
          ? data.horsepower.value
          : this.horsepower,
      yearFrom: data.yearFrom.present ? data.yearFrom.value : this.yearFrom,
      yearTo: data.yearTo.present ? data.yearTo.value : this.yearTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EngineRow(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('displacement: $displacement, ')
          ..write('fuel: $fuel, ')
          ..write('horsepower: $horsepower, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('yearTo: $yearTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelId,
    code,
    name,
    displacement,
    fuel,
    horsepower,
    yearFrom,
    yearTo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EngineRow &&
          other.id == this.id &&
          other.modelId == this.modelId &&
          other.code == this.code &&
          other.name == this.name &&
          other.displacement == this.displacement &&
          other.fuel == this.fuel &&
          other.horsepower == this.horsepower &&
          other.yearFrom == this.yearFrom &&
          other.yearTo == this.yearTo);
}

class EnginesCompanion extends UpdateCompanion<EngineRow> {
  final Value<String> id;
  final Value<String> modelId;
  final Value<String> code;
  final Value<String> name;
  final Value<double> displacement;
  final Value<String> fuel;
  final Value<int> horsepower;
  final Value<int> yearFrom;
  final Value<int> yearTo;
  final Value<int> rowid;
  const EnginesCompanion({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.displacement = const Value.absent(),
    this.fuel = const Value.absent(),
    this.horsepower = const Value.absent(),
    this.yearFrom = const Value.absent(),
    this.yearTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnginesCompanion.insert({
    required String id,
    required String modelId,
    required String code,
    required String name,
    this.displacement = const Value.absent(),
    this.fuel = const Value.absent(),
    this.horsepower = const Value.absent(),
    required int yearFrom,
    required int yearTo,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       modelId = Value(modelId),
       code = Value(code),
       name = Value(name),
       yearFrom = Value(yearFrom),
       yearTo = Value(yearTo);
  static Insertable<EngineRow> custom({
    Expression<String>? id,
    Expression<String>? modelId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<double>? displacement,
    Expression<String>? fuel,
    Expression<int>? horsepower,
    Expression<int>? yearFrom,
    Expression<int>? yearTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelId != null) 'model_id': modelId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (displacement != null) 'displacement': displacement,
      if (fuel != null) 'fuel': fuel,
      if (horsepower != null) 'horsepower': horsepower,
      if (yearFrom != null) 'year_from': yearFrom,
      if (yearTo != null) 'year_to': yearTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnginesCompanion copyWith({
    Value<String>? id,
    Value<String>? modelId,
    Value<String>? code,
    Value<String>? name,
    Value<double>? displacement,
    Value<String>? fuel,
    Value<int>? horsepower,
    Value<int>? yearFrom,
    Value<int>? yearTo,
    Value<int>? rowid,
  }) {
    return EnginesCompanion(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      code: code ?? this.code,
      name: name ?? this.name,
      displacement: displacement ?? this.displacement,
      fuel: fuel ?? this.fuel,
      horsepower: horsepower ?? this.horsepower,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displacement.present) {
      map['displacement'] = Variable<double>(displacement.value);
    }
    if (fuel.present) {
      map['fuel'] = Variable<String>(fuel.value);
    }
    if (horsepower.present) {
      map['horsepower'] = Variable<int>(horsepower.value);
    }
    if (yearFrom.present) {
      map['year_from'] = Variable<int>(yearFrom.value);
    }
    if (yearTo.present) {
      map['year_to'] = Variable<int>(yearTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnginesCompanion(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('displacement: $displacement, ')
          ..write('fuel: $fuel, ')
          ..write('horsepower: $horsepower, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('yearTo: $yearTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _oemMeta = const VerificationMeta('oem');
  @override
  late final GeneratedColumn<String> oem = GeneratedColumn<String>(
    'oem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _partBrandIdMeta = const VerificationMeta(
    'partBrandId',
  );
  @override
  late final GeneratedColumn<String> partBrandId = GeneratedColumn<String>(
    'part_brand_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES part_brands (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousPriceMeta = const VerificationMeta(
    'previousPrice',
  );
  @override
  late final GeneratedColumn<double> previousPrice = GeneratedColumn<double>(
    'previous_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _warrantyMonthsMeta = const VerificationMeta(
    'warrantyMonths',
  );
  @override
  late final GeneratedColumn<int> warrantyMonths = GeneratedColumn<int>(
    'warranty_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(12),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reviewCountMeta = const VerificationMeta(
    'reviewCount',
  );
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
    'review_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isFeaturedMeta = const VerificationMeta(
    'isFeatured',
  );
  @override
  late final GeneratedColumn<bool> isFeatured = GeneratedColumn<bool>(
    'is_featured',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_featured" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _specsJsonMeta = const VerificationMeta(
    'specsJson',
  );
  @override
  late final GeneratedColumn<String> specsJson = GeneratedColumn<String>(
    'specs_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sku,
    oem,
    name,
    description,
    categoryId,
    partBrandId,
    price,
    previousPrice,
    stock,
    warrantyMonths,
    rating,
    reviewCount,
    isFeatured,
    specsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('oem')) {
      context.handle(
        _oemMeta,
        oem.isAcceptableOrUnknown(data['oem']!, _oemMeta),
      );
    } else if (isInserting) {
      context.missing(_oemMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('part_brand_id')) {
      context.handle(
        _partBrandIdMeta,
        partBrandId.isAcceptableOrUnknown(
          data['part_brand_id']!,
          _partBrandIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partBrandIdMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('previous_price')) {
      context.handle(
        _previousPriceMeta,
        previousPrice.isAcceptableOrUnknown(
          data['previous_price']!,
          _previousPriceMeta,
        ),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('warranty_months')) {
      context.handle(
        _warrantyMonthsMeta,
        warrantyMonths.isAcceptableOrUnknown(
          data['warranty_months']!,
          _warrantyMonthsMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('review_count')) {
      context.handle(
        _reviewCountMeta,
        reviewCount.isAcceptableOrUnknown(
          data['review_count']!,
          _reviewCountMeta,
        ),
      );
    }
    if (data.containsKey('is_featured')) {
      context.handle(
        _isFeaturedMeta,
        isFeatured.isAcceptableOrUnknown(data['is_featured']!, _isFeaturedMeta),
      );
    }
    if (data.containsKey('specs_json')) {
      context.handle(
        _specsJsonMeta,
        specsJson.isAcceptableOrUnknown(data['specs_json']!, _specsJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      )!,
      oem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oem'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      partBrandId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_brand_id'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      previousPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_price'],
      ),
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      warrantyMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warranty_months'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      )!,
      reviewCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}review_count'],
      )!,
      isFeatured: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_featured'],
      )!,
      specsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specs_json'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String sku;
  final String oem;
  final String name;
  final String description;
  final String categoryId;
  final String partBrandId;
  final double price;
  final double? previousPrice;
  final int stock;
  final int warrantyMonths;
  final double rating;
  final int reviewCount;
  final bool isFeatured;

  /// Ficha tecnica serializada como JSON: `{"Diametro":"280 mm"}`.
  final String specsJson;
  const ProductRow({
    required this.id,
    required this.sku,
    required this.oem,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.partBrandId,
    required this.price,
    this.previousPrice,
    required this.stock,
    required this.warrantyMonths,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.specsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['sku'] = Variable<String>(sku);
    map['oem'] = Variable<String>(oem);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['category_id'] = Variable<String>(categoryId);
    map['part_brand_id'] = Variable<String>(partBrandId);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || previousPrice != null) {
      map['previous_price'] = Variable<double>(previousPrice);
    }
    map['stock'] = Variable<int>(stock);
    map['warranty_months'] = Variable<int>(warrantyMonths);
    map['rating'] = Variable<double>(rating);
    map['review_count'] = Variable<int>(reviewCount);
    map['is_featured'] = Variable<bool>(isFeatured);
    map['specs_json'] = Variable<String>(specsJson);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      sku: Value(sku),
      oem: Value(oem),
      name: Value(name),
      description: Value(description),
      categoryId: Value(categoryId),
      partBrandId: Value(partBrandId),
      price: Value(price),
      previousPrice: previousPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(previousPrice),
      stock: Value(stock),
      warrantyMonths: Value(warrantyMonths),
      rating: Value(rating),
      reviewCount: Value(reviewCount),
      isFeatured: Value(isFeatured),
      specsJson: Value(specsJson),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      sku: serializer.fromJson<String>(json['sku']),
      oem: serializer.fromJson<String>(json['oem']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      partBrandId: serializer.fromJson<String>(json['partBrandId']),
      price: serializer.fromJson<double>(json['price']),
      previousPrice: serializer.fromJson<double?>(json['previousPrice']),
      stock: serializer.fromJson<int>(json['stock']),
      warrantyMonths: serializer.fromJson<int>(json['warrantyMonths']),
      rating: serializer.fromJson<double>(json['rating']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      isFeatured: serializer.fromJson<bool>(json['isFeatured']),
      specsJson: serializer.fromJson<String>(json['specsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sku': serializer.toJson<String>(sku),
      'oem': serializer.toJson<String>(oem),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'categoryId': serializer.toJson<String>(categoryId),
      'partBrandId': serializer.toJson<String>(partBrandId),
      'price': serializer.toJson<double>(price),
      'previousPrice': serializer.toJson<double?>(previousPrice),
      'stock': serializer.toJson<int>(stock),
      'warrantyMonths': serializer.toJson<int>(warrantyMonths),
      'rating': serializer.toJson<double>(rating),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'isFeatured': serializer.toJson<bool>(isFeatured),
      'specsJson': serializer.toJson<String>(specsJson),
    };
  }

  ProductRow copyWith({
    String? id,
    String? sku,
    String? oem,
    String? name,
    String? description,
    String? categoryId,
    String? partBrandId,
    double? price,
    Value<double?> previousPrice = const Value.absent(),
    int? stock,
    int? warrantyMonths,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    String? specsJson,
  }) => ProductRow(
    id: id ?? this.id,
    sku: sku ?? this.sku,
    oem: oem ?? this.oem,
    name: name ?? this.name,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    partBrandId: partBrandId ?? this.partBrandId,
    price: price ?? this.price,
    previousPrice: previousPrice.present
        ? previousPrice.value
        : this.previousPrice,
    stock: stock ?? this.stock,
    warrantyMonths: warrantyMonths ?? this.warrantyMonths,
    rating: rating ?? this.rating,
    reviewCount: reviewCount ?? this.reviewCount,
    isFeatured: isFeatured ?? this.isFeatured,
    specsJson: specsJson ?? this.specsJson,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      sku: data.sku.present ? data.sku.value : this.sku,
      oem: data.oem.present ? data.oem.value : this.oem,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      partBrandId: data.partBrandId.present
          ? data.partBrandId.value
          : this.partBrandId,
      price: data.price.present ? data.price.value : this.price,
      previousPrice: data.previousPrice.present
          ? data.previousPrice.value
          : this.previousPrice,
      stock: data.stock.present ? data.stock.value : this.stock,
      warrantyMonths: data.warrantyMonths.present
          ? data.warrantyMonths.value
          : this.warrantyMonths,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewCount: data.reviewCount.present
          ? data.reviewCount.value
          : this.reviewCount,
      isFeatured: data.isFeatured.present
          ? data.isFeatured.value
          : this.isFeatured,
      specsJson: data.specsJson.present ? data.specsJson.value : this.specsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('oem: $oem, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('partBrandId: $partBrandId, ')
          ..write('price: $price, ')
          ..write('previousPrice: $previousPrice, ')
          ..write('stock: $stock, ')
          ..write('warrantyMonths: $warrantyMonths, ')
          ..write('rating: $rating, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('isFeatured: $isFeatured, ')
          ..write('specsJson: $specsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sku,
    oem,
    name,
    description,
    categoryId,
    partBrandId,
    price,
    previousPrice,
    stock,
    warrantyMonths,
    rating,
    reviewCount,
    isFeatured,
    specsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.sku == this.sku &&
          other.oem == this.oem &&
          other.name == this.name &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.partBrandId == this.partBrandId &&
          other.price == this.price &&
          other.previousPrice == this.previousPrice &&
          other.stock == this.stock &&
          other.warrantyMonths == this.warrantyMonths &&
          other.rating == this.rating &&
          other.reviewCount == this.reviewCount &&
          other.isFeatured == this.isFeatured &&
          other.specsJson == this.specsJson);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> sku;
  final Value<String> oem;
  final Value<String> name;
  final Value<String> description;
  final Value<String> categoryId;
  final Value<String> partBrandId;
  final Value<double> price;
  final Value<double?> previousPrice;
  final Value<int> stock;
  final Value<int> warrantyMonths;
  final Value<double> rating;
  final Value<int> reviewCount;
  final Value<bool> isFeatured;
  final Value<String> specsJson;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.sku = const Value.absent(),
    this.oem = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.partBrandId = const Value.absent(),
    this.price = const Value.absent(),
    this.previousPrice = const Value.absent(),
    this.stock = const Value.absent(),
    this.warrantyMonths = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.isFeatured = const Value.absent(),
    this.specsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String sku,
    required String oem,
    required String name,
    this.description = const Value.absent(),
    required String categoryId,
    required String partBrandId,
    required double price,
    this.previousPrice = const Value.absent(),
    this.stock = const Value.absent(),
    this.warrantyMonths = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.isFeatured = const Value.absent(),
    this.specsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sku = Value(sku),
       oem = Value(oem),
       name = Value(name),
       categoryId = Value(categoryId),
       partBrandId = Value(partBrandId),
       price = Value(price);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? sku,
    Expression<String>? oem,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? categoryId,
    Expression<String>? partBrandId,
    Expression<double>? price,
    Expression<double>? previousPrice,
    Expression<int>? stock,
    Expression<int>? warrantyMonths,
    Expression<double>? rating,
    Expression<int>? reviewCount,
    Expression<bool>? isFeatured,
    Expression<String>? specsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sku != null) 'sku': sku,
      if (oem != null) 'oem': oem,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (partBrandId != null) 'part_brand_id': partBrandId,
      if (price != null) 'price': price,
      if (previousPrice != null) 'previous_price': previousPrice,
      if (stock != null) 'stock': stock,
      if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'review_count': reviewCount,
      if (isFeatured != null) 'is_featured': isFeatured,
      if (specsJson != null) 'specs_json': specsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? sku,
    Value<String>? oem,
    Value<String>? name,
    Value<String>? description,
    Value<String>? categoryId,
    Value<String>? partBrandId,
    Value<double>? price,
    Value<double?>? previousPrice,
    Value<int>? stock,
    Value<int>? warrantyMonths,
    Value<double>? rating,
    Value<int>? reviewCount,
    Value<bool>? isFeatured,
    Value<String>? specsJson,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      sku: sku ?? this.sku,
      oem: oem ?? this.oem,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      partBrandId: partBrandId ?? this.partBrandId,
      price: price ?? this.price,
      previousPrice: previousPrice ?? this.previousPrice,
      stock: stock ?? this.stock,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      specsJson: specsJson ?? this.specsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (oem.present) {
      map['oem'] = Variable<String>(oem.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (partBrandId.present) {
      map['part_brand_id'] = Variable<String>(partBrandId.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (previousPrice.present) {
      map['previous_price'] = Variable<double>(previousPrice.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (warrantyMonths.present) {
      map['warranty_months'] = Variable<int>(warrantyMonths.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (isFeatured.present) {
      map['is_featured'] = Variable<bool>(isFeatured.value);
    }
    if (specsJson.present) {
      map['specs_json'] = Variable<String>(specsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('sku: $sku, ')
          ..write('oem: $oem, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('partBrandId: $partBrandId, ')
          ..write('price: $price, ')
          ..write('previousPrice: $previousPrice, ')
          ..write('stock: $stock, ')
          ..write('warrantyMonths: $warrantyMonths, ')
          ..write('rating: $rating, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('isFeatured: $isFeatured, ')
          ..write('specsJson: $specsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductImagesTable extends ProductImages
    with TableInfo<$ProductImagesTable, ProductImageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    url,
    sortOrder,
    isPrimary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductImageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductImageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductImageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $ProductImagesTable createAlias(String alias) {
    return $ProductImagesTable(attachedDatabase, alias);
  }
}

class ProductImageRow extends DataClass implements Insertable<ProductImageRow> {
  final String id;
  final String productId;
  final String url;
  final int sortOrder;
  final bool isPrimary;
  const ProductImageRow({
    required this.id,
    required this.productId,
    required this.url,
    required this.sortOrder,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['url'] = Variable<String>(url);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  ProductImagesCompanion toCompanion(bool nullToAbsent) {
    return ProductImagesCompanion(
      id: Value(id),
      productId: Value(productId),
      url: Value(url),
      sortOrder: Value(sortOrder),
      isPrimary: Value(isPrimary),
    );
  }

  factory ProductImageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductImageRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      url: serializer.fromJson<String>(json['url']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'url': serializer.toJson<String>(url),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  ProductImageRow copyWith({
    String? id,
    String? productId,
    String? url,
    int? sortOrder,
    bool? isPrimary,
  }) => ProductImageRow(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    url: url ?? this.url,
    sortOrder: sortOrder ?? this.sortOrder,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  ProductImageRow copyWithCompanion(ProductImagesCompanion data) {
    return ProductImageRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      url: data.url.present ? data.url.value : this.url,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductImageRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('url: $url, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, url, sortOrder, isPrimary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductImageRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.url == this.url &&
          other.sortOrder == this.sortOrder &&
          other.isPrimary == this.isPrimary);
}

class ProductImagesCompanion extends UpdateCompanion<ProductImageRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> url;
  final Value<int> sortOrder;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const ProductImagesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.url = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductImagesCompanion.insert({
    required String id,
    required String productId,
    required String url,
    this.sortOrder = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       url = Value(url);
  static Insertable<ProductImageRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? url,
    Expression<int>? sortOrder,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (url != null) 'url': url,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductImagesCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? url,
    Value<int>? sortOrder,
    Value<bool>? isPrimary,
    Value<int>? rowid,
  }) {
    return ProductImagesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      url: url ?? this.url,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductImagesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('url: $url, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FitmentsTable extends Fitments
    with TableInfo<$FitmentsTable, FitmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FitmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicle_models (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _engineIdMeta = const VerificationMeta(
    'engineId',
  );
  @override
  late final GeneratedColumn<String> engineId = GeneratedColumn<String>(
    'engine_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES engines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _yearFromMeta = const VerificationMeta(
    'yearFrom',
  );
  @override
  late final GeneratedColumn<int> yearFrom = GeneratedColumn<int>(
    'year_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearToMeta = const VerificationMeta('yearTo');
  @override
  late final GeneratedColumn<int> yearTo = GeneratedColumn<int>(
    'year_to',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    modelId,
    engineId,
    yearFrom,
    yearTo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fitments';
  @override
  VerificationContext validateIntegrity(
    Insertable<FitmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('engine_id')) {
      context.handle(
        _engineIdMeta,
        engineId.isAcceptableOrUnknown(data['engine_id']!, _engineIdMeta),
      );
    }
    if (data.containsKey('year_from')) {
      context.handle(
        _yearFromMeta,
        yearFrom.isAcceptableOrUnknown(data['year_from']!, _yearFromMeta),
      );
    } else if (isInserting) {
      context.missing(_yearFromMeta);
    }
    if (data.containsKey('year_to')) {
      context.handle(
        _yearToMeta,
        yearTo.isAcceptableOrUnknown(data['year_to']!, _yearToMeta),
      );
    } else if (isInserting) {
      context.missing(_yearToMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FitmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FitmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      engineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}engine_id'],
      ),
      yearFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_from'],
      )!,
      yearTo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_to'],
      )!,
    );
  }

  @override
  $FitmentsTable createAlias(String alias) {
    return $FitmentsTable(attachedDatabase, alias);
  }
}

class FitmentRow extends DataClass implements Insertable<FitmentRow> {
  final String id;
  final String productId;
  final String modelId;
  final String? engineId;
  final int yearFrom;
  final int yearTo;
  const FitmentRow({
    required this.id,
    required this.productId,
    required this.modelId,
    this.engineId,
    required this.yearFrom,
    required this.yearTo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['product_id'] = Variable<String>(productId);
    map['model_id'] = Variable<String>(modelId);
    if (!nullToAbsent || engineId != null) {
      map['engine_id'] = Variable<String>(engineId);
    }
    map['year_from'] = Variable<int>(yearFrom);
    map['year_to'] = Variable<int>(yearTo);
    return map;
  }

  FitmentsCompanion toCompanion(bool nullToAbsent) {
    return FitmentsCompanion(
      id: Value(id),
      productId: Value(productId),
      modelId: Value(modelId),
      engineId: engineId == null && nullToAbsent
          ? const Value.absent()
          : Value(engineId),
      yearFrom: Value(yearFrom),
      yearTo: Value(yearTo),
    );
  }

  factory FitmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FitmentRow(
      id: serializer.fromJson<String>(json['id']),
      productId: serializer.fromJson<String>(json['productId']),
      modelId: serializer.fromJson<String>(json['modelId']),
      engineId: serializer.fromJson<String?>(json['engineId']),
      yearFrom: serializer.fromJson<int>(json['yearFrom']),
      yearTo: serializer.fromJson<int>(json['yearTo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'productId': serializer.toJson<String>(productId),
      'modelId': serializer.toJson<String>(modelId),
      'engineId': serializer.toJson<String?>(engineId),
      'yearFrom': serializer.toJson<int>(yearFrom),
      'yearTo': serializer.toJson<int>(yearTo),
    };
  }

  FitmentRow copyWith({
    String? id,
    String? productId,
    String? modelId,
    Value<String?> engineId = const Value.absent(),
    int? yearFrom,
    int? yearTo,
  }) => FitmentRow(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    modelId: modelId ?? this.modelId,
    engineId: engineId.present ? engineId.value : this.engineId,
    yearFrom: yearFrom ?? this.yearFrom,
    yearTo: yearTo ?? this.yearTo,
  );
  FitmentRow copyWithCompanion(FitmentsCompanion data) {
    return FitmentRow(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      engineId: data.engineId.present ? data.engineId.value : this.engineId,
      yearFrom: data.yearFrom.present ? data.yearFrom.value : this.yearFrom,
      yearTo: data.yearTo.present ? data.yearTo.value : this.yearTo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FitmentRow(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('modelId: $modelId, ')
          ..write('engineId: $engineId, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('yearTo: $yearTo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productId, modelId, engineId, yearFrom, yearTo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FitmentRow &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.modelId == this.modelId &&
          other.engineId == this.engineId &&
          other.yearFrom == this.yearFrom &&
          other.yearTo == this.yearTo);
}

class FitmentsCompanion extends UpdateCompanion<FitmentRow> {
  final Value<String> id;
  final Value<String> productId;
  final Value<String> modelId;
  final Value<String?> engineId;
  final Value<int> yearFrom;
  final Value<int> yearTo;
  final Value<int> rowid;
  const FitmentsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.modelId = const Value.absent(),
    this.engineId = const Value.absent(),
    this.yearFrom = const Value.absent(),
    this.yearTo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FitmentsCompanion.insert({
    required String id,
    required String productId,
    required String modelId,
    this.engineId = const Value.absent(),
    required int yearFrom,
    required int yearTo,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       productId = Value(productId),
       modelId = Value(modelId),
       yearFrom = Value(yearFrom),
       yearTo = Value(yearTo);
  static Insertable<FitmentRow> custom({
    Expression<String>? id,
    Expression<String>? productId,
    Expression<String>? modelId,
    Expression<String>? engineId,
    Expression<int>? yearFrom,
    Expression<int>? yearTo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (modelId != null) 'model_id': modelId,
      if (engineId != null) 'engine_id': engineId,
      if (yearFrom != null) 'year_from': yearFrom,
      if (yearTo != null) 'year_to': yearTo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FitmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? productId,
    Value<String>? modelId,
    Value<String?>? engineId,
    Value<int>? yearFrom,
    Value<int>? yearTo,
    Value<int>? rowid,
  }) {
    return FitmentsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      modelId: modelId ?? this.modelId,
      engineId: engineId ?? this.engineId,
      yearFrom: yearFrom ?? this.yearFrom,
      yearTo: yearTo ?? this.yearTo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (engineId.present) {
      map['engine_id'] = Variable<String>(engineId.value);
    }
    if (yearFrom.present) {
      map['year_from'] = Variable<int>(yearFrom.value);
    }
    if (yearTo.present) {
      map['year_to'] = Variable<int>(yearTo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FitmentsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('modelId: $modelId, ')
          ..write('engineId: $engineId, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('yearTo: $yearTo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuotesTable extends Quotes with TableInfo<$QuotesTable, QuoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerPhoneMeta = const VerificationMeta(
    'customerPhone',
  );
  @override
  late final GeneratedColumn<String> customerPhone = GeneratedColumn<String>(
    'customer_phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _customerEmailMeta = const VerificationMeta(
    'customerEmail',
  );
  @override
  late final GeneratedColumn<String> customerEmail = GeneratedColumn<String>(
    'customer_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _companyNameMeta = const VerificationMeta(
    'companyName',
  );
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
    'company_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxRateMeta = const VerificationMeta(
    'taxRate',
  );
  @override
  late final GeneratedColumn<double> taxRate = GeneratedColumn<double>(
    'tax_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.19),
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemCountMeta = const VerificationMeta(
    'itemCount',
  );
  @override
  late final GeneratedColumn<int> itemCount = GeneratedColumn<int>(
    'item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitCountMeta = const VerificationMeta(
    'unitCount',
  );
  @override
  late final GeneratedColumn<int> unitCount = GeneratedColumn<int>(
    'unit_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    status,
    customerName,
    customerPhone,
    customerEmail,
    companyName,
    notes,
    subtotal,
    taxRate,
    taxAmount,
    total,
    itemCount,
    unitCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('customer_phone')) {
      context.handle(
        _customerPhoneMeta,
        customerPhone.isAcceptableOrUnknown(
          data['customer_phone']!,
          _customerPhoneMeta,
        ),
      );
    }
    if (data.containsKey('customer_email')) {
      context.handle(
        _customerEmailMeta,
        customerEmail.isAcceptableOrUnknown(
          data['customer_email']!,
          _customerEmailMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerEmailMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
        _companyNameMeta,
        companyName.isAcceptableOrUnknown(
          data['company_name']!,
          _companyNameMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('tax_rate')) {
      context.handle(
        _taxRateMeta,
        taxRate.isAcceptableOrUnknown(data['tax_rate']!, _taxRateMeta),
      );
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_taxAmountMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('item_count')) {
      context.handle(
        _itemCountMeta,
        itemCount.isAcceptableOrUnknown(data['item_count']!, _itemCountMeta),
      );
    }
    if (data.containsKey('unit_count')) {
      context.handle(
        _unitCountMeta,
        unitCount.isAcceptableOrUnknown(data['unit_count']!, _unitCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      customerPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_phone'],
      )!,
      customerEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_email'],
      )!,
      companyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      taxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_rate'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      itemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_count'],
      )!,
      unitCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }
}

class QuoteRow extends DataClass implements Insertable<QuoteRow> {
  final String id;
  final String userId;
  final String status;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String companyName;
  final String notes;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final int itemCount;
  final int unitCount;
  final DateTime createdAt;
  const QuoteRow({
    required this.id,
    required this.userId,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.companyName,
    required this.notes,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.itemCount,
    required this.unitCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['status'] = Variable<String>(status);
    map['customer_name'] = Variable<String>(customerName);
    map['customer_phone'] = Variable<String>(customerPhone);
    map['customer_email'] = Variable<String>(customerEmail);
    map['company_name'] = Variable<String>(companyName);
    map['notes'] = Variable<String>(notes);
    map['subtotal'] = Variable<double>(subtotal);
    map['tax_rate'] = Variable<double>(taxRate);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['total'] = Variable<double>(total);
    map['item_count'] = Variable<int>(itemCount);
    map['unit_count'] = Variable<int>(unitCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      id: Value(id),
      userId: Value(userId),
      status: Value(status),
      customerName: Value(customerName),
      customerPhone: Value(customerPhone),
      customerEmail: Value(customerEmail),
      companyName: Value(companyName),
      notes: Value(notes),
      subtotal: Value(subtotal),
      taxRate: Value(taxRate),
      taxAmount: Value(taxAmount),
      total: Value(total),
      itemCount: Value(itemCount),
      unitCount: Value(unitCount),
      createdAt: Value(createdAt),
    );
  }

  factory QuoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuoteRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      status: serializer.fromJson<String>(json['status']),
      customerName: serializer.fromJson<String>(json['customerName']),
      customerPhone: serializer.fromJson<String>(json['customerPhone']),
      customerEmail: serializer.fromJson<String>(json['customerEmail']),
      companyName: serializer.fromJson<String>(json['companyName']),
      notes: serializer.fromJson<String>(json['notes']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      taxRate: serializer.fromJson<double>(json['taxRate']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      total: serializer.fromJson<double>(json['total']),
      itemCount: serializer.fromJson<int>(json['itemCount']),
      unitCount: serializer.fromJson<int>(json['unitCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'status': serializer.toJson<String>(status),
      'customerName': serializer.toJson<String>(customerName),
      'customerPhone': serializer.toJson<String>(customerPhone),
      'customerEmail': serializer.toJson<String>(customerEmail),
      'companyName': serializer.toJson<String>(companyName),
      'notes': serializer.toJson<String>(notes),
      'subtotal': serializer.toJson<double>(subtotal),
      'taxRate': serializer.toJson<double>(taxRate),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'total': serializer.toJson<double>(total),
      'itemCount': serializer.toJson<int>(itemCount),
      'unitCount': serializer.toJson<int>(unitCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  QuoteRow copyWith({
    String? id,
    String? userId,
    String? status,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? companyName,
    String? notes,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? total,
    int? itemCount,
    int? unitCount,
    DateTime? createdAt,
  }) => QuoteRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    status: status ?? this.status,
    customerName: customerName ?? this.customerName,
    customerPhone: customerPhone ?? this.customerPhone,
    customerEmail: customerEmail ?? this.customerEmail,
    companyName: companyName ?? this.companyName,
    notes: notes ?? this.notes,
    subtotal: subtotal ?? this.subtotal,
    taxRate: taxRate ?? this.taxRate,
    taxAmount: taxAmount ?? this.taxAmount,
    total: total ?? this.total,
    itemCount: itemCount ?? this.itemCount,
    unitCount: unitCount ?? this.unitCount,
    createdAt: createdAt ?? this.createdAt,
  );
  QuoteRow copyWithCompanion(QuotesCompanion data) {
    return QuoteRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      status: data.status.present ? data.status.value : this.status,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      customerPhone: data.customerPhone.present
          ? data.customerPhone.value
          : this.customerPhone,
      customerEmail: data.customerEmail.present
          ? data.customerEmail.value
          : this.customerEmail,
      companyName: data.companyName.present
          ? data.companyName.value
          : this.companyName,
      notes: data.notes.present ? data.notes.value : this.notes,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      taxRate: data.taxRate.present ? data.taxRate.value : this.taxRate,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      total: data.total.present ? data.total.value : this.total,
      itemCount: data.itemCount.present ? data.itemCount.value : this.itemCount,
      unitCount: data.unitCount.present ? data.unitCount.value : this.unitCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuoteRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('companyName: $companyName, ')
          ..write('notes: $notes, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxRate: $taxRate, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('total: $total, ')
          ..write('itemCount: $itemCount, ')
          ..write('unitCount: $unitCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    status,
    customerName,
    customerPhone,
    customerEmail,
    companyName,
    notes,
    subtotal,
    taxRate,
    taxAmount,
    total,
    itemCount,
    unitCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuoteRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.status == this.status &&
          other.customerName == this.customerName &&
          other.customerPhone == this.customerPhone &&
          other.customerEmail == this.customerEmail &&
          other.companyName == this.companyName &&
          other.notes == this.notes &&
          other.subtotal == this.subtotal &&
          other.taxRate == this.taxRate &&
          other.taxAmount == this.taxAmount &&
          other.total == this.total &&
          other.itemCount == this.itemCount &&
          other.unitCount == this.unitCount &&
          other.createdAt == this.createdAt);
}

class QuotesCompanion extends UpdateCompanion<QuoteRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> status;
  final Value<String> customerName;
  final Value<String> customerPhone;
  final Value<String> customerEmail;
  final Value<String> companyName;
  final Value<String> notes;
  final Value<double> subtotal;
  final Value<double> taxRate;
  final Value<double> taxAmount;
  final Value<double> total;
  final Value<int> itemCount;
  final Value<int> unitCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const QuotesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.customerName = const Value.absent(),
    this.customerPhone = const Value.absent(),
    this.customerEmail = const Value.absent(),
    this.companyName = const Value.absent(),
    this.notes = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.total = const Value.absent(),
    this.itemCount = const Value.absent(),
    this.unitCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuotesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    required String customerName,
    this.customerPhone = const Value.absent(),
    required String customerEmail,
    this.companyName = const Value.absent(),
    this.notes = const Value.absent(),
    required double subtotal,
    this.taxRate = const Value.absent(),
    required double taxAmount,
    required double total,
    this.itemCount = const Value.absent(),
    this.unitCount = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerName = Value(customerName),
       customerEmail = Value(customerEmail),
       subtotal = Value(subtotal),
       taxAmount = Value(taxAmount),
       total = Value(total),
       createdAt = Value(createdAt);
  static Insertable<QuoteRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? status,
    Expression<String>? customerName,
    Expression<String>? customerPhone,
    Expression<String>? customerEmail,
    Expression<String>? companyName,
    Expression<String>? notes,
    Expression<double>? subtotal,
    Expression<double>? taxRate,
    Expression<double>? taxAmount,
    Expression<double>? total,
    Expression<int>? itemCount,
    Expression<int>? unitCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (customerEmail != null) 'customer_email': customerEmail,
      if (companyName != null) 'company_name': companyName,
      if (notes != null) 'notes': notes,
      if (subtotal != null) 'subtotal': subtotal,
      if (taxRate != null) 'tax_rate': taxRate,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (total != null) 'total': total,
      if (itemCount != null) 'item_count': itemCount,
      if (unitCount != null) 'unit_count': unitCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuotesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? status,
    Value<String>? customerName,
    Value<String>? customerPhone,
    Value<String>? customerEmail,
    Value<String>? companyName,
    Value<String>? notes,
    Value<double>? subtotal,
    Value<double>? taxRate,
    Value<double>? taxAmount,
    Value<double>? total,
    Value<int>? itemCount,
    Value<int>? unitCount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return QuotesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      companyName: companyName ?? this.companyName,
      notes: notes ?? this.notes,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      itemCount: itemCount ?? this.itemCount,
      unitCount: unitCount ?? this.unitCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (customerPhone.present) {
      map['customer_phone'] = Variable<String>(customerPhone.value);
    }
    if (customerEmail.present) {
      map['customer_email'] = Variable<String>(customerEmail.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (taxRate.present) {
      map['tax_rate'] = Variable<double>(taxRate.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (itemCount.present) {
      map['item_count'] = Variable<int>(itemCount.value);
    }
    if (unitCount.present) {
      map['unit_count'] = Variable<int>(unitCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('customerName: $customerName, ')
          ..write('customerPhone: $customerPhone, ')
          ..write('customerEmail: $customerEmail, ')
          ..write('companyName: $companyName, ')
          ..write('notes: $notes, ')
          ..write('subtotal: $subtotal, ')
          ..write('taxRate: $taxRate, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('total: $total, ')
          ..write('itemCount: $itemCount, ')
          ..write('unitCount: $unitCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuoteItemsTable extends QuoteItems
    with TableInfo<$QuoteItemsTable, QuoteItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuoteItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteIdMeta = const VerificationMeta(
    'quoteId',
  );
  @override
  late final GeneratedColumn<String> quoteId = GeneratedColumn<String>(
    'quote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quotes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oemMeta = const VerificationMeta('oem');
  @override
  late final GeneratedColumn<String> oem = GeneratedColumn<String>(
    'oem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineTotalMeta = const VerificationMeta(
    'lineTotal',
  );
  @override
  late final GeneratedColumn<double> lineTotal = GeneratedColumn<double>(
    'line_total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quoteId,
    productId,
    sku,
    oem,
    productName,
    brandName,
    unitPrice,
    quantity,
    lineTotal,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quote_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuoteItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quote_id')) {
      context.handle(
        _quoteIdMeta,
        quoteId.isAcceptableOrUnknown(data['quote_id']!, _quoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('oem')) {
      context.handle(
        _oemMeta,
        oem.isAcceptableOrUnknown(data['oem']!, _oemMeta),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('line_total')) {
      context.handle(
        _lineTotalMeta,
        lineTotal.isAcceptableOrUnknown(data['line_total']!, _lineTotalMeta),
      );
    } else if (isInserting) {
      context.missing(_lineTotalMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuoteItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuoteItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      quoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      )!,
      oem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oem'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      lineTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}line_total'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $QuoteItemsTable createAlias(String alias) {
    return $QuoteItemsTable(attachedDatabase, alias);
  }
}

class QuoteItemRow extends DataClass implements Insertable<QuoteItemRow> {
  final String id;
  final String quoteId;
  final String productId;
  final String sku;
  final String oem;
  final String productName;
  final String brandName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final int sortOrder;
  const QuoteItemRow({
    required this.id,
    required this.quoteId,
    required this.productId,
    required this.sku,
    required this.oem,
    required this.productName,
    required this.brandName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quote_id'] = Variable<String>(quoteId);
    map['product_id'] = Variable<String>(productId);
    map['sku'] = Variable<String>(sku);
    map['oem'] = Variable<String>(oem);
    map['product_name'] = Variable<String>(productName);
    map['brand_name'] = Variable<String>(brandName);
    map['unit_price'] = Variable<double>(unitPrice);
    map['quantity'] = Variable<int>(quantity);
    map['line_total'] = Variable<double>(lineTotal);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  QuoteItemsCompanion toCompanion(bool nullToAbsent) {
    return QuoteItemsCompanion(
      id: Value(id),
      quoteId: Value(quoteId),
      productId: Value(productId),
      sku: Value(sku),
      oem: Value(oem),
      productName: Value(productName),
      brandName: Value(brandName),
      unitPrice: Value(unitPrice),
      quantity: Value(quantity),
      lineTotal: Value(lineTotal),
      sortOrder: Value(sortOrder),
    );
  }

  factory QuoteItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuoteItemRow(
      id: serializer.fromJson<String>(json['id']),
      quoteId: serializer.fromJson<String>(json['quoteId']),
      productId: serializer.fromJson<String>(json['productId']),
      sku: serializer.fromJson<String>(json['sku']),
      oem: serializer.fromJson<String>(json['oem']),
      productName: serializer.fromJson<String>(json['productName']),
      brandName: serializer.fromJson<String>(json['brandName']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      quantity: serializer.fromJson<int>(json['quantity']),
      lineTotal: serializer.fromJson<double>(json['lineTotal']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quoteId': serializer.toJson<String>(quoteId),
      'productId': serializer.toJson<String>(productId),
      'sku': serializer.toJson<String>(sku),
      'oem': serializer.toJson<String>(oem),
      'productName': serializer.toJson<String>(productName),
      'brandName': serializer.toJson<String>(brandName),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'quantity': serializer.toJson<int>(quantity),
      'lineTotal': serializer.toJson<double>(lineTotal),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  QuoteItemRow copyWith({
    String? id,
    String? quoteId,
    String? productId,
    String? sku,
    String? oem,
    String? productName,
    String? brandName,
    double? unitPrice,
    int? quantity,
    double? lineTotal,
    int? sortOrder,
  }) => QuoteItemRow(
    id: id ?? this.id,
    quoteId: quoteId ?? this.quoteId,
    productId: productId ?? this.productId,
    sku: sku ?? this.sku,
    oem: oem ?? this.oem,
    productName: productName ?? this.productName,
    brandName: brandName ?? this.brandName,
    unitPrice: unitPrice ?? this.unitPrice,
    quantity: quantity ?? this.quantity,
    lineTotal: lineTotal ?? this.lineTotal,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  QuoteItemRow copyWithCompanion(QuoteItemsCompanion data) {
    return QuoteItemRow(
      id: data.id.present ? data.id.value : this.id,
      quoteId: data.quoteId.present ? data.quoteId.value : this.quoteId,
      productId: data.productId.present ? data.productId.value : this.productId,
      sku: data.sku.present ? data.sku.value : this.sku,
      oem: data.oem.present ? data.oem.value : this.oem,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      lineTotal: data.lineTotal.present ? data.lineTotal.value : this.lineTotal,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuoteItemRow(')
          ..write('id: $id, ')
          ..write('quoteId: $quoteId, ')
          ..write('productId: $productId, ')
          ..write('sku: $sku, ')
          ..write('oem: $oem, ')
          ..write('productName: $productName, ')
          ..write('brandName: $brandName, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('quantity: $quantity, ')
          ..write('lineTotal: $lineTotal, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    quoteId,
    productId,
    sku,
    oem,
    productName,
    brandName,
    unitPrice,
    quantity,
    lineTotal,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuoteItemRow &&
          other.id == this.id &&
          other.quoteId == this.quoteId &&
          other.productId == this.productId &&
          other.sku == this.sku &&
          other.oem == this.oem &&
          other.productName == this.productName &&
          other.brandName == this.brandName &&
          other.unitPrice == this.unitPrice &&
          other.quantity == this.quantity &&
          other.lineTotal == this.lineTotal &&
          other.sortOrder == this.sortOrder);
}

class QuoteItemsCompanion extends UpdateCompanion<QuoteItemRow> {
  final Value<String> id;
  final Value<String> quoteId;
  final Value<String> productId;
  final Value<String> sku;
  final Value<String> oem;
  final Value<String> productName;
  final Value<String> brandName;
  final Value<double> unitPrice;
  final Value<int> quantity;
  final Value<double> lineTotal;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const QuoteItemsCompanion({
    this.id = const Value.absent(),
    this.quoteId = const Value.absent(),
    this.productId = const Value.absent(),
    this.sku = const Value.absent(),
    this.oem = const Value.absent(),
    this.productName = const Value.absent(),
    this.brandName = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.lineTotal = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuoteItemsCompanion.insert({
    required String id,
    required String quoteId,
    required String productId,
    required String sku,
    this.oem = const Value.absent(),
    required String productName,
    this.brandName = const Value.absent(),
    required double unitPrice,
    required int quantity,
    required double lineTotal,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       quoteId = Value(quoteId),
       productId = Value(productId),
       sku = Value(sku),
       productName = Value(productName),
       unitPrice = Value(unitPrice),
       quantity = Value(quantity),
       lineTotal = Value(lineTotal);
  static Insertable<QuoteItemRow> custom({
    Expression<String>? id,
    Expression<String>? quoteId,
    Expression<String>? productId,
    Expression<String>? sku,
    Expression<String>? oem,
    Expression<String>? productName,
    Expression<String>? brandName,
    Expression<double>? unitPrice,
    Expression<int>? quantity,
    Expression<double>? lineTotal,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quoteId != null) 'quote_id': quoteId,
      if (productId != null) 'product_id': productId,
      if (sku != null) 'sku': sku,
      if (oem != null) 'oem': oem,
      if (productName != null) 'product_name': productName,
      if (brandName != null) 'brand_name': brandName,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (quantity != null) 'quantity': quantity,
      if (lineTotal != null) 'line_total': lineTotal,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuoteItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? quoteId,
    Value<String>? productId,
    Value<String>? sku,
    Value<String>? oem,
    Value<String>? productName,
    Value<String>? brandName,
    Value<double>? unitPrice,
    Value<int>? quantity,
    Value<double>? lineTotal,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return QuoteItemsCompanion(
      id: id ?? this.id,
      quoteId: quoteId ?? this.quoteId,
      productId: productId ?? this.productId,
      sku: sku ?? this.sku,
      oem: oem ?? this.oem,
      productName: productName ?? this.productName,
      brandName: brandName ?? this.brandName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      lineTotal: lineTotal ?? this.lineTotal,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quoteId.present) {
      map['quote_id'] = Variable<String>(quoteId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (oem.present) {
      map['oem'] = Variable<String>(oem.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (lineTotal.present) {
      map['line_total'] = Variable<double>(lineTotal.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuoteItemsCompanion(')
          ..write('id: $id, ')
          ..write('quoteId: $quoteId, ')
          ..write('productId: $productId, ')
          ..write('sku: $sku, ')
          ..write('oem: $oem, ')
          ..write('productName: $productName, ')
          ..write('brandName: $brandName, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('quantity: $quantity, ')
          ..write('lineTotal: $lineTotal, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $PartBrandsTable partBrands = $PartBrandsTable(this);
  late final $VehicleMakesTable vehicleMakes = $VehicleMakesTable(this);
  late final $VehicleModelsTable vehicleModels = $VehicleModelsTable(this);
  late final $EnginesTable engines = $EnginesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $ProductImagesTable productImages = $ProductImagesTable(this);
  late final $FitmentsTable fitments = $FitmentsTable(this);
  late final $QuotesTable quotes = $QuotesTable(this);
  late final $QuoteItemsTable quoteItems = $QuoteItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    partBrands,
    vehicleMakes,
    vehicleModels,
    engines,
    products,
    productImages,
    fitments,
    quotes,
    quoteItems,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicle_makes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vehicle_models', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicle_models',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('engines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('products', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'part_brands',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('products', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('product_images', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fitments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicle_models',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fitments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'engines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fitments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quotes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quote_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      Value<String> iconKey,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> iconKey,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<ProductRow>>
  _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: $_aliasNameGenerator(db.categories.id, db.products.categoryId),
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool productsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                description: description,
                iconKey: iconKey,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                description: description,
                iconKey: iconKey,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoriesTable,
                      ProductRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._productsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).productsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool productsRefs})
    >;
typedef $$PartBrandsTableCreateCompanionBuilder =
    PartBrandsCompanion Function({
      required String id,
      required String name,
      Value<String> country,
      Value<String> tier,
      Value<String?> logoUrl,
      Value<int> rowid,
    });
typedef $$PartBrandsTableUpdateCompanionBuilder =
    PartBrandsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> country,
      Value<String> tier,
      Value<String?> logoUrl,
      Value<int> rowid,
    });

final class $$PartBrandsTableReferences
    extends BaseReferences<_$AppDatabase, $PartBrandsTable, PartBrandRow> {
  $$PartBrandsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<ProductRow>>
  _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: $_aliasNameGenerator(db.partBrands.id, db.products.partBrandId),
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.partBrandId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PartBrandsTableFilterComposer
    extends Composer<_$AppDatabase, $PartBrandsTable> {
  $$PartBrandsTableFilterComposer({
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

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.partBrandId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartBrandsTableOrderingComposer
    extends Composer<_$AppDatabase, $PartBrandsTable> {
  $$PartBrandsTableOrderingComposer({
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

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartBrandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartBrandsTable> {
  $$PartBrandsTableAnnotationComposer({
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

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.partBrandId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PartBrandsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartBrandsTable,
          PartBrandRow,
          $$PartBrandsTableFilterComposer,
          $$PartBrandsTableOrderingComposer,
          $$PartBrandsTableAnnotationComposer,
          $$PartBrandsTableCreateCompanionBuilder,
          $$PartBrandsTableUpdateCompanionBuilder,
          (PartBrandRow, $$PartBrandsTableReferences),
          PartBrandRow,
          PrefetchHooks Function({bool productsRefs})
        > {
  $$PartBrandsTableTableManager(_$AppDatabase db, $PartBrandsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartBrandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartBrandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartBrandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartBrandsCompanion(
                id: id,
                name: name,
                country: country,
                tier: tier,
                logoUrl: logoUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> country = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PartBrandsCompanion.insert(
                id: id,
                name: name,
                country: country,
                tier: tier,
                logoUrl: logoUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PartBrandsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<
                      PartBrandRow,
                      $PartBrandsTable,
                      ProductRow
                    >(
                      currentTable: table,
                      referencedTable: $$PartBrandsTableReferences
                          ._productsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PartBrandsTableReferences(
                            db,
                            table,
                            p0,
                          ).productsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.partBrandId == item.id,
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

typedef $$PartBrandsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartBrandsTable,
      PartBrandRow,
      $$PartBrandsTableFilterComposer,
      $$PartBrandsTableOrderingComposer,
      $$PartBrandsTableAnnotationComposer,
      $$PartBrandsTableCreateCompanionBuilder,
      $$PartBrandsTableUpdateCompanionBuilder,
      (PartBrandRow, $$PartBrandsTableReferences),
      PartBrandRow,
      PrefetchHooks Function({bool productsRefs})
    >;
typedef $$VehicleMakesTableCreateCompanionBuilder =
    VehicleMakesCompanion Function({
      required String id,
      required String name,
      Value<String> country,
      Value<int> rowid,
    });
typedef $$VehicleMakesTableUpdateCompanionBuilder =
    VehicleMakesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> country,
      Value<int> rowid,
    });

final class $$VehicleMakesTableReferences
    extends BaseReferences<_$AppDatabase, $VehicleMakesTable, VehicleMakeRow> {
  $$VehicleMakesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VehicleModelsTable, List<VehicleModelRow>>
  _vehicleModelsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vehicleModels,
    aliasName: $_aliasNameGenerator(
      db.vehicleMakes.id,
      db.vehicleModels.makeId,
    ),
  );

  $$VehicleModelsTableProcessedTableManager get vehicleModelsRefs {
    final manager = $$VehicleModelsTableTableManager(
      $_db,
      $_db.vehicleModels,
    ).filter((f) => f.makeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vehicleModelsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehicleMakesTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleMakesTable> {
  $$VehicleMakesTableFilterComposer({
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

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> vehicleModelsRefs(
    Expression<bool> Function($$VehicleModelsTableFilterComposer f) f,
  ) {
    final $$VehicleModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicleModels,
      getReferencedColumn: (t) => t.makeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleModelsTableFilterComposer(
            $db: $db,
            $table: $db.vehicleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehicleMakesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleMakesTable> {
  $$VehicleMakesTableOrderingComposer({
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

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehicleMakesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleMakesTable> {
  $$VehicleMakesTableAnnotationComposer({
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

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  Expression<T> vehicleModelsRefs<T extends Object>(
    Expression<T> Function($$VehicleModelsTableAnnotationComposer a) f,
  ) {
    final $$VehicleModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicleModels,
      getReferencedColumn: (t) => t.makeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehicleMakesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleMakesTable,
          VehicleMakeRow,
          $$VehicleMakesTableFilterComposer,
          $$VehicleMakesTableOrderingComposer,
          $$VehicleMakesTableAnnotationComposer,
          $$VehicleMakesTableCreateCompanionBuilder,
          $$VehicleMakesTableUpdateCompanionBuilder,
          (VehicleMakeRow, $$VehicleMakesTableReferences),
          VehicleMakeRow,
          PrefetchHooks Function({bool vehicleModelsRefs})
        > {
  $$VehicleMakesTableTableManager(_$AppDatabase db, $VehicleMakesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleMakesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleMakesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleMakesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleMakesCompanion(
                id: id,
                name: name,
                country: country,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> country = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleMakesCompanion.insert(
                id: id,
                name: name,
                country: country,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehicleMakesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleModelsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (vehicleModelsRefs) db.vehicleModels,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (vehicleModelsRefs)
                    await $_getPrefetchedData<
                      VehicleMakeRow,
                      $VehicleMakesTable,
                      VehicleModelRow
                    >(
                      currentTable: table,
                      referencedTable: $$VehicleMakesTableReferences
                          ._vehicleModelsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$VehicleMakesTableReferences(
                            db,
                            table,
                            p0,
                          ).vehicleModelsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.makeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VehicleMakesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleMakesTable,
      VehicleMakeRow,
      $$VehicleMakesTableFilterComposer,
      $$VehicleMakesTableOrderingComposer,
      $$VehicleMakesTableAnnotationComposer,
      $$VehicleMakesTableCreateCompanionBuilder,
      $$VehicleMakesTableUpdateCompanionBuilder,
      (VehicleMakeRow, $$VehicleMakesTableReferences),
      VehicleMakeRow,
      PrefetchHooks Function({bool vehicleModelsRefs})
    >;
typedef $$VehicleModelsTableCreateCompanionBuilder =
    VehicleModelsCompanion Function({
      required String id,
      required String makeId,
      required String name,
      Value<String> bodyType,
      required int yearFrom,
      required int yearTo,
      Value<int> rowid,
    });
typedef $$VehicleModelsTableUpdateCompanionBuilder =
    VehicleModelsCompanion Function({
      Value<String> id,
      Value<String> makeId,
      Value<String> name,
      Value<String> bodyType,
      Value<int> yearFrom,
      Value<int> yearTo,
      Value<int> rowid,
    });

final class $$VehicleModelsTableReferences
    extends
        BaseReferences<_$AppDatabase, $VehicleModelsTable, VehicleModelRow> {
  $$VehicleModelsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehicleMakesTable _makeIdTable(_$AppDatabase db) =>
      db.vehicleMakes.createAlias(
        $_aliasNameGenerator(db.vehicleModels.makeId, db.vehicleMakes.id),
      );

  $$VehicleMakesTableProcessedTableManager get makeId {
    final $_column = $_itemColumn<String>('make_id')!;

    final manager = $$VehicleMakesTableTableManager(
      $_db,
      $_db.vehicleMakes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_makeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EnginesTable, List<EngineRow>> _enginesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.engines,
    aliasName: $_aliasNameGenerator(db.vehicleModels.id, db.engines.modelId),
  );

  $$EnginesTableProcessedTableManager get enginesRefs {
    final manager = $$EnginesTableTableManager(
      $_db,
      $_db.engines,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_enginesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FitmentsTable, List<FitmentRow>>
  _fitmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fitments,
    aliasName: $_aliasNameGenerator(db.vehicleModels.id, db.fitments.modelId),
  );

  $$FitmentsTableProcessedTableManager get fitmentsRefs {
    final manager = $$FitmentsTableTableManager(
      $_db,
      $_db.fitments,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_fitmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehicleModelsTableFilterComposer
    extends Composer<_$AppDatabase, $VehicleModelsTable> {
  $$VehicleModelsTableFilterComposer({
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

  ColumnFilters<String> get bodyType => $composableBuilder(
    column: $table.bodyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearTo => $composableBuilder(
    column: $table.yearTo,
    builder: (column) => ColumnFilters(column),
  );

  $$VehicleMakesTableFilterComposer get makeId {
    final $$VehicleMakesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.makeId,
      referencedTable: $db.vehicleMakes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleMakesTableFilterComposer(
            $db: $db,
            $table: $db.vehicleMakes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> enginesRefs(
    Expression<bool> Function($$EnginesTableFilterComposer f) f,
  ) {
    final $$EnginesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.engines,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnginesTableFilterComposer(
            $db: $db,
            $table: $db.engines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fitmentsRefs(
    Expression<bool> Function($$FitmentsTableFilterComposer f) f,
  ) {
    final $$FitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fitments,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FitmentsTableFilterComposer(
            $db: $db,
            $table: $db.fitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehicleModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $VehicleModelsTable> {
  $$VehicleModelsTableOrderingComposer({
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

  ColumnOrderings<String> get bodyType => $composableBuilder(
    column: $table.bodyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearTo => $composableBuilder(
    column: $table.yearTo,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehicleMakesTableOrderingComposer get makeId {
    final $$VehicleMakesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.makeId,
      referencedTable: $db.vehicleMakes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleMakesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicleMakes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehicleModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehicleModelsTable> {
  $$VehicleModelsTableAnnotationComposer({
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

  GeneratedColumn<String> get bodyType =>
      $composableBuilder(column: $table.bodyType, builder: (column) => column);

  GeneratedColumn<int> get yearFrom =>
      $composableBuilder(column: $table.yearFrom, builder: (column) => column);

  GeneratedColumn<int> get yearTo =>
      $composableBuilder(column: $table.yearTo, builder: (column) => column);

  $$VehicleMakesTableAnnotationComposer get makeId {
    final $$VehicleMakesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.makeId,
      referencedTable: $db.vehicleMakes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleMakesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleMakes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> enginesRefs<T extends Object>(
    Expression<T> Function($$EnginesTableAnnotationComposer a) f,
  ) {
    final $$EnginesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.engines,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnginesTableAnnotationComposer(
            $db: $db,
            $table: $db.engines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fitmentsRefs<T extends Object>(
    Expression<T> Function($$FitmentsTableAnnotationComposer a) f,
  ) {
    final $$FitmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fitments,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FitmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.fitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehicleModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehicleModelsTable,
          VehicleModelRow,
          $$VehicleModelsTableFilterComposer,
          $$VehicleModelsTableOrderingComposer,
          $$VehicleModelsTableAnnotationComposer,
          $$VehicleModelsTableCreateCompanionBuilder,
          $$VehicleModelsTableUpdateCompanionBuilder,
          (VehicleModelRow, $$VehicleModelsTableReferences),
          VehicleModelRow,
          PrefetchHooks Function({
            bool makeId,
            bool enginesRefs,
            bool fitmentsRefs,
          })
        > {
  $$VehicleModelsTableTableManager(_$AppDatabase db, $VehicleModelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehicleModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehicleModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehicleModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> makeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bodyType = const Value.absent(),
                Value<int> yearFrom = const Value.absent(),
                Value<int> yearTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehicleModelsCompanion(
                id: id,
                makeId: makeId,
                name: name,
                bodyType: bodyType,
                yearFrom: yearFrom,
                yearTo: yearTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String makeId,
                required String name,
                Value<String> bodyType = const Value.absent(),
                required int yearFrom,
                required int yearTo,
                Value<int> rowid = const Value.absent(),
              }) => VehicleModelsCompanion.insert(
                id: id,
                makeId: makeId,
                name: name,
                bodyType: bodyType,
                yearFrom: yearFrom,
                yearTo: yearTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehicleModelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({makeId = false, enginesRefs = false, fitmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (enginesRefs) db.engines,
                    if (fitmentsRefs) db.fitments,
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
                        if (makeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.makeId,
                                    referencedTable:
                                        $$VehicleModelsTableReferences
                                            ._makeIdTable(db),
                                    referencedColumn:
                                        $$VehicleModelsTableReferences
                                            ._makeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (enginesRefs)
                        await $_getPrefetchedData<
                          VehicleModelRow,
                          $VehicleModelsTable,
                          EngineRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehicleModelsTableReferences
                              ._enginesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehicleModelsTableReferences(
                                db,
                                table,
                                p0,
                              ).enginesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modelId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fitmentsRefs)
                        await $_getPrefetchedData<
                          VehicleModelRow,
                          $VehicleModelsTable,
                          FitmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$VehicleModelsTableReferences
                              ._fitmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehicleModelsTableReferences(
                                db,
                                table,
                                p0,
                              ).fitmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.modelId == item.id,
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

typedef $$VehicleModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehicleModelsTable,
      VehicleModelRow,
      $$VehicleModelsTableFilterComposer,
      $$VehicleModelsTableOrderingComposer,
      $$VehicleModelsTableAnnotationComposer,
      $$VehicleModelsTableCreateCompanionBuilder,
      $$VehicleModelsTableUpdateCompanionBuilder,
      (VehicleModelRow, $$VehicleModelsTableReferences),
      VehicleModelRow,
      PrefetchHooks Function({bool makeId, bool enginesRefs, bool fitmentsRefs})
    >;
typedef $$EnginesTableCreateCompanionBuilder =
    EnginesCompanion Function({
      required String id,
      required String modelId,
      required String code,
      required String name,
      Value<double> displacement,
      Value<String> fuel,
      Value<int> horsepower,
      required int yearFrom,
      required int yearTo,
      Value<int> rowid,
    });
typedef $$EnginesTableUpdateCompanionBuilder =
    EnginesCompanion Function({
      Value<String> id,
      Value<String> modelId,
      Value<String> code,
      Value<String> name,
      Value<double> displacement,
      Value<String> fuel,
      Value<int> horsepower,
      Value<int> yearFrom,
      Value<int> yearTo,
      Value<int> rowid,
    });

final class $$EnginesTableReferences
    extends BaseReferences<_$AppDatabase, $EnginesTable, EngineRow> {
  $$EnginesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehicleModelsTable _modelIdTable(_$AppDatabase db) =>
      db.vehicleModels.createAlias(
        $_aliasNameGenerator(db.engines.modelId, db.vehicleModels.id),
      );

  $$VehicleModelsTableProcessedTableManager get modelId {
    final $_column = $_itemColumn<String>('model_id')!;

    final manager = $$VehicleModelsTableTableManager(
      $_db,
      $_db.vehicleModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$FitmentsTable, List<FitmentRow>>
  _fitmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fitments,
    aliasName: $_aliasNameGenerator(db.engines.id, db.fitments.engineId),
  );

  $$FitmentsTableProcessedTableManager get fitmentsRefs {
    final manager = $$FitmentsTableTableManager(
      $_db,
      $_db.fitments,
    ).filter((f) => f.engineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_fitmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EnginesTableFilterComposer
    extends Composer<_$AppDatabase, $EnginesTable> {
  $$EnginesTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get displacement => $composableBuilder(
    column: $table.displacement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuel => $composableBuilder(
    column: $table.fuel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get horsepower => $composableBuilder(
    column: $table.horsepower,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearTo => $composableBuilder(
    column: $table.yearTo,
    builder: (column) => ColumnFilters(column),
  );

  $$VehicleModelsTableFilterComposer get modelId {
    final $$VehicleModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.vehicleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleModelsTableFilterComposer(
            $db: $db,
            $table: $db.vehicleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> fitmentsRefs(
    Expression<bool> Function($$FitmentsTableFilterComposer f) f,
  ) {
    final $$FitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fitments,
      getReferencedColumn: (t) => t.engineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FitmentsTableFilterComposer(
            $db: $db,
            $table: $db.fitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EnginesTableOrderingComposer
    extends Composer<_$AppDatabase, $EnginesTable> {
  $$EnginesTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get displacement => $composableBuilder(
    column: $table.displacement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuel => $composableBuilder(
    column: $table.fuel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get horsepower => $composableBuilder(
    column: $table.horsepower,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearTo => $composableBuilder(
    column: $table.yearTo,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehicleModelsTableOrderingComposer get modelId {
    final $$VehicleModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.vehicleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleModelsTableOrderingComposer(
            $db: $db,
            $table: $db.vehicleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnginesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnginesTable> {
  $$EnginesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get displacement => $composableBuilder(
    column: $table.displacement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fuel =>
      $composableBuilder(column: $table.fuel, builder: (column) => column);

  GeneratedColumn<int> get horsepower => $composableBuilder(
    column: $table.horsepower,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yearFrom =>
      $composableBuilder(column: $table.yearFrom, builder: (column) => column);

  GeneratedColumn<int> get yearTo =>
      $composableBuilder(column: $table.yearTo, builder: (column) => column);

  $$VehicleModelsTableAnnotationComposer get modelId {
    final $$VehicleModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.vehicleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> fitmentsRefs<T extends Object>(
    Expression<T> Function($$FitmentsTableAnnotationComposer a) f,
  ) {
    final $$FitmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fitments,
      getReferencedColumn: (t) => t.engineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FitmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.fitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EnginesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnginesTable,
          EngineRow,
          $$EnginesTableFilterComposer,
          $$EnginesTableOrderingComposer,
          $$EnginesTableAnnotationComposer,
          $$EnginesTableCreateCompanionBuilder,
          $$EnginesTableUpdateCompanionBuilder,
          (EngineRow, $$EnginesTableReferences),
          EngineRow,
          PrefetchHooks Function({bool modelId, bool fitmentsRefs})
        > {
  $$EnginesTableTableManager(_$AppDatabase db, $EnginesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnginesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnginesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnginesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> displacement = const Value.absent(),
                Value<String> fuel = const Value.absent(),
                Value<int> horsepower = const Value.absent(),
                Value<int> yearFrom = const Value.absent(),
                Value<int> yearTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EnginesCompanion(
                id: id,
                modelId: modelId,
                code: code,
                name: name,
                displacement: displacement,
                fuel: fuel,
                horsepower: horsepower,
                yearFrom: yearFrom,
                yearTo: yearTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String modelId,
                required String code,
                required String name,
                Value<double> displacement = const Value.absent(),
                Value<String> fuel = const Value.absent(),
                Value<int> horsepower = const Value.absent(),
                required int yearFrom,
                required int yearTo,
                Value<int> rowid = const Value.absent(),
              }) => EnginesCompanion.insert(
                id: id,
                modelId: modelId,
                code: code,
                name: name,
                displacement: displacement,
                fuel: fuel,
                horsepower: horsepower,
                yearFrom: yearFrom,
                yearTo: yearTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnginesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({modelId = false, fitmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (fitmentsRefs) db.fitments],
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
                    if (modelId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.modelId,
                                referencedTable: $$EnginesTableReferences
                                    ._modelIdTable(db),
                                referencedColumn: $$EnginesTableReferences
                                    ._modelIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (fitmentsRefs)
                    await $_getPrefetchedData<
                      EngineRow,
                      $EnginesTable,
                      FitmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$EnginesTableReferences
                          ._fitmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EnginesTableReferences(db, table, p0).fitmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.engineId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EnginesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnginesTable,
      EngineRow,
      $$EnginesTableFilterComposer,
      $$EnginesTableOrderingComposer,
      $$EnginesTableAnnotationComposer,
      $$EnginesTableCreateCompanionBuilder,
      $$EnginesTableUpdateCompanionBuilder,
      (EngineRow, $$EnginesTableReferences),
      EngineRow,
      PrefetchHooks Function({bool modelId, bool fitmentsRefs})
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String sku,
      required String oem,
      required String name,
      Value<String> description,
      required String categoryId,
      required String partBrandId,
      required double price,
      Value<double?> previousPrice,
      Value<int> stock,
      Value<int> warrantyMonths,
      Value<double> rating,
      Value<int> reviewCount,
      Value<bool> isFeatured,
      Value<String> specsJson,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> sku,
      Value<String> oem,
      Value<String> name,
      Value<String> description,
      Value<String> categoryId,
      Value<String> partBrandId,
      Value<double> price,
      Value<double?> previousPrice,
      Value<int> stock,
      Value<int> warrantyMonths,
      Value<double> rating,
      Value<int> reviewCount,
      Value<bool> isFeatured,
      Value<String> specsJson,
      Value<int> rowid,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductRow> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.products.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PartBrandsTable _partBrandIdTable(_$AppDatabase db) =>
      db.partBrands.createAlias(
        $_aliasNameGenerator(db.products.partBrandId, db.partBrands.id),
      );

  $$PartBrandsTableProcessedTableManager get partBrandId {
    final $_column = $_itemColumn<String>('part_brand_id')!;

    final manager = $$PartBrandsTableTableManager(
      $_db,
      $_db.partBrands,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_partBrandIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProductImagesTable, List<ProductImageRow>>
  _productImagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productImages,
    aliasName: $_aliasNameGenerator(db.products.id, db.productImages.productId),
  );

  $$ProductImagesTableProcessedTableManager get productImagesRefs {
    final manager = $$ProductImagesTableTableManager(
      $_db,
      $_db.productImages,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productImagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FitmentsTable, List<FitmentRow>>
  _fitmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fitments,
    aliasName: $_aliasNameGenerator(db.products.id, db.fitments.productId),
  );

  $$FitmentsTableProcessedTableManager get fitmentsRefs {
    final manager = $$FitmentsTableTableManager(
      $_db,
      $_db.fitments,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_fitmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
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

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oem => $composableBuilder(
    column: $table.oem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousPrice => $composableBuilder(
    column: $table.previousPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warrantyMonths => $composableBuilder(
    column: $table.warrantyMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFeatured => $composableBuilder(
    column: $table.isFeatured,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specsJson => $composableBuilder(
    column: $table.specsJson,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PartBrandsTableFilterComposer get partBrandId {
    final $$PartBrandsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partBrandId,
      referencedTable: $db.partBrands,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartBrandsTableFilterComposer(
            $db: $db,
            $table: $db.partBrands,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> productImagesRefs(
    Expression<bool> Function($$ProductImagesTableFilterComposer f) f,
  ) {
    final $$ProductImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productImages,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductImagesTableFilterComposer(
            $db: $db,
            $table: $db.productImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fitmentsRefs(
    Expression<bool> Function($$FitmentsTableFilterComposer f) f,
  ) {
    final $$FitmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fitments,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FitmentsTableFilterComposer(
            $db: $db,
            $table: $db.fitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
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

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oem => $composableBuilder(
    column: $table.oem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousPrice => $composableBuilder(
    column: $table.previousPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warrantyMonths => $composableBuilder(
    column: $table.warrantyMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFeatured => $composableBuilder(
    column: $table.isFeatured,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specsJson => $composableBuilder(
    column: $table.specsJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PartBrandsTableOrderingComposer get partBrandId {
    final $$PartBrandsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partBrandId,
      referencedTable: $db.partBrands,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartBrandsTableOrderingComposer(
            $db: $db,
            $table: $db.partBrands,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get oem =>
      $composableBuilder(column: $table.oem, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get previousPrice => $composableBuilder(
    column: $table.previousPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get warrantyMonths => $composableBuilder(
    column: $table.warrantyMonths,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get reviewCount => $composableBuilder(
    column: $table.reviewCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFeatured => $composableBuilder(
    column: $table.isFeatured,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specsJson =>
      $composableBuilder(column: $table.specsJson, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PartBrandsTableAnnotationComposer get partBrandId {
    final $$PartBrandsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.partBrandId,
      referencedTable: $db.partBrands,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PartBrandsTableAnnotationComposer(
            $db: $db,
            $table: $db.partBrands,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> productImagesRefs<T extends Object>(
    Expression<T> Function($$ProductImagesTableAnnotationComposer a) f,
  ) {
    final $$ProductImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productImages,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.productImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fitmentsRefs<T extends Object>(
    Expression<T> Function($$FitmentsTableAnnotationComposer a) f,
  ) {
    final $$FitmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fitments,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FitmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.fitments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRow, $$ProductsTableReferences),
          ProductRow,
          PrefetchHooks Function({
            bool categoryId,
            bool partBrandId,
            bool productImagesRefs,
            bool fitmentsRefs,
          })
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sku = const Value.absent(),
                Value<String> oem = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> partBrandId = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> previousPrice = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> warrantyMonths = const Value.absent(),
                Value<double> rating = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<bool> isFeatured = const Value.absent(),
                Value<String> specsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                sku: sku,
                oem: oem,
                name: name,
                description: description,
                categoryId: categoryId,
                partBrandId: partBrandId,
                price: price,
                previousPrice: previousPrice,
                stock: stock,
                warrantyMonths: warrantyMonths,
                rating: rating,
                reviewCount: reviewCount,
                isFeatured: isFeatured,
                specsJson: specsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sku,
                required String oem,
                required String name,
                Value<String> description = const Value.absent(),
                required String categoryId,
                required String partBrandId,
                required double price,
                Value<double?> previousPrice = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> warrantyMonths = const Value.absent(),
                Value<double> rating = const Value.absent(),
                Value<int> reviewCount = const Value.absent(),
                Value<bool> isFeatured = const Value.absent(),
                Value<String> specsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                sku: sku,
                oem: oem,
                name: name,
                description: description,
                categoryId: categoryId,
                partBrandId: partBrandId,
                price: price,
                previousPrice: previousPrice,
                stock: stock,
                warrantyMonths: warrantyMonths,
                rating: rating,
                reviewCount: reviewCount,
                isFeatured: isFeatured,
                specsJson: specsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                partBrandId = false,
                productImagesRefs = false,
                fitmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productImagesRefs) db.productImages,
                    if (fitmentsRefs) db.fitments,
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
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$ProductsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$ProductsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (partBrandId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.partBrandId,
                                    referencedTable: $$ProductsTableReferences
                                        ._partBrandIdTable(db),
                                    referencedColumn: $$ProductsTableReferences
                                        ._partBrandIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productImagesRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          ProductImageRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productImagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productImagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fitmentsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          FitmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._fitmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).fitmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
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

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, $$ProductsTableReferences),
      ProductRow,
      PrefetchHooks Function({
        bool categoryId,
        bool partBrandId,
        bool productImagesRefs,
        bool fitmentsRefs,
      })
    >;
typedef $$ProductImagesTableCreateCompanionBuilder =
    ProductImagesCompanion Function({
      required String id,
      required String productId,
      required String url,
      Value<int> sortOrder,
      Value<bool> isPrimary,
      Value<int> rowid,
    });
typedef $$ProductImagesTableUpdateCompanionBuilder =
    ProductImagesCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> url,
      Value<int> sortOrder,
      Value<bool> isPrimary,
      Value<int> rowid,
    });

final class $$ProductImagesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProductImagesTable, ProductImageRow> {
  $$ProductImagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias(
        $_aliasNameGenerator(db.productImages.productId, db.products.id),
      );

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductImagesTable> {
  $$ProductImagesTableFilterComposer({
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductImagesTable> {
  $$ProductImagesTableOrderingComposer({
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductImagesTable> {
  $$ProductImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductImagesTable,
          ProductImageRow,
          $$ProductImagesTableFilterComposer,
          $$ProductImagesTableOrderingComposer,
          $$ProductImagesTableAnnotationComposer,
          $$ProductImagesTableCreateCompanionBuilder,
          $$ProductImagesTableUpdateCompanionBuilder,
          (ProductImageRow, $$ProductImagesTableReferences),
          ProductImageRow,
          PrefetchHooks Function({bool productId})
        > {
  $$ProductImagesTableTableManager(_$AppDatabase db, $ProductImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductImagesCompanion(
                id: id,
                productId: productId,
                url: url,
                sortOrder: sortOrder,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String url,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductImagesCompanion.insert(
                id: id,
                productId: productId,
                url: url,
                sortOrder: sortOrder,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductImagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
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
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$ProductImagesTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$ProductImagesTableReferences
                                    ._productIdTable(db)
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

typedef $$ProductImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductImagesTable,
      ProductImageRow,
      $$ProductImagesTableFilterComposer,
      $$ProductImagesTableOrderingComposer,
      $$ProductImagesTableAnnotationComposer,
      $$ProductImagesTableCreateCompanionBuilder,
      $$ProductImagesTableUpdateCompanionBuilder,
      (ProductImageRow, $$ProductImagesTableReferences),
      ProductImageRow,
      PrefetchHooks Function({bool productId})
    >;
typedef $$FitmentsTableCreateCompanionBuilder =
    FitmentsCompanion Function({
      required String id,
      required String productId,
      required String modelId,
      Value<String?> engineId,
      required int yearFrom,
      required int yearTo,
      Value<int> rowid,
    });
typedef $$FitmentsTableUpdateCompanionBuilder =
    FitmentsCompanion Function({
      Value<String> id,
      Value<String> productId,
      Value<String> modelId,
      Value<String?> engineId,
      Value<int> yearFrom,
      Value<int> yearTo,
      Value<int> rowid,
    });

final class $$FitmentsTableReferences
    extends BaseReferences<_$AppDatabase, $FitmentsTable, FitmentRow> {
  $$FitmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) => db.products
      .createAlias($_aliasNameGenerator(db.fitments.productId, db.products.id));

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<String>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VehicleModelsTable _modelIdTable(_$AppDatabase db) =>
      db.vehicleModels.createAlias(
        $_aliasNameGenerator(db.fitments.modelId, db.vehicleModels.id),
      );

  $$VehicleModelsTableProcessedTableManager get modelId {
    final $_column = $_itemColumn<String>('model_id')!;

    final manager = $$VehicleModelsTableTableManager(
      $_db,
      $_db.vehicleModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EnginesTable _engineIdTable(_$AppDatabase db) => db.engines
      .createAlias($_aliasNameGenerator(db.fitments.engineId, db.engines.id));

  $$EnginesTableProcessedTableManager? get engineId {
    final $_column = $_itemColumn<String>('engine_id');
    if ($_column == null) return null;
    final manager = $$EnginesTableTableManager(
      $_db,
      $_db.engines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_engineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FitmentsTableFilterComposer
    extends Composer<_$AppDatabase, $FitmentsTable> {
  $$FitmentsTableFilterComposer({
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

  ColumnFilters<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearTo => $composableBuilder(
    column: $table.yearTo,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehicleModelsTableFilterComposer get modelId {
    final $$VehicleModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.vehicleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleModelsTableFilterComposer(
            $db: $db,
            $table: $db.vehicleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EnginesTableFilterComposer get engineId {
    final $$EnginesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.engineId,
      referencedTable: $db.engines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnginesTableFilterComposer(
            $db: $db,
            $table: $db.engines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FitmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $FitmentsTable> {
  $$FitmentsTableOrderingComposer({
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

  ColumnOrderings<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearTo => $composableBuilder(
    column: $table.yearTo,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehicleModelsTableOrderingComposer get modelId {
    final $$VehicleModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.vehicleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleModelsTableOrderingComposer(
            $db: $db,
            $table: $db.vehicleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EnginesTableOrderingComposer get engineId {
    final $$EnginesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.engineId,
      referencedTable: $db.engines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnginesTableOrderingComposer(
            $db: $db,
            $table: $db.engines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FitmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FitmentsTable> {
  $$FitmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get yearFrom =>
      $composableBuilder(column: $table.yearFrom, builder: (column) => column);

  GeneratedColumn<int> get yearTo =>
      $composableBuilder(column: $table.yearTo, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehicleModelsTableAnnotationComposer get modelId {
    final $$VehicleModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.vehicleModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehicleModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicleModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EnginesTableAnnotationComposer get engineId {
    final $$EnginesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.engineId,
      referencedTable: $db.engines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnginesTableAnnotationComposer(
            $db: $db,
            $table: $db.engines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FitmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FitmentsTable,
          FitmentRow,
          $$FitmentsTableFilterComposer,
          $$FitmentsTableOrderingComposer,
          $$FitmentsTableAnnotationComposer,
          $$FitmentsTableCreateCompanionBuilder,
          $$FitmentsTableUpdateCompanionBuilder,
          (FitmentRow, $$FitmentsTableReferences),
          FitmentRow,
          PrefetchHooks Function({bool productId, bool modelId, bool engineId})
        > {
  $$FitmentsTableTableManager(_$AppDatabase db, $FitmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FitmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FitmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FitmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String?> engineId = const Value.absent(),
                Value<int> yearFrom = const Value.absent(),
                Value<int> yearTo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FitmentsCompanion(
                id: id,
                productId: productId,
                modelId: modelId,
                engineId: engineId,
                yearFrom: yearFrom,
                yearTo: yearTo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String productId,
                required String modelId,
                Value<String?> engineId = const Value.absent(),
                required int yearFrom,
                required int yearTo,
                Value<int> rowid = const Value.absent(),
              }) => FitmentsCompanion.insert(
                id: id,
                productId: productId,
                modelId: modelId,
                engineId: engineId,
                yearFrom: yearFrom,
                yearTo: yearTo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FitmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({productId = false, modelId = false, engineId = false}) {
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
                        if (productId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productId,
                                    referencedTable: $$FitmentsTableReferences
                                        ._productIdTable(db),
                                    referencedColumn: $$FitmentsTableReferences
                                        ._productIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (modelId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.modelId,
                                    referencedTable: $$FitmentsTableReferences
                                        ._modelIdTable(db),
                                    referencedColumn: $$FitmentsTableReferences
                                        ._modelIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (engineId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.engineId,
                                    referencedTable: $$FitmentsTableReferences
                                        ._engineIdTable(db),
                                    referencedColumn: $$FitmentsTableReferences
                                        ._engineIdTable(db)
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

typedef $$FitmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FitmentsTable,
      FitmentRow,
      $$FitmentsTableFilterComposer,
      $$FitmentsTableOrderingComposer,
      $$FitmentsTableAnnotationComposer,
      $$FitmentsTableCreateCompanionBuilder,
      $$FitmentsTableUpdateCompanionBuilder,
      (FitmentRow, $$FitmentsTableReferences),
      FitmentRow,
      PrefetchHooks Function({bool productId, bool modelId, bool engineId})
    >;
typedef $$QuotesTableCreateCompanionBuilder =
    QuotesCompanion Function({
      required String id,
      Value<String> userId,
      Value<String> status,
      required String customerName,
      Value<String> customerPhone,
      required String customerEmail,
      Value<String> companyName,
      Value<String> notes,
      required double subtotal,
      Value<double> taxRate,
      required double taxAmount,
      required double total,
      Value<int> itemCount,
      Value<int> unitCount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$QuotesTableUpdateCompanionBuilder =
    QuotesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> status,
      Value<String> customerName,
      Value<String> customerPhone,
      Value<String> customerEmail,
      Value<String> companyName,
      Value<String> notes,
      Value<double> subtotal,
      Value<double> taxRate,
      Value<double> taxAmount,
      Value<double> total,
      Value<int> itemCount,
      Value<int> unitCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$QuotesTableReferences
    extends BaseReferences<_$AppDatabase, $QuotesTable, QuoteRow> {
  $$QuotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuoteItemsTable, List<QuoteItemRow>>
  _quoteItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.quoteItems,
    aliasName: $_aliasNameGenerator(db.quotes.id, db.quoteItems.quoteId),
  );

  $$QuoteItemsTableProcessedTableManager get quoteItemsRefs {
    final manager = $$QuoteItemsTableTableManager(
      $_db,
      $_db.quoteItems,
    ).filter((f) => f.quoteId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_quoteItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuotesTableFilterComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerEmail => $composableBuilder(
    column: $table.customerEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxRate => $composableBuilder(
    column: $table.taxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCount => $composableBuilder(
    column: $table.unitCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> quoteItemsRefs(
    Expression<bool> Function($$QuoteItemsTableFilterComposer f) f,
  ) {
    final $$QuoteItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quoteItems,
      getReferencedColumn: (t) => t.quoteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuoteItemsTableFilterComposer(
            $db: $db,
            $table: $db.quoteItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerEmail => $composableBuilder(
    column: $table.customerEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxRate => $composableBuilder(
    column: $table.taxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemCount => $composableBuilder(
    column: $table.itemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCount => $composableBuilder(
    column: $table.unitCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerPhone => $composableBuilder(
    column: $table.customerPhone,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerEmail => $composableBuilder(
    column: $table.customerEmail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get taxRate =>
      $composableBuilder(column: $table.taxRate, builder: (column) => column);

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<int> get itemCount =>
      $composableBuilder(column: $table.itemCount, builder: (column) => column);

  GeneratedColumn<int> get unitCount =>
      $composableBuilder(column: $table.unitCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> quoteItemsRefs<T extends Object>(
    Expression<T> Function($$QuoteItemsTableAnnotationComposer a) f,
  ) {
    final $$QuoteItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quoteItems,
      getReferencedColumn: (t) => t.quoteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuoteItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.quoteItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuotesTable,
          QuoteRow,
          $$QuotesTableFilterComposer,
          $$QuotesTableOrderingComposer,
          $$QuotesTableAnnotationComposer,
          $$QuotesTableCreateCompanionBuilder,
          $$QuotesTableUpdateCompanionBuilder,
          (QuoteRow, $$QuotesTableReferences),
          QuoteRow,
          PrefetchHooks Function({bool quoteItemsRefs})
        > {
  $$QuotesTableTableManager(_$AppDatabase db, $QuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> customerPhone = const Value.absent(),
                Value<String> customerEmail = const Value.absent(),
                Value<String> companyName = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> taxRate = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<int> itemCount = const Value.absent(),
                Value<int> unitCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion(
                id: id,
                userId: userId,
                status: status,
                customerName: customerName,
                customerPhone: customerPhone,
                customerEmail: customerEmail,
                companyName: companyName,
                notes: notes,
                subtotal: subtotal,
                taxRate: taxRate,
                taxAmount: taxAmount,
                total: total,
                itemCount: itemCount,
                unitCount: unitCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> userId = const Value.absent(),
                Value<String> status = const Value.absent(),
                required String customerName,
                Value<String> customerPhone = const Value.absent(),
                required String customerEmail,
                Value<String> companyName = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required double subtotal,
                Value<double> taxRate = const Value.absent(),
                required double taxAmount,
                required double total,
                Value<int> itemCount = const Value.absent(),
                Value<int> unitCount = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion.insert(
                id: id,
                userId: userId,
                status: status,
                customerName: customerName,
                customerPhone: customerPhone,
                customerEmail: customerEmail,
                companyName: companyName,
                notes: notes,
                subtotal: subtotal,
                taxRate: taxRate,
                taxAmount: taxAmount,
                total: total,
                itemCount: itemCount,
                unitCount: unitCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$QuotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({quoteItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (quoteItemsRefs) db.quoteItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (quoteItemsRefs)
                    await $_getPrefetchedData<
                      QuoteRow,
                      $QuotesTable,
                      QuoteItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$QuotesTableReferences
                          ._quoteItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$QuotesTableReferences(db, table, p0).quoteItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.quoteId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$QuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuotesTable,
      QuoteRow,
      $$QuotesTableFilterComposer,
      $$QuotesTableOrderingComposer,
      $$QuotesTableAnnotationComposer,
      $$QuotesTableCreateCompanionBuilder,
      $$QuotesTableUpdateCompanionBuilder,
      (QuoteRow, $$QuotesTableReferences),
      QuoteRow,
      PrefetchHooks Function({bool quoteItemsRefs})
    >;
typedef $$QuoteItemsTableCreateCompanionBuilder =
    QuoteItemsCompanion Function({
      required String id,
      required String quoteId,
      required String productId,
      required String sku,
      Value<String> oem,
      required String productName,
      Value<String> brandName,
      required double unitPrice,
      required int quantity,
      required double lineTotal,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$QuoteItemsTableUpdateCompanionBuilder =
    QuoteItemsCompanion Function({
      Value<String> id,
      Value<String> quoteId,
      Value<String> productId,
      Value<String> sku,
      Value<String> oem,
      Value<String> productName,
      Value<String> brandName,
      Value<double> unitPrice,
      Value<int> quantity,
      Value<double> lineTotal,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$QuoteItemsTableReferences
    extends BaseReferences<_$AppDatabase, $QuoteItemsTable, QuoteItemRow> {
  $$QuoteItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuotesTable _quoteIdTable(_$AppDatabase db) => db.quotes.createAlias(
    $_aliasNameGenerator(db.quoteItems.quoteId, db.quotes.id),
  );

  $$QuotesTableProcessedTableManager get quoteId {
    final $_column = $_itemColumn<String>('quote_id')!;

    final manager = $$QuotesTableTableManager(
      $_db,
      $_db.quotes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quoteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuoteItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QuoteItemsTable> {
  $$QuoteItemsTableFilterComposer({
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

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oem => $composableBuilder(
    column: $table.oem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$QuotesTableFilterComposer get quoteId {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quoteId,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableFilterComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuoteItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuoteItemsTable> {
  $$QuoteItemsTableOrderingComposer({
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

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oem => $composableBuilder(
    column: $table.oem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lineTotal => $composableBuilder(
    column: $table.lineTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuotesTableOrderingComposer get quoteId {
    final $$QuotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quoteId,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableOrderingComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuoteItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuoteItemsTable> {
  $$QuoteItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get oem =>
      $composableBuilder(column: $table.oem, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get lineTotal =>
      $composableBuilder(column: $table.lineTotal, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$QuotesTableAnnotationComposer get quoteId {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quoteId,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuoteItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuoteItemsTable,
          QuoteItemRow,
          $$QuoteItemsTableFilterComposer,
          $$QuoteItemsTableOrderingComposer,
          $$QuoteItemsTableAnnotationComposer,
          $$QuoteItemsTableCreateCompanionBuilder,
          $$QuoteItemsTableUpdateCompanionBuilder,
          (QuoteItemRow, $$QuoteItemsTableReferences),
          QuoteItemRow,
          PrefetchHooks Function({bool quoteId})
        > {
  $$QuoteItemsTableTableManager(_$AppDatabase db, $QuoteItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuoteItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuoteItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuoteItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> quoteId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> sku = const Value.absent(),
                Value<String> oem = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String> brandName = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> lineTotal = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuoteItemsCompanion(
                id: id,
                quoteId: quoteId,
                productId: productId,
                sku: sku,
                oem: oem,
                productName: productName,
                brandName: brandName,
                unitPrice: unitPrice,
                quantity: quantity,
                lineTotal: lineTotal,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String quoteId,
                required String productId,
                required String sku,
                Value<String> oem = const Value.absent(),
                required String productName,
                Value<String> brandName = const Value.absent(),
                required double unitPrice,
                required int quantity,
                required double lineTotal,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuoteItemsCompanion.insert(
                id: id,
                quoteId: quoteId,
                productId: productId,
                sku: sku,
                oem: oem,
                productName: productName,
                brandName: brandName,
                unitPrice: unitPrice,
                quantity: quantity,
                lineTotal: lineTotal,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuoteItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({quoteId = false}) {
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
                    if (quoteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.quoteId,
                                referencedTable: $$QuoteItemsTableReferences
                                    ._quoteIdTable(db),
                                referencedColumn: $$QuoteItemsTableReferences
                                    ._quoteIdTable(db)
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

typedef $$QuoteItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuoteItemsTable,
      QuoteItemRow,
      $$QuoteItemsTableFilterComposer,
      $$QuoteItemsTableOrderingComposer,
      $$QuoteItemsTableAnnotationComposer,
      $$QuoteItemsTableCreateCompanionBuilder,
      $$QuoteItemsTableUpdateCompanionBuilder,
      (QuoteItemRow, $$QuoteItemsTableReferences),
      QuoteItemRow,
      PrefetchHooks Function({bool quoteId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$PartBrandsTableTableManager get partBrands =>
      $$PartBrandsTableTableManager(_db, _db.partBrands);
  $$VehicleMakesTableTableManager get vehicleMakes =>
      $$VehicleMakesTableTableManager(_db, _db.vehicleMakes);
  $$VehicleModelsTableTableManager get vehicleModels =>
      $$VehicleModelsTableTableManager(_db, _db.vehicleModels);
  $$EnginesTableTableManager get engines =>
      $$EnginesTableTableManager(_db, _db.engines);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$ProductImagesTableTableManager get productImages =>
      $$ProductImagesTableTableManager(_db, _db.productImages);
  $$FitmentsTableTableManager get fitments =>
      $$FitmentsTableTableManager(_db, _db.fitments);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
  $$QuoteItemsTableTableManager get quoteItems =>
      $$QuoteItemsTableTableManager(_db, _db.quoteItems);
}
