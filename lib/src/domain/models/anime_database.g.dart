// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_database.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnimeDatabaseCollection on Isar {
  IsarCollection<AnimeDatabase> get animeDatabases => this.collection();
}

const AnimeDatabaseSchema = CollectionSchema(
  name: r'animeDatabase',
  id: 5157471302420633738,
  properties: {
    r'animeName': PropertySchema(
      id: 0,
      name: r'animeName',
      type: IsarType.string,
    ),
    r'imageUrl': PropertySchema(
      id: 1,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'lastUpdate': PropertySchema(
      id: 2,
      name: r'lastUpdate',
      type: IsarType.dateTime,
    ),
    r'shikimoriId': PropertySchema(
      id: 3,
      name: r'shikimoriId',
      type: IsarType.long,
    ),
    r'studios': PropertySchema(
      id: 4,
      name: r'studios',
      type: IsarType.objectList,
      target: r'Studio',
    )
  },
  estimateSize: _animeDatabaseEstimateSize,
  serialize: _animeDatabaseSerialize,
  deserialize: _animeDatabaseDeserialize,
  deserializeProp: _animeDatabaseDeserializeProp,
  idName: r'id',
  indexes: {
    r'shikimoriId': IndexSchema(
      id: -406814047258590623,
      name: r'shikimoriId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'shikimoriId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'Studio': StudioSchema, r'Episode': EpisodeSchema},
  getId: _animeDatabaseGetId,
  getLinks: _animeDatabaseGetLinks,
  attach: _animeDatabaseAttach,
  version: '3.1.0+1',
);

int _animeDatabaseEstimateSize(
  AnimeDatabase object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.animeName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.studios;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[Studio]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += StudioSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  return bytesCount;
}

void _animeDatabaseSerialize(
  AnimeDatabase object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animeName);
  writer.writeString(offsets[1], object.imageUrl);
  writer.writeDateTime(offsets[2], object.lastUpdate);
  writer.writeLong(offsets[3], object.shikimoriId);
  writer.writeObjectList<Studio>(
    offsets[4],
    allOffsets,
    StudioSchema.serialize,
    object.studios,
  );
}

AnimeDatabase _animeDatabaseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnimeDatabase();
  object.animeName = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.imageUrl = reader.readStringOrNull(offsets[1]);
  object.lastUpdate = reader.readDateTimeOrNull(offsets[2]);
  object.shikimoriId = reader.readLong(offsets[3]);
  object.studios = reader.readObjectList<Studio>(
    offsets[4],
    StudioSchema.deserialize,
    allOffsets,
    Studio(),
  );
  return object;
}

P _animeDatabaseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readObjectList<Studio>(
        offset,
        StudioSchema.deserialize,
        allOffsets,
        Studio(),
      )) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _animeDatabaseGetId(AnimeDatabase object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _animeDatabaseGetLinks(AnimeDatabase object) {
  return [];
}

void _animeDatabaseAttach(
    IsarCollection<dynamic> col, Id id, AnimeDatabase object) {
  object.id = id;
}

extension AnimeDatabaseByIndex on IsarCollection<AnimeDatabase> {
  Future<AnimeDatabase?> getByShikimoriId(int shikimoriId) {
    return getByIndex(r'shikimoriId', [shikimoriId]);
  }

  AnimeDatabase? getByShikimoriIdSync(int shikimoriId) {
    return getByIndexSync(r'shikimoriId', [shikimoriId]);
  }

  Future<bool> deleteByShikimoriId(int shikimoriId) {
    return deleteByIndex(r'shikimoriId', [shikimoriId]);
  }

  bool deleteByShikimoriIdSync(int shikimoriId) {
    return deleteByIndexSync(r'shikimoriId', [shikimoriId]);
  }

  Future<List<AnimeDatabase?>> getAllByShikimoriId(
      List<int> shikimoriIdValues) {
    final values = shikimoriIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'shikimoriId', values);
  }

  List<AnimeDatabase?> getAllByShikimoriIdSync(List<int> shikimoriIdValues) {
    final values = shikimoriIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'shikimoriId', values);
  }

  Future<int> deleteAllByShikimoriId(List<int> shikimoriIdValues) {
    final values = shikimoriIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'shikimoriId', values);
  }

  int deleteAllByShikimoriIdSync(List<int> shikimoriIdValues) {
    final values = shikimoriIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'shikimoriId', values);
  }

  Future<Id> putByShikimoriId(AnimeDatabase object) {
    return putByIndex(r'shikimoriId', object);
  }

  Id putByShikimoriIdSync(AnimeDatabase object, {bool saveLinks = true}) {
    return putByIndexSync(r'shikimoriId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByShikimoriId(List<AnimeDatabase> objects) {
    return putAllByIndex(r'shikimoriId', objects);
  }

  List<Id> putAllByShikimoriIdSync(List<AnimeDatabase> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'shikimoriId', objects, saveLinks: saveLinks);
  }
}

