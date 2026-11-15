// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'year_in_review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$YearInReview {
  int get year => throw _privateConstructorUsedError;

  /// First active day, unless the data covers the year from January 1st.
  DateTime? get countedFrom => throw _privateConstructorUsedError;
  int get activeDays => throw _privateConstructorUsedError;
  List<YearInReviewSlide> get slides => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $YearInReviewCopyWith<YearInReview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YearInReviewCopyWith<$Res> {
  factory $YearInReviewCopyWith(
          YearInReview value, $Res Function(YearInReview) then) =
      _$YearInReviewCopyWithImpl<$Res, YearInReview>;
  @useResult
  $Res call(
      {int year,
      DateTime? countedFrom,
      int activeDays,
      List<YearInReviewSlide> slides});
}

/// @nodoc
class _$YearInReviewCopyWithImpl<$Res, $Val extends YearInReview>
    implements $YearInReviewCopyWith<$Res> {
  _$YearInReviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? countedFrom = freezed,
    Object? activeDays = null,
    Object? slides = null,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      countedFrom: freezed == countedFrom
          ? _value.countedFrom
          : countedFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeDays: null == activeDays
          ? _value.activeDays
          : activeDays // ignore: cast_nullable_to_non_nullable
              as int,
      slides: null == slides
          ? _value.slides
          : slides // ignore: cast_nullable_to_non_nullable
              as List<YearInReviewSlide>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$YearInReviewImplCopyWith<$Res>
    implements $YearInReviewCopyWith<$Res> {
  factory _$$YearInReviewImplCopyWith(
          _$YearInReviewImpl value, $Res Function(_$YearInReviewImpl) then) =
      __$$YearInReviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int year,
      DateTime? countedFrom,
      int activeDays,
      List<YearInReviewSlide> slides});
}

/// @nodoc
class __$$YearInReviewImplCopyWithImpl<$Res>
    extends _$YearInReviewCopyWithImpl<$Res, _$YearInReviewImpl>
    implements _$$YearInReviewImplCopyWith<$Res> {
  __$$YearInReviewImplCopyWithImpl(
      _$YearInReviewImpl _value, $Res Function(_$YearInReviewImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? countedFrom = freezed,
    Object? activeDays = null,
    Object? slides = null,
  }) {
    return _then(_$YearInReviewImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      countedFrom: freezed == countedFrom
          ? _value.countedFrom
          : countedFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeDays: null == activeDays
          ? _value.activeDays
          : activeDays // ignore: cast_nullable_to_non_nullable
              as int,
      slides: null == slides
          ? _value._slides
          : slides // ignore: cast_nullable_to_non_nullable
              as List<YearInReviewSlide>,
    ));
  }
}

/// @nodoc

class _$YearInReviewImpl implements _YearInReview {
  const _$YearInReviewImpl(
      {required this.year,
      this.countedFrom,
      required this.activeDays,
      required final List<YearInReviewSlide> slides})
      : _slides = slides;

  @override
  final int year;

  /// First active day, unless the data covers the year from January 1st.
  @override
  final DateTime? countedFrom;
  @override
  final int activeDays;
  final List<YearInReviewSlide> _slides;
  @override
  List<YearInReviewSlide> get slides {
    if (_slides is EqualUnmodifiableListView) return _slides;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slides);
  }

  @override
  String toString() {
    return 'YearInReview(year: $year, countedFrom: $countedFrom, activeDays: $activeDays, slides: $slides)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YearInReviewImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.countedFrom, countedFrom) ||
                other.countedFrom == countedFrom) &&
            (identical(other.activeDays, activeDays) ||
                other.activeDays == activeDays) &&
            const DeepCollectionEquality().equals(other._slides, _slides));
  }

  @override
  int get hashCode => Object.hash(runtimeType, year, countedFrom, activeDays,
      const DeepCollectionEquality().hash(_slides));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$YearInReviewImplCopyWith<_$YearInReviewImpl> get copyWith =>
      __$$YearInReviewImplCopyWithImpl<_$YearInReviewImpl>(this, _$identity);
}

abstract class _YearInReview implements YearInReview {
  const factory _YearInReview(
      {required final int year,
      final DateTime? countedFrom,
      required final int activeDays,
      required final List<YearInReviewSlide> slides}) = _$YearInReviewImpl;

  @override
  int get year;
  @override

  /// First active day, unless the data covers the year from January 1st.
  DateTime? get countedFrom;
  @override
  int get activeDays;
  @override
  List<YearInReviewSlide> get slides;
  @override
  @JsonKey(ignore: true)
  _$$YearInReviewImplCopyWith<_$YearInReviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
