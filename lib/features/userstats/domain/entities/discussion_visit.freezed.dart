// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discussion_visit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DiscussionVisit {
  int get year => throw _privateConstructorUsedError;
  int get discussionId => throw _privateConstructorUsedError;
  String get discussionName => throw _privateConstructorUsedError;
  int get visits => throw _privateConstructorUsedError;

  /// Create a copy of DiscussionVisit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscussionVisitCopyWith<DiscussionVisit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscussionVisitCopyWith<$Res> {
  factory $DiscussionVisitCopyWith(
          DiscussionVisit value, $Res Function(DiscussionVisit) then) =
      _$DiscussionVisitCopyWithImpl<$Res, DiscussionVisit>;
  @useResult
  $Res call({int year, int discussionId, String discussionName, int visits});
}

/// @nodoc
class _$DiscussionVisitCopyWithImpl<$Res, $Val extends DiscussionVisit>
    implements $DiscussionVisitCopyWith<$Res> {
  _$DiscussionVisitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscussionVisit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? discussionId = null,
    Object? discussionName = null,
    Object? visits = null,
  }) {
    return _then(_value.copyWith(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as int,
      discussionName: null == discussionName
          ? _value.discussionName
          : discussionName // ignore: cast_nullable_to_non_nullable
              as String,
      visits: null == visits
          ? _value.visits
          : visits // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiscussionVisitImplCopyWith<$Res>
    implements $DiscussionVisitCopyWith<$Res> {
  factory _$$DiscussionVisitImplCopyWith(_$DiscussionVisitImpl value,
          $Res Function(_$DiscussionVisitImpl) then) =
      __$$DiscussionVisitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int year, int discussionId, String discussionName, int visits});
}

/// @nodoc
class __$$DiscussionVisitImplCopyWithImpl<$Res>
    extends _$DiscussionVisitCopyWithImpl<$Res, _$DiscussionVisitImpl>
    implements _$$DiscussionVisitImplCopyWith<$Res> {
  __$$DiscussionVisitImplCopyWithImpl(
      _$DiscussionVisitImpl _value, $Res Function(_$DiscussionVisitImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiscussionVisit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? year = null,
    Object? discussionId = null,
    Object? discussionName = null,
    Object? visits = null,
  }) {
    return _then(_$DiscussionVisitImpl(
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      discussionId: null == discussionId
          ? _value.discussionId
          : discussionId // ignore: cast_nullable_to_non_nullable
              as int,
      discussionName: null == discussionName
          ? _value.discussionName
          : discussionName // ignore: cast_nullable_to_non_nullable
              as String,
      visits: null == visits
          ? _value.visits
          : visits // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DiscussionVisitImpl implements _DiscussionVisit {
  const _$DiscussionVisitImpl(
      {required this.year,
      required this.discussionId,
      required this.discussionName,
      required this.visits});

  @override
  final int year;
  @override
  final int discussionId;
  @override
  final String discussionName;
  @override
  final int visits;

  @override
  String toString() {
    return 'DiscussionVisit(year: $year, discussionId: $discussionId, discussionName: $discussionName, visits: $visits)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscussionVisitImpl &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.discussionId, discussionId) ||
                other.discussionId == discussionId) &&
            (identical(other.discussionName, discussionName) ||
                other.discussionName == discussionName) &&
            (identical(other.visits, visits) || other.visits == visits));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, year, discussionId, discussionName, visits);

  /// Create a copy of DiscussionVisit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscussionVisitImplCopyWith<_$DiscussionVisitImpl> get copyWith =>
      __$$DiscussionVisitImplCopyWithImpl<_$DiscussionVisitImpl>(
          this, _$identity);
}

abstract class _DiscussionVisit implements DiscussionVisit {
  const factory _DiscussionVisit(
      {required final int year,
      required final int discussionId,
      required final String discussionName,
      required final int visits}) = _$DiscussionVisitImpl;

  @override
  int get year;
  @override
  int get discussionId;
  @override
  String get discussionName;
  @override
  int get visits;

  /// Create a copy of DiscussionVisit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscussionVisitImplCopyWith<_$DiscussionVisitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