extension AnimeDatabaseQueryWhereSort
    on QueryBuilder<AnimeDatabase, AnimeDatabase, QWhere> {
  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhere> anyShikimoriId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'shikimoriId'),
      );
    });
  }
}

extension AnimeDatabaseQueryWhere
    on QueryBuilder<AnimeDatabase, AnimeDatabase, QWhereClause> {
  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause>
      shikimoriIdEqualTo(int shikimoriId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'shikimoriId',
        value: [shikimoriId],
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause>
      shikimoriIdNotEqualTo(int shikimoriId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shikimoriId',
              lower: [],
              upper: [shikimoriId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shikimoriId',
              lower: [shikimoriId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shikimoriId',
              lower: [shikimoriId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'shikimoriId',
              lower: [],
              upper: [shikimoriId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause>
      shikimoriIdGreaterThan(
    int shikimoriId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'shikimoriId',
        lower: [shikimoriId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause>
      shikimoriIdLessThan(
    int shikimoriId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'shikimoriId',
        lower: [],
        upper: [shikimoriId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterWhereClause>
      shikimoriIdBetween(
    int lowerShikimoriId,
    int upperShikimoriId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'shikimoriId',
        lower: [lowerShikimoriId],
        includeLower: includeLower,
        upper: [upperShikimoriId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AnimeDatabaseQueryFilter
    on QueryBuilder<AnimeDatabase, AnimeDatabase, QFilterCondition> {
  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'animeName',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'animeName',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'animeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'animeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animeName',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      animeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animeName',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      lastUpdateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUpdate',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      lastUpdateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUpdate',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      lastUpdateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      lastUpdateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      lastUpdateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      lastUpdateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      shikimoriIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shikimoriId',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      shikimoriIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shikimoriId',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      shikimoriIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shikimoriId',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      shikimoriIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shikimoriId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      studiosIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'studios',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      studiosIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'studios',
      ));
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      studiosLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'studios',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      studiosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'studios',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      studiosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'studios',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      studiosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'studios',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      studiosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'studios',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      studiosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'studios',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension AnimeDatabaseQueryObject
    on QueryBuilder<AnimeDatabase, AnimeDatabase, QFilterCondition> {
  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterFilterCondition>
      studiosElement(FilterQuery<Studio> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'studios');
    });
  }
}

extension AnimeDatabaseQueryLinks
    on QueryBuilder<AnimeDatabase, AnimeDatabase, QFilterCondition> {}

extension AnimeDatabaseQuerySortBy
    on QueryBuilder<AnimeDatabase, AnimeDatabase, QSortBy> {
  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> sortByAnimeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeName', Sort.asc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy>
      sortByAnimeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeName', Sort.desc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy>
      sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> sortByLastUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.asc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy>
      sortByLastUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.desc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> sortByShikimoriId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shikimoriId', Sort.asc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy>
      sortByShikimoriIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shikimoriId', Sort.desc);
    });
  }
}

extension AnimeDatabaseQuerySortThenBy
    on QueryBuilder<AnimeDatabase, AnimeDatabase, QSortThenBy> {
  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> thenByAnimeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeName', Sort.asc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy>
      thenByAnimeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animeName', Sort.desc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy>
      thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> thenByLastUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.asc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy>
      thenByLastUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdate', Sort.desc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy> thenByShikimoriId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shikimoriId', Sort.asc);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QAfterSortBy>
      thenByShikimoriIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shikimoriId', Sort.desc);
    });
  }
}

extension AnimeDatabaseQueryWhereDistinct
    on QueryBuilder<AnimeDatabase, AnimeDatabase, QDistinct> {
  QueryBuilder<AnimeDatabase, AnimeDatabase, QDistinct> distinctByAnimeName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animeName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QDistinct> distinctByLastUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdate');
    });
  }

  QueryBuilder<AnimeDatabase, AnimeDatabase, QDistinct>
      distinctByShikimoriId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shikimoriId');
    });
  }
}

