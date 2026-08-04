// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'premium_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PremiumStatusModel {
  String get nickname => throw _privateConstructorUsedError;
  bool get isGod => throw _privateConstructorUsedError;
  DateTime? get validTo => throw _privateConstructorUsedError;
  DateTime get fetchedAt => throw _privateConstructorUsedError;

  /// Create a copy of PremiumStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PremiumStatusModelCopyWith<PremiumStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PremiumStatusModelCopyWith<$Res> {
  factory $PremiumStatusModelCopyWith(
          PremiumStatusModel value, $Res Function(PremiumStatusModel) then) =
      _$PremiumStatusModelCopyWithImpl<$Res, PremiumStatusModel>;
  @useResult
  $Res call(
      {String nickname, bool isGod, DateTime? validTo, DateTime fetchedAt});
}

/// @nodoc
class _$PremiumStatusModelCopyWithImpl<$Res, $Val extends PremiumStatusModel>
    implements $PremiumStatusModelCopyWith<$Res> {
  _$PremiumStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PremiumStatusModel
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
abstract class _$$PremiumStatusModelImplCopyWith<$Res>
    implements $PremiumStatusModelCopyWith<$Res> {
  factory _$$PremiumStatusModelImplCopyWith(_$PremiumStatusModelImpl value,
          $Res Function(_$PremiumStatusModelImpl) then) =
      __$$PremiumStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String nickname, bool isGod, DateTime? validTo, DateTime fetchedAt});
}

/// @nodoc
class __$$PremiumStatusModelImplCopyWithImpl<$Res>
    extends _$PremiumStatusModelCopyWithImpl<$Res, _$PremiumStatusModelImpl>
    implements _$$PremiumStatusModelImplCopyWith<$Res> {
  __$$PremiumStatusModelImplCopyWithImpl(_$PremiumStatusModelImpl _value,
      $Res Function(_$PremiumStatusModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PremiumStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nickname = null,
    Object? isGod = null,
    Object? validTo = freezed,
    Object? fetchedAt = null,
  }) {
    return _then(_$PremiumStatusModelImpl(
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

class _$PremiumStatusModelImpl extends _PremiumStatusModel {
  const _$PremiumStatusModelImpl(
      {required this.nickname,
      required this.isGod,
      this.validTo,
      required this.fetchedAt})
      : super._();

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
    return 'PremiumStatusModel(nickname: $nickname, isGod: $isGod, validTo: $validTo, fetchedAt: $fetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PremiumStatusModelImpl &&
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

  /// Create a copy of PremiumStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PremiumStatusModelImplCopyWith<_$PremiumStatusModelImpl> get copyWith =>
      __$$PremiumStatusModelImplCopyWithImpl<_$PremiumStatusModelImpl>(
          this, _$identity);
}

abstract class _PremiumStatusModel extends PremiumStatusModel {
  const factory _PremiumStatusModel(
      {required final String nickname,
      required final bool isGod,
      final DateTime? validTo,
      required final DateTime fetchedAt}) = _$PremiumStatusModelImpl;
  const _PremiumStatusModel._() : super._();

  @override
  String get nickname;
  @override
  bool get isGod;
  @override
  DateTime? get validTo;
  @override
  DateTime get fetchedAt;

  /// Create a copy of PremiumStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PremiumStatusModelImplCopyWith<_$PremiumStatusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
