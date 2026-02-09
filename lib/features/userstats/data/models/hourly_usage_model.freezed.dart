// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hourly_usage_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HourlyUsageModel {
  int get year => throw _privateConstructorUsedError;
  int get hour => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Create a copy of HourlyUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HourlyUsageModelCopyWith<HourlyUsageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HourlyUsageModelCopyWith<$Res> {
  factory $HourlyUsageModelCopyWith(
          HourlyUsageModel value, $Res Function(HourlyUsageModel) then) =
      _$HourlyUsageModelCopyWithImpl<$Res, HourlyUsageModel>;
  @useResult
  $Res call({int year, int hour, int count});
}

/// @nodoc
class _$HourlyUsageModelCopyWithImpl<$Res, $Val extends HourlyUsageModel>
    implements $HourlyUsageModelCopyWith<$Res> {
  _$HourlyUsageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HourlyUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? hour = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HourlyUsageModelImplCopyWith<$Res>
    implements $HourlyUsageModelCopyWith<$Res> {
  factory _$$HourlyUsageModelImplCopyWith(_$HourlyUsageModelImpl value,
          $Res Function(_$HourlyUsageModelImpl) then) =
      __$$HourlyUsageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int year, int hour, int count});
}

/// @nodoc
class __$$HourlyUsageModelImplCopyWithImpl<$Res>
    extends _$HourlyUsageModelCopyWithImpl<$Res, _$HourlyUsageModelImpl>
    implements _$$HourlyUsageModelImplCopyWith<$Res> {
  __$$HourlyUsageModelImplCopyWithImpl(_$HourlyUsageModelImpl _value,
      $Res Function(_$HourlyUsageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of HourlyUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? hour = null,
    Object? count = null,
  }) {
    return _then(_$HourlyUsageModelImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$HourlyUsageModelImpl extends _HourlyUsageModel {
  const _$HourlyUsageModelImpl(
      {required this.year, required this.hour, required this.count})
      : super._();

  @override
  final int year;
  @override
  final int hour;
  @override
  final int count;

  @override
  String toString() {
    return 'HourlyUsageModel(year: $year, hour: $hour, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HourlyUsageModelImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(runtimeType, year, hour, count);

  /// Create a copy of HourlyUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HourlyUsageModelImplCopyWith<_$HourlyUsageModelImpl> get copyWith =>
      __$$HourlyUsageModelImplCopyWithImpl<_$HourlyUsageModelImpl>(
          this, _$identity);
}

abstract class _HourlyUsageModel extends HourlyUsageModel {
  const factory _HourlyUsageModel(
      {required final int year,
      required final int hour,
      required final int count}) = _$HourlyUsageModelImpl;
  const _HourlyUsageModel._() : super._();

  @override
  int get year;
  @override
  int get hour;
  @override
  int get count;

  /// Create a copy of HourlyUsageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HourlyUsageModelImplCopyWith<_$HourlyUsageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