extension AnimeDatabaseQueryProperty
    on QueryBuilder<AnimeDatabase, AnimeDatabase, QQueryProperty> {
  QueryBuilder<AnimeDatabase, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnimeDatabase, String?, QQueryOperations> animeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animeName');
    });
  }

  QueryBuilder<AnimeDatabase, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<AnimeDatabase, DateTime?, QQueryOperations>
      lastUpdateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdate');
    });
  }

  QueryBuilder<AnimeDatabase, int, QQueryOperations> shikimoriIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shikimoriId');
    });
  }

  QueryBuilder<AnimeDatabase, List<Studio>?, QQueryOperations>
      studiosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'studios');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const EpisodeSchema = Schema(
  name: r'Episode',
  id: -3258565036328751473,
  properties: {
    r'additionalInfo': PropertySchema(
      id: 0,
      name: r'additionalInfo',
      type: IsarType.string,
    ),
    r'isComplete': PropertySchema(
      id: 1,
      name: r'isComplete',
      type: IsarType.bool,
    ),
    r'nubmer': PropertySchema(
      id: 2,
      name: r'nubmer',
      type: IsarType.long,
    ),
    r'position': PropertySchema(
      id: 3,
      name: r'position',
      type: IsarType.string,
    ),
    r'timeStamp': PropertySchema(
      id: 4,
      name: r'timeStamp',
      type: IsarType.string,
    )
  },
  estimateSize: _episodeEstimateSize,
  serialize: _episodeSerialize,
  deserialize: _episodeDeserialize,
  deserializeProp: _episodeDeserializeProp,
);

int _episodeEstimateSize(
  Episode object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.additionalInfo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.position;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.timeStamp;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _episodeSerialize(
  Episode object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.additionalInfo);
  writer.writeBool(offsets[1], object.isComplete);
  writer.writeLong(offsets[2], object.nubmer);
  writer.writeString(offsets[3], object.position);
  writer.writeString(offsets[4], object.timeStamp);
}

Episode _episodeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Episode(
    additionalInfo: reader.readStringOrNull(offsets[0]),
    isComplete: reader.readBoolOrNull(offsets[1]),
    nubmer: reader.readLongOrNull(offsets[2]),
    position: reader.readStringOrNull(offsets[3]),
    timeStamp: reader.readStringOrNull(offsets[4]),
  );
  return object;
}

P _episodeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension EpisodeQueryFilter
    on QueryBuilder<Episode, Episode, QFilterCondition> {
  QueryBuilder<Episode, Episode, QAfterFilterCondition> additionalInfoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'additionalInfo',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      additionalInfoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'additionalInfo',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> additionalInfoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      additionalInfoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'additionalInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> additionalInfoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'additionalInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> additionalInfoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'additionalInfo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      additionalInfoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'additionalInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> additionalInfoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'additionalInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> additionalInfoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'additionalInfo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> additionalInfoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'additionalInfo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      additionalInfoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'additionalInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition>
      additionalInfoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'additionalInfo',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> isCompleteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isComplete',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> isCompleteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isComplete',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> isCompleteEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isComplete',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> nubmerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nubmer',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> nubmerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nubmer',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> nubmerEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nubmer',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> nubmerGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nubmer',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> nubmerLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nubmer',
        value: value,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> nubmerBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nubmer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'position',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'position',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'position',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'position',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'position',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'position',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'position',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'position',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'position',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'position',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'position',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> positionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'position',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'timeStamp',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'timeStamp',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeStamp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timeStamp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timeStamp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timeStamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'timeStamp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'timeStamp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'timeStamp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'timeStamp',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timeStamp',
        value: '',
      ));
    });
  }

  QueryBuilder<Episode, Episode, QAfterFilterCondition> timeStampIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'timeStamp',
        value: '',
      ));
    });
  }
}

