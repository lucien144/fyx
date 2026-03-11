// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_stat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GlobalStatModel {
  int get year => throw _privateConstructorUsedError;
  String get statType => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;

  /// Create a copy of GlobalStatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GlobalStatModelCopyWith<GlobalStatModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalStatModelCopyWith<$Res> {
  factory $GlobalStatModelCopyWith(
          GlobalStatModel value, $Res Function(GlobalStatModel) then) =
      _$GlobalStatModelCopyWithImpl<$Res, GlobalStatModel>;
  @useResult
  $Res call({int year, String statType, int number});
}

/// @nodoc
class _$GlobalStatModelCopyWithImpl<$Res, $Val extends GlobalStatModel>
    implements $GlobalStatModelCopyWith<$Res> {
  _$GlobalStatModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GlobalStatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? statType = null,
    Object? number = null,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      statType: null == statType
          ? _value.statType
          : statType // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GlobalStatModelImplCopyWith<$Res>
    implements $GlobalStatModelCopyWith<$Res> {
  factory _$$GlobalStatModelImplCopyWith(_$GlobalStatModelImpl value,
          $Res Function(_$GlobalStatModelImpl) then) =
      __$$GlobalStatModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int year, String statType, int number});
}

/// @nodoc
class __$$GlobalStatModelImplCopyWithImpl<$Res>
    extends _$GlobalStatModelCopyWithImpl<$Res, _$GlobalStatModelImpl>
    implements _$$GlobalStatModelImplCopyWith<$Res> {
  __$$GlobalStatModelImplCopyWithImpl(
      _$GlobalStatModelImpl _value, $Res Function(_$GlobalStatModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of GlobalStatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? statType = null,
    Object? number = null,
  }) {
    return _then(_$GlobalStatModelImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      statType: null == statType
          ? _value.statType
          : statType // ignore: cast_nullable_to_non_nullable
              as String,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$GlobalStatModelImpl extends _GlobalStatModel {
  const _$GlobalStatModelImpl(
      {required this.year, required this.statType, required this.number})
      : super._();

  @override
  final int year;
  @override
  final String statType;
  @override
  final int number;

  @override
  String toString() {
    return 'GlobalStatModel(year: $year, statType: $statType, number: $number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalStatModelImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.statType, statType) ||
                other.statType == statType) &&
            (identical(other.number, number) || other.number == number));
  }

  @override
  int get hashCode => Object.hash(runtimeType, year, statType, number);

  /// Create a copy of GlobalStatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalStatModelImplCopyWith<_$GlobalStatModelImpl> get copyWith =>
      __$$GlobalStatModelImplCopyWithImpl<_$GlobalStatModelImpl>(
          this, _$identity);
}

abstract class _GlobalStatModel extends GlobalStatModel {
  const factory _GlobalStatModel(
      {required final int year,
      required final String statType,
      required final int number}) = _$GlobalStatModelImpl;
  const _GlobalStatModel._() : super._();

  @override
  int get year;
  @override
  String get statType;
  @override
  int get number;

  /// Create a copy of GlobalStatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GlobalStatModelImplCopyWith<_$GlobalStatModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
