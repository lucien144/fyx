// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'premium_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PremiumStatus {
  /// Whose status this is (lowercase).
  String get nickname => throw _privateConstructorUsedError;
  bool get isGod => throw _privateConstructorUsedError;
  DateTime? get validTo => throw _privateConstructorUsedError;
  DateTime get fetchedAt => throw _privateConstructorUsedError;

  /// Create a copy of PremiumStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PremiumStatusCopyWith<PremiumStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumStatusCopyWith<$Res> {
  factory $PremiumStatusCopyWith(
          PremiumStatus value, $Res Function(PremiumStatus) then) =
      _$PremiumStatusCopyWithImpl<$Res, PremiumStatus>;
  @useResult
  $Res call(
      {String nickname, bool isGod, DateTime? validTo, DateTime fetchedAt});
}

/// @nodoc
class _$PremiumStatusCopyWithImpl<$Res, $Val extends PremiumStatus>
    implements $PremiumStatusCopyWith<$Res> {
  _$PremiumStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PremiumStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = null,
    Object? isGod = null,
    Object? validTo = freezed,
    Object? fetchedAt = null,
  }) {
    return _then(_value.copyWith(
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      isGod: null == isGod
          ? _value.isGod
          : isGod // ignore: cast_nullable_to_non_nullable
              as bool,
      validTo: freezed == validTo
          ? _value.validTo
          : validTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PremiumStatusImplCopyWith<$Res>
    implements $PremiumStatusCopyWith<$Res> {
  factory _$$PremiumStatusImplCopyWith(
          _$PremiumStatusImpl value, $Res Function(_$PremiumStatusImpl) then) =
      __$$PremiumStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String nickname, bool isGod, DateTime? validTo, DateTime fetchedAt});
}

/// @nodoc
class __$$PremiumStatusImplCopyWithImpl<$Res>
    extends _$PremiumStatusCopyWithImpl<$Res, _$PremiumStatusImpl>
    implements _$$PremiumStatusImplCopyWith<$Res> {
  __$$PremiumStatusImplCopyWithImpl(
      _$PremiumStatusImpl _value, $Res Function(_$PremiumStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of PremiumStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = null,
    Object? isGod = null,
    Object? validTo = freezed,
    Object? fetchedAt = null,
  }) {
    return _then(_$PremiumStatusImpl(
      nickname: null == nickname
          ? _value.nickname
          : nickname // ignore: cast_nullable_to_non_nullable
              as String,
      isGod: null == isGod
          ? _value.isGod
          : isGod // ignore: cast_nullable_to_non_nullable
              as bool,
      validTo: freezed == validTo
          ? _value.validTo
          : validTo // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      fetchedAt: null == fetchedAt
          ? _value.fetchedAt
          : fetchedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$PremiumStatusImpl extends _PremiumStatus {
  const _$PremiumStatusImpl(
      {required this.nickname,
      required this.isGod,
      this.validTo,
      required this.fetchedAt})
      : super._();

  /// Whose status this is (lowercase).
  @override
  final String nickname;
  @override
  final bool isGod;
  @override
  final DateTime? validTo;
  @override
  final DateTime fetchedAt;

  @override
  String toString() {
    return 'PremiumStatus(nickname: $nickname, isGod: $isGod, validTo: $validTo, fetchedAt: $fetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumStatusImpl &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.isGod, isGod) || other.isGod == isGod) &&
            (identical(other.validTo, validTo) || other.validTo == validTo) &&
            (identical(other.fetchedAt, fetchedAt) ||
                other.fetchedAt == fetchedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, nickname, isGod, validTo, fetchedAt);

  /// Create a copy of PremiumStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumStatusImplCopyWith<_$PremiumStatusImpl> get copyWith =>
      __$$PremiumStatusImplCopyWithImpl<_$PremiumStatusImpl>(this, _$identity);
}

abstract class _PremiumStatus extends PremiumStatus {
  const factory _PremiumStatus(
      {required final String nickname,
      required final bool isGod,
      final DateTime? validTo,
      required final DateTime fetchedAt}) = _$PremiumStatusImpl;
  const _PremiumStatus._() : super._();

  /// Whose status this is (lowercase).
  @override
  String get nickname;
  @override
  bool get isGod;
  @override
  DateTime? get validTo;
  @override
  DateTime get fetchedAt;

  /// Create a copy of PremiumStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PremiumStatusImplCopyWith<_$PremiumStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
