// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mail_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MailModel {
  int get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  bool get incoming => throw _privateConstructorUsedError;
  MailStatus get status => throw _privateConstructorUsedError;
  bool get isNew => throw _privateConstructorUsedError;
  ContentRegular get content => throw _privateConstructorUsedError;
  Active? get active => throw _privateConstructorUsedError;

  /// Create a copy of MailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MailModelCopyWith<MailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MailModelCopyWith<$Res> {
  factory $MailModelCopyWith(MailModel value, $Res Function(MailModel) then) =
      _$MailModelCopyWithImpl<$Res, MailModel>;
  @useResult
  $Res call(
      {int id,
      String username,
      int time,
      bool incoming,
      MailStatus status,
      bool isNew,
      ContentRegular content,
      Active? active});
}

/// @nodoc
class _$MailModelCopyWithImpl<$Res, $Val extends MailModel>
    implements $MailModelCopyWith<$Res> {
  _$MailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? time = null,
    Object? incoming = null,
    Object? status = null,
    Object? isNew = null,
    Object? content = null,
    Object? active = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      incoming: null == incoming
          ? _value.incoming
          : incoming // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MailStatus,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as ContentRegular,
      active: freezed == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as Active?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MailModelImplCopyWith<$Res>
    implements $MailModelCopyWith<$Res> {
  factory _$$MailModelImplCopyWith(
          _$MailModelImpl value, $Res Function(_$MailModelImpl) then) =
      __$$MailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String username,
      int time,
      bool incoming,
      MailStatus status,
      bool isNew,
      ContentRegular content,
      Active? active});
}

/// @nodoc
class __$$MailModelImplCopyWithImpl<$Res>
    extends _$MailModelCopyWithImpl<$Res, _$MailModelImpl>
    implements _$$MailModelImplCopyWith<$Res> {
  __$$MailModelImplCopyWithImpl(
      _$MailModelImpl _value, $Res Function(_$MailModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? time = null,
    Object? incoming = null,
    Object? status = null,
    Object? isNew = null,
    Object? content = null,
    Object? active = freezed,
  }) {
    return _then(_$MailModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      incoming: null == incoming
          ? _value.incoming
          : incoming // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MailStatus,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as ContentRegular,
      active: freezed == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as Active?,
    ));
  }
}

/// @nodoc

class _$MailModelImpl extends _MailModel {
  const _$MailModelImpl(
      {required this.id,
      required this.username,
      required this.time,
      required this.incoming,
      required this.status,
      required this.isNew,
      required this.content,
      this.active})
      : super._();

  @override
  final int id;
  @override
  final String username;
  @override
  final int time;
  @override
  final bool incoming;
  @override
  final MailStatus status;
  @override
  final bool isNew;
  @override
  final ContentRegular content;
  @override
  final Active? active;

  @override
  String toString() {
    return 'MailModel(id: $id, username: $username, time: $time, incoming: $incoming, status: $status, isNew: $isNew, content: $content, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MailModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.incoming, incoming) ||
                other.incoming == incoming) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isNew, isNew) || other.isNew == isNew) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.active, active) || other.active == active));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, username, time, incoming,
      status, isNew, content, active);

  /// Create a copy of MailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MailModelImplCopyWith<_$MailModelImpl> get copyWith =>
      __$$MailModelImplCopyWithImpl<_$MailModelImpl>(this, _$identity);
}

abstract class _MailModel extends MailModel {
  const factory _MailModel(
      {required final int id,
      required final String username,
      required final int time,
      required final bool incoming,
      required final MailStatus status,
      required final bool isNew,
      required final ContentRegular content,
      final Active? active}) = _$MailModelImpl;
  const _MailModel._() : super._();

  @override
  int get id;
  @override
  String get username;
  @override
  int get time;
  @override
  bool get incoming;
  @override
  MailStatus get status;
  @override
  bool get isNew;
  @override
  ContentRegular get content;
  @override
  Active? get active;

  /// Create a copy of MailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MailModelImplCopyWith<_$MailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
