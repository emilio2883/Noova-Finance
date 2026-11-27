// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSavingsGoalCollection on Isar {
  IsarCollection<SavingsGoal> get savingsGoals => this.collection();
}

const SavingsGoalSchema = CollectionSchema(
  name: r'SavingsGoal',
  id: 2336982407974704875,
  properties: {
    r'colorArgb': PropertySchema(
      id: 0,
      name: r'colorArgb',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'deadline': PropertySchema(
      id: 2,
      name: r'deadline',
      type: IsarType.dateTime,
    ),
    r'iconName': PropertySchema(
      id: 3,
      name: r'iconName',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 4,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isRecurring': PropertySchema(
      id: 5,
      name: r'isRecurring',
      type: IsarType.bool,
    ),
    r'lastAutoMonth': PropertySchema(
      id: 6,
      name: r'lastAutoMonth',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 7,
      name: r'name',
      type: IsarType.string,
    ),
    r'periodMonths': PropertySchema(
      id: 8,
      name: r'periodMonths',
      type: IsarType.long,
    ),
    r'savedBps': PropertySchema(
      id: 9,
      name: r'savedBps',
      type: IsarType.long,
    ),
    r'targetBps': PropertySchema(
      id: 10,
      name: r'targetBps',
      type: IsarType.long,
    )
  },
  estimateSize: _savingsGoalEstimateSize,
  serialize: _savingsGoalSerialize,
  deserialize: _savingsGoalDeserialize,
  deserializeProp: _savingsGoalDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _savingsGoalGetId,
  getLinks: _savingsGoalGetLinks,
  attach: _savingsGoalAttach,
  version: '3.1.0+1',
);

int _savingsGoalEstimateSize(
  SavingsGoal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.iconName.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _savingsGoalSerialize(
  SavingsGoal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorArgb);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDateTime(offsets[2], object.deadline);
  writer.writeString(offsets[3], object.iconName);
  writer.writeBool(offsets[4], object.isActive);
  writer.writeBool(offsets[5], object.isRecurring);
  writer.writeLong(offsets[6], object.lastAutoMonth);
  writer.writeString(offsets[7], object.name);
  writer.writeLong(offsets[8], object.periodMonths);
  writer.writeLong(offsets[9], object.savedBps);
  writer.writeLong(offsets[10], object.targetBps);
}

SavingsGoal _savingsGoalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SavingsGoal(
    colorArgb: reader.readLongOrNull(offsets[0]) ?? 0xFF22A06B,
    createdAt: reader.readDateTimeOrNull(offsets[1]),
    deadline: reader.readDateTimeOrNull(offsets[2]),
    iconName: reader.readStringOrNull(offsets[3]) ?? 'savings',
    isActive: reader.readBoolOrNull(offsets[4]) ?? true,
    isRecurring: reader.readBoolOrNull(offsets[5]) ?? false,
    lastAutoMonth: reader.readLongOrNull(offsets[6]) ?? 0,
    name: reader.readString(offsets[7]),
    periodMonths: reader.readLongOrNull(offsets[8]) ?? 0,
    savedBps: reader.readLongOrNull(offsets[9]) ?? 0,
    targetBps: reader.readLong(offsets[10]),
  );
  object.id = id;
  return object;
}

