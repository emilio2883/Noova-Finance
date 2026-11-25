// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_rule.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRecurringRuleCollection on Isar {
  IsarCollection<RecurringRule> get recurringRules => this.collection();
}

const RecurringRuleSchema = CollectionSchema(
  name: r'RecurringRule',
  id: -4060329745646828675,
  properties: {
    r'activationDay': PropertySchema(
      id: 0,
      name: r'activationDay',
      type: IsarType.long,
    ),
    r'amountBps': PropertySchema(
      id: 1,
      name: r'amountBps',
      type: IsarType.long,
    ),
    r'categoryId': PropertySchema(
      id: 2,
      name: r'categoryId',
      type: IsarType.long,
    ),
    r'endDate': PropertySchema(
      id: 3,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'frequency': PropertySchema(
      id: 4,
      name: r'frequency',
      type: IsarType.string,
      enumMap: _RecurringRulefrequencyEnumValueMap,
    ),
    r'isActive': PropertySchema(
      id: 5,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'lastGenerated': PropertySchema(
      id: 6,
      name: r'lastGenerated',
      type: IsarType.dateTime,
    ),
    r'startDate': PropertySchema(
      id: 7,
      name: r'startDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _recurringRuleEstimateSize,
  serialize: _recurringRuleSerialize,
  deserialize: _recurringRuleDeserialize,
  deserializeProp: _recurringRuleDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _recurringRuleGetId,
  getLinks: _recurringRuleGetLinks,
  attach: _recurringRuleAttach,
  version: '3.1.0+1',
);

int _recurringRuleEstimateSize(
  RecurringRule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.frequency.name.length * 3;
  return bytesCount;
}

void _recurringRuleSerialize(
  RecurringRule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.activationDay);
  writer.writeLong(offsets[1], object.amountBps);
  writer.writeLong(offsets[2], object.categoryId);
  writer.writeDateTime(offsets[3], object.endDate);
  writer.writeString(offsets[4], object.frequency.name);
  writer.writeBool(offsets[5], object.isActive);
  writer.writeDateTime(offsets[6], object.lastGenerated);
  writer.writeDateTime(offsets[7], object.startDate);
}

RecurringRule _recurringRuleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RecurringRule(
    activationDay: reader.readLong(offsets[0]),
    amountBps: reader.readLong(offsets[1]),
    categoryId: reader.readLong(offsets[2]),
    endDate: reader.readDateTimeOrNull(offsets[3]),
    frequency: _RecurringRulefrequencyValueEnumMap[
            reader.readStringOrNull(offsets[4])] ??
        RecurringFrequency.quincenal,
    isActive: reader.readBoolOrNull(offsets[5]) ?? true,
    lastGenerated: reader.readDateTimeOrNull(offsets[6]),
    startDate: reader.readDateTime(offsets[7]),
  );
  object.id = id;
  return object;
}

P _recurringRuleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (_RecurringRulefrequencyValueEnumMap[
              reader.readStringOrNull(offset)] ??
          RecurringFrequency.quincenal) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RecurringRulefrequencyEnumValueMap = {
  r'quincenal': r'quincenal',
  r'monthly': r'monthly',
};
const _RecurringRulefrequencyValueEnumMap = {
  r'quincenal': RecurringFrequency.quincenal,
  r'monthly': RecurringFrequency.monthly,
};

Id _recurringRuleGetId(RecurringRule object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _recurringRuleGetLinks(RecurringRule object) {
  return [];
}

void _recurringRuleAttach(
    IsarCollection<dynamic> col, Id id, RecurringRule object) {
  object.id = id;
}

extension RecurringRuleQueryWhereSort
    on QueryBuilder<RecurringRule, RecurringRule, QWhere> {
  QueryBuilder<RecurringRule, RecurringRule, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RecurringRuleQueryWhere
    on QueryBuilder<RecurringRule, RecurringRule, QWhereClause> {
  QueryBuilder<RecurringRule, RecurringRule, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<RecurringRule, RecurringRule, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterWhereClause> idBetween(
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

extension RecurringRuleQueryFilter
    on QueryBuilder<RecurringRule, RecurringRule, QFilterCondition> {
  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      activationDayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activationDay',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      activationDayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activationDay',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      activationDayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activationDay',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      activationDayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activationDay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      amountBpsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amountBps',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      amountBpsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amountBps',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      amountBpsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amountBps',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      amountBpsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amountBps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      categoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      categoryIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      categoryIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryId',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      categoryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      endDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyEqualTo(
    RecurringFrequency value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyGreaterThan(
    RecurringFrequency value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyLessThan(
    RecurringFrequency value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyBetween(
    RecurringFrequency lower,
    RecurringFrequency upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'frequency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'frequency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'frequency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frequency',
        value: '',
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      frequencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'frequency',
        value: '',
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
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

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      lastGeneratedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastGenerated',
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      lastGeneratedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastGenerated',
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      lastGeneratedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastGenerated',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      lastGeneratedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastGenerated',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      lastGeneratedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastGenerated',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      lastGeneratedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastGenerated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      startDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterFilterCondition>
      startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RecurringRuleQueryObject
    on QueryBuilder<RecurringRule, RecurringRule, QFilterCondition> {}

extension RecurringRuleQueryLinks
    on QueryBuilder<RecurringRule, RecurringRule, QFilterCondition> {}

extension RecurringRuleQuerySortBy
    on QueryBuilder<RecurringRule, RecurringRule, QSortBy> {
  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      sortByActivationDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationDay', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      sortByActivationDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationDay', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> sortByAmountBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountBps', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      sortByAmountBpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountBps', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> sortByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      sortByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      sortByLastGenerated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastGenerated', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      sortByLastGeneratedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastGenerated', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension RecurringRuleQuerySortThenBy
    on QueryBuilder<RecurringRule, RecurringRule, QSortThenBy> {
  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      thenByActivationDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationDay', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      thenByActivationDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activationDay', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> thenByAmountBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountBps', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      thenByAmountBpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amountBps', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> thenByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      thenByCategoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryId', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      thenByLastGenerated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastGenerated', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      thenByLastGeneratedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastGenerated', Sort.desc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QAfterSortBy>
      thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension RecurringRuleQueryWhereDistinct
    on QueryBuilder<RecurringRule, RecurringRule, QDistinct> {
  QueryBuilder<RecurringRule, RecurringRule, QDistinct>
      distinctByActivationDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activationDay');
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QDistinct> distinctByAmountBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amountBps');
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QDistinct> distinctByCategoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryId');
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QDistinct> distinctByFrequency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QDistinct>
      distinctByLastGenerated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastGenerated');
    });
  }

  QueryBuilder<RecurringRule, RecurringRule, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }
}

extension RecurringRuleQueryProperty
    on QueryBuilder<RecurringRule, RecurringRule, QQueryProperty> {
  QueryBuilder<RecurringRule, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RecurringRule, int, QQueryOperations> activationDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activationDay');
    });
  }

  QueryBuilder<RecurringRule, int, QQueryOperations> amountBpsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amountBps');
    });
  }

  QueryBuilder<RecurringRule, int, QQueryOperations> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryId');
    });
  }

  QueryBuilder<RecurringRule, DateTime?, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<RecurringRule, RecurringFrequency, QQueryOperations>
      frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<RecurringRule, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<RecurringRule, DateTime?, QQueryOperations>
      lastGeneratedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastGenerated');
    });
  }

  QueryBuilder<RecurringRule, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }
}
