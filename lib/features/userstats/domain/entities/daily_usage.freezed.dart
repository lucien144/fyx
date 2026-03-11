// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DailyUsage {
  int get year => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Create a copy of DailyUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyUsageCopyWith<DailyUsage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyUsageCopyWith<$Res> {
  factory $DailyUsageCopyWith(
          DailyUsage value, $Res Function(DailyUsage) then) =
      _$DailyUsageCopyWithImpl<$Res, DailyUsage>;
  @useResult
  $Res call({int year, DateTime date});
}

/// @nodoc
class _$DailyUsageCopyWithImpl<$Res, $Val extends DailyUsage>
    implements $DailyUsageCopyWith<$Res> {
  _$DailyUsageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyUsageImplCopyWith<$Res>
    implements $DailyUsageCopyWith<$Res> {
  factory _$$DailyUsageImplCopyWith(
          _$DailyUsageImpl value, $Res Function(_$DailyUsageImpl) then) =
      __$$DailyUsageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int year, DateTime date});
}

/// @nodoc
class __$$DailyUsageImplCopyWithImpl<$Res>
    extends _$DailyUsageCopyWithImpl<$Res, _$DailyUsageImpl>
    implements _$$DailyUsageImplCopyWith<$Res> {
  __$$DailyUsageImplCopyWithImpl(
      _$DailyUsageImpl _value, $Res Function(_$DailyUsageImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyUsage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? date = null,
  }) {
    return _then(_$DailyUsageImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$DailyUsageImpl implements _DailyUsage {
  const _$DailyUsageImpl({required this.year, required this.date});

  @override
  final int year;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'DailyUsage(year: $year, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyUsageImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.date, date) || other.date == date));
  }

  @override
  int get hashCode => Object.hash(runtimeType, year, date);

  /// Create a copy of DailyUsage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyUsageImplCopyWith<_$DailyUsageImpl> get copyWith =>
      __$$DailyUsageImplCopyWithImpl<_$DailyUsageImpl>(this, _$identity);
}

abstract class _DailyUsage implements DailyUsage {
  const factory _DailyUsage(
      {required final int year,
      required final DateTime date}) = _$DailyUsageImpl;

  @override
  int get year;
  @override
  DateTime get date;

  /// Create a copy of DailyUsage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyUsageImplCopyWith<_$DailyUsageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