extension EpisodeQueryObject
    on QueryBuilder<Episode, Episode, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const StudioSchema = Schema(
  name: r'Studio',
  id: 7142960261740749730,
  properties: {
    r'created': PropertySchema(
      id: 0,
      name: r'created',
      type: IsarType.dateTime,
    ),
    r'episodes': PropertySchema(
      id: 1,
      name: r'episodes',
      type: IsarType.objectList,
      target: r'Episode',
    ),
    r'id': PropertySchema(
      id: 2,
      name: r'id',
      type: IsarType.long,
    ),
    r'lastEpisodeIndex': PropertySchema(
      id: 3,
      name: r'lastEpisodeIndex',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 5,
      name: r'type',
      type: IsarType.string,
    ),
    r'updated': PropertySchema(
      id: 6,
      name: r'updated',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _studioEstimateSize,
  serialize: _studioSerialize,
  deserialize: _studioDeserialize,
  deserializeProp: _studioDeserializeProp,
);

int _studioEstimateSize(
  Studio object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.episodes;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[Episode]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += EpisodeSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.type;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _studioSerialize(
  Studio object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.created);
  writer.writeObjectList<Episode>(
    offsets[1],
    allOffsets,
    EpisodeSchema.serialize,
    object.episodes,
  );
  writer.writeLong(offsets[2], object.id);
  writer.writeLong(offsets[3], object.lastEpisodeIndex);
  writer.writeString(offsets[4], object.name);
  writer.writeString(offsets[5], object.type);
  writer.writeDateTime(offsets[6], object.updated);
}

Studio _studioDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Studio();
  object.created = reader.readDateTimeOrNull(offsets[0]);
  object.episodes = reader.readObjectList<Episode>(
    offsets[1],
    EpisodeSchema.deserialize,
    allOffsets,
    Episode(),
  );
  object.id = reader.readLongOrNull(offsets[2]);
  object.lastEpisodeIndex = reader.readLong(offsets[3]);
  object.name = reader.readStringOrNull(offsets[4]);
  object.type = reader.readStringOrNull(offsets[5]);
  object.updated = reader.readDateTimeOrNull(offsets[6]);
  return object;
}

P _studioDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<Episode>(
        offset,
        EpisodeSchema.deserialize,
        allOffsets,
        Episode(),
      )) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension StudioQueryFilter on QueryBuilder<Studio, Studio, QFilterCondition> {
  QueryBuilder<Studio, Studio, QAfterFilterCondition> createdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'created',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> createdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'created',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> createdEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'created',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> createdGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'created',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> createdLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'created',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> createdBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'created',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> episodesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'episodes',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> episodesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'episodes',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> episodesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> episodesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> episodesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> episodesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> episodesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> episodesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'episodes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'id',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> idEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> idGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> idLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> idBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> lastEpisodeIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastEpisodeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition>
      lastEpisodeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastEpisodeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> lastEpisodeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastEpisodeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> lastEpisodeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastEpisodeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'type',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> updatedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updated',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> updatedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updated',
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> updatedEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updated',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> updatedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updated',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> updatedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updated',
        value: value,
      ));
    });
  }

  QueryBuilder<Studio, Studio, QAfterFilterCondition> updatedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StudioQueryObject on QueryBuilder<Studio, Studio, QFilterCondition> {
  QueryBuilder<Studio, Studio, QAfterFilterCondition> episodesElement(
      FilterQuery<Episode> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'episodes');
    });
  }
}
