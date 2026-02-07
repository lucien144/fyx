// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_stat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GlobalStat {
  int get year => throw _privateConstructorUsedError;
  String get statType => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;

  /// Create a copy of GlobalStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GlobalStatCopyWith<GlobalStat> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalStatCopyWith<$Res> {
  factory $GlobalStatCopyWith(
          GlobalStat value, $Res Function(GlobalStat) then) =
      _$GlobalStatCopyWithImpl<$Res, GlobalStat>;
  @useResult
  $Res call({int year, String statType, int number});
}

/// @nodoc
class _$GlobalStatCopyWithImpl<$Res, $Val extends GlobalStat>
    implements $GlobalStatCopyWith<$Res> {
  _$GlobalStatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GlobalStat
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
abstract class _$$GlobalStatImplCopyWith<$Res>
    implements $GlobalStatCopyWith<$Res> {
  factory _$$GlobalStatImplCopyWith(
          _$GlobalStatImpl value, $Res Function(_$GlobalStatImpl) then) =
      __$$GlobalStatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int year, String statType, int number});
}

/// @nodoc
class __$$GlobalStatImplCopyWithImpl<$Res>
    extends _$GlobalStatCopyWithImpl<$Res, _$GlobalStatImpl>
    implements _$$GlobalStatImplCopyWith<$Res> {
  __$$GlobalStatImplCopyWithImpl(
      _$GlobalStatImpl _value, $Res Function(_$GlobalStatImpl) _then)
      : super(_value, _then);

  /// Create a copy of GlobalStat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? statType = null,
    Object? number = null,
  }) {
    return _then(_$GlobalStatImpl(
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

class _$GlobalStatImpl implements _GlobalStat {
  const _$GlobalStatImpl(
      {required this.year, required this.statType, required this.number});

  @override
  final int year;
  @override
  final String statType;
  @override
  final int number;

  @override
  String toString() {
    return 'GlobalStat(year: $year, statType: $statType, number: $number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalStatImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.statType, statType) ||
                other.statType == statType) &&
            (identical(other.number, number) || other.number == number));
  }

  @override
  int get hashCode => Object.hash(runtimeType, year, statType, number);

  /// Create a copy of GlobalStat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalStatImplCopyWith<_$GlobalStatImpl> get copyWith =>
      __$$GlobalStatImplCopyWithImpl<_$GlobalStatImpl>(this, _$identity);
}

abstract class _GlobalStat implements GlobalStat {
  const factory _GlobalStat(
      {required final int year,
      required final String statType,
      required final int number}) = _$GlobalStatImpl;

  @override
  int get year;
  @override
  String get statType;
  @override
  int get number;

  /// Create a copy of GlobalStat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GlobalStatImplCopyWith<_$GlobalStatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
