// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Mail {
  int get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  bool get incoming => throw _privateConstructorUsedError;
  MailStatus get status => throw _privateConstructorUsedError;
  bool get isNew => throw _privateConstructorUsedError;
  ContentRegular get content => throw _privateConstructorUsedError;
  Active? get active => throw _privateConstructorUsedError;

  /// Create a copy of Mail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MailCopyWith<Mail> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MailCopyWith<$Res> {
  factory $MailCopyWith(Mail value, $Res Function(Mail) then) =
      _$MailCopyWithImpl<$Res, Mail>;
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
class _$MailCopyWithImpl<$Res, $Val extends Mail>
    implements $MailCopyWith<$Res> {
  _$MailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Mail
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
abstract class _$$MailImplCopyWith<$Res> implements $MailCopyWith<$Res> {
  factory _$$MailImplCopyWith(
          _$MailImpl value, $Res Function(_$MailImpl) then) =
      __$$MailImplCopyWithImpl<$Res>;
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
class __$$MailImplCopyWithImpl<$Res>
    extends _$MailCopyWithImpl<$Res, _$MailImpl>
    implements _$$MailImplCopyWith<$Res> {
  __$$MailImplCopyWithImpl(_$MailImpl _value, $Res Function(_$MailImpl) _then)
      : super(_value, _then);

  /// Create a copy of Mail
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
    return _then(_$MailImpl(
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

class _$MailImpl extends _Mail {
  const _$MailImpl(
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
    return 'Mail(id: $id, username: $username, time: $time, incoming: $incoming, status: $status, isNew: $isNew, content: $content, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MailImpl &&
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

  /// Create a copy of Mail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MailImplCopyWith<_$MailImpl> get copyWith =>
      __$$MailImplCopyWithImpl<_$MailImpl>(this, _$identity);
}

abstract class _Mail extends Mail {
  const factory _Mail(
      {required final int id,
      required final String username,
      required final int time,
      required final bool incoming,
      required final MailStatus status,
      required final bool isNew,
      required final ContentRegular content,
      final Active? active}) = _$MailImpl;
  const _Mail._() : super._();

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

  /// Create a copy of Mail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MailImplCopyWith<_$MailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