P _savingsGoalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0xFF22A06B) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset) ?? 'savings') as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 9:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _savingsGoalGetId(SavingsGoal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _savingsGoalGetLinks(SavingsGoal object) {
  return [];
}

void _savingsGoalAttach(
    IsarCollection<dynamic> col, Id id, SavingsGoal object) {
  object.id = id;
}

extension SavingsGoalQueryWhereSort
    on QueryBuilder<SavingsGoal, SavingsGoal, QWhere> {
  QueryBuilder<SavingsGoal, SavingsGoal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SavingsGoalQueryWhere
    on QueryBuilder<SavingsGoal, SavingsGoal, QWhereClause> {
  QueryBuilder<SavingsGoal, SavingsGoal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterWhereClause> idBetween(
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

extension SavingsGoalQueryFilter
    on QueryBuilder<SavingsGoal, SavingsGoal, QFilterCondition> {
  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      colorArgbEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      colorArgbGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      colorArgbLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorArgb',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      colorArgbBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorArgb',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      deadlineIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deadline',
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      deadlineIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deadline',
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> deadlineEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      deadlineGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      deadlineLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> deadlineBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deadline',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> iconNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      iconNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      iconNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> iconNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      iconNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      iconNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      iconNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> iconNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      iconNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconName',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      iconNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconName',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      isRecurringEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRecurring',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      lastAutoMonthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastAutoMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      lastAutoMonthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastAutoMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      lastAutoMonthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastAutoMonth',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      lastAutoMonthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastAutoMonth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> nameEqualTo(
    String value, {
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> nameGreaterThan(
    String value, {
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> nameLessThan(
    String value, {
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      periodMonthsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'periodMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      periodMonthsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'periodMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      periodMonthsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'periodMonths',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      periodMonthsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'periodMonths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> savedBpsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savedBps',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      savedBpsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savedBps',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      savedBpsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savedBps',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> savedBpsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savedBps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      targetBpsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetBps',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      targetBpsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetBps',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      targetBpsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetBps',
        value: value,
      ));
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      targetBpsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetBps',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SavingsGoalQueryObject
    on QueryBuilder<SavingsGoal, SavingsGoal, QFilterCondition> {}

extension SavingsGoalQueryLinks
    on QueryBuilder<SavingsGoal, SavingsGoal, QFilterCondition> {}

extension SavingsGoalQuerySortBy
    on QueryBuilder<SavingsGoal, SavingsGoal, QSortBy> {
  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByColorArgb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByColorArgbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByIconName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconName', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByIconNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconName', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByIsRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurring', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByIsRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurring', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByLastAutoMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoMonth', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy>
      sortByLastAutoMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoMonth', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByPeriodMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodMonths', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy>
      sortByPeriodMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodMonths', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortBySavedBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedBps', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortBySavedBpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedBps', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByTargetBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetBps', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByTargetBpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetBps', Sort.desc);
    });
  }
}

extension SavingsGoalQuerySortThenBy
    on QueryBuilder<SavingsGoal, SavingsGoal, QSortThenBy> {
  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByColorArgb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByColorArgbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorArgb', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByIconName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconName', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByIconNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconName', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByIsRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurring', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByIsRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRecurring', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByLastAutoMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoMonth', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy>
      thenByLastAutoMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAutoMonth', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByPeriodMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodMonths', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy>
      thenByPeriodMonthsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodMonths', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenBySavedBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedBps', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenBySavedBpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedBps', Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByTargetBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetBps', Sort.asc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByTargetBpsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetBps', Sort.desc);
    });
  }
}

extension SavingsGoalQueryWhereDistinct
    on QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> {
  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByColorArgb() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorArgb');
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deadline');
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByIconName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByIsRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRecurring');
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByLastAutoMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAutoMonth');
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByPeriodMonths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodMonths');
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctBySavedBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedBps');
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> distinctByTargetBps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetBps');
    });
  }
}

extension SavingsGoalQueryProperty
    on QueryBuilder<SavingsGoal, SavingsGoal, QQueryProperty> {
  QueryBuilder<SavingsGoal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SavingsGoal, int, QQueryOperations> colorArgbProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorArgb');
    });
  }

  QueryBuilder<SavingsGoal, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SavingsGoal, DateTime?, QQueryOperations> deadlineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deadline');
    });
  }

  QueryBuilder<SavingsGoal, String, QQueryOperations> iconNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconName');
    });
  }

  QueryBuilder<SavingsGoal, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<SavingsGoal, bool, QQueryOperations> isRecurringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRecurring');
    });
  }

  QueryBuilder<SavingsGoal, int, QQueryOperations> lastAutoMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAutoMonth');
    });
  }

  QueryBuilder<SavingsGoal, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SavingsGoal, int, QQueryOperations> periodMonthsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodMonths');
    });
  }

  QueryBuilder<SavingsGoal, int, QQueryOperations> savedBpsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedBps');
    });
  }

  QueryBuilder<SavingsGoal, int, QQueryOperations> targetBpsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetBps');
    });
  }
}
