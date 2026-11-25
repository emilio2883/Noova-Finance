// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetImportRecordCollection on Isar {
  IsarCollection<ImportRecord> get importRecords => this.collection();
}

const ImportRecordSchema = CollectionSchema(
  name: r'ImportRecord',
  id: -2843428769293799400,
  properties: {
    r'fileName': PropertySchema(
      id: 0,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'imported': PropertySchema(
      id: 1,
      name: r'imported',
      type: IsarType.long,
    ),
    r'importedAt': PropertySchema(
      id: 2,
      name: r'importedAt',
      type: IsarType.dateTime,
    ),
    r'skipped': PropertySchema(
      id: 3,
      name: r'skipped',
      type: IsarType.long,
    )
  },
  estimateSize: _importRecordEstimateSize,
  serialize: _importRecordSerialize,
  deserialize: _importRecordDeserialize,
  deserializeProp: _importRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _importRecordGetId,
  getLinks: _importRecordGetLinks,
  attach: _importRecordAttach,
  version: '3.1.0+1',
);

int _importRecordEstimateSize(
  ImportRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fileName.length * 3;
  return bytesCount;
}

void _importRecordSerialize(
  ImportRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.fileName);
  writer.writeLong(offsets[1], object.imported);
  writer.writeDateTime(offsets[2], object.importedAt);
  writer.writeLong(offsets[3], object.skipped);
}

ImportRecord _importRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ImportRecord(
    fileName: reader.readString(offsets[0]),
    imported: reader.readLong(offsets[1]),
    importedAt: reader.readDateTime(offsets[2]),
    skipped: reader.readLong(offsets[3]),
  );
  object.id = id;
  return object;
}

P _importRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _importRecordGetId(ImportRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _importRecordGetLinks(ImportRecord object) {
  return [];
}

void _importRecordAttach(
    IsarCollection<dynamic> col, Id id, ImportRecord object) {
  object.id = id;
}

extension ImportRecordQueryWhereSort
    on QueryBuilder<ImportRecord, ImportRecord, QWhere> {
  QueryBuilder<ImportRecord, ImportRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ImportRecordQueryWhere
    on QueryBuilder<ImportRecord, ImportRecord, QWhereClause> {
  QueryBuilder<ImportRecord, ImportRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ImportRecord, ImportRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterWhereClause> idBetween(
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
}

extension ImportRecordQueryFilter
    on QueryBuilder<ImportRecord, ImportRecord, QFilterCondition> {
  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      importedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imported',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      importedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imported',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      importedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imported',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      importedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imported',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      importedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'importedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      importedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'importedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      importedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'importedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      importedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'importedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      skippedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'skipped',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      skippedGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'skipped',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      skippedLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'skipped',
        value: value,
      ));
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterFilterCondition>
      skippedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'skipped',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ImportRecordQueryObject
    on QueryBuilder<ImportRecord, ImportRecord, QFilterCondition> {}

extension ImportRecordQueryLinks
    on QueryBuilder<ImportRecord, ImportRecord, QFilterCondition> {}

extension ImportRecordQuerySortBy
    on QueryBuilder<ImportRecord, ImportRecord, QSortBy> {
  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> sortByImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imported', Sort.asc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> sortByImportedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imported', Sort.desc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> sortByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy>
      sortByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> sortBySkipped() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipped', Sort.asc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> sortBySkippedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipped', Sort.desc);
    });
  }
}

extension ImportRecordQuerySortThenBy
    on QueryBuilder<ImportRecord, ImportRecord, QSortThenBy> {
  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> thenByImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imported', Sort.asc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> thenByImportedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imported', Sort.desc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> thenByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.asc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy>
      thenByImportedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importedAt', Sort.desc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> thenBySkipped() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipped', Sort.asc);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QAfterSortBy> thenBySkippedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'skipped', Sort.desc);
    });
  }
}

extension ImportRecordQueryWhereDistinct
    on QueryBuilder<ImportRecord, ImportRecord, QDistinct> {
  QueryBuilder<ImportRecord, ImportRecord, QDistinct> distinctByFileName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QDistinct> distinctByImported() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imported');
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QDistinct> distinctByImportedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importedAt');
    });
  }

  QueryBuilder<ImportRecord, ImportRecord, QDistinct> distinctBySkipped() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'skipped');
    });
  }
}

extension ImportRecordQueryProperty
    on QueryBuilder<ImportRecord, ImportRecord, QQueryProperty> {
  QueryBuilder<ImportRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ImportRecord, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<ImportRecord, int, QQueryOperations> importedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imported');
    });
  }

  QueryBuilder<ImportRecord, DateTime, QQueryOperations> importedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importedAt');
    });
  }

  QueryBuilder<ImportRecord, int, QQueryOperations> skippedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'skipped');
    });
  }
}
