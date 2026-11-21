// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppRelease {
  int get build => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;

  /// Club post with the changelog, e.g. `/discussion/24237/id/123456`.
  String get postUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppReleaseCopyWith<AppRelease> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppReleaseCopyWith<$Res> {
  factory $AppReleaseCopyWith(AppRelease value, $Res Function(AppRelease) then) = _$AppReleaseCopyWithImpl<$Res, AppRelease>;
  @useResult
  $Res call({int build, String version, String postUrl});
}

/// @nodoc
class _$AppReleaseCopyWithImpl<$Res, $Val extends AppRelease> implements $AppReleaseCopyWith<$Res> {
  _$AppReleaseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? build = null,
    Object? version = null,
    Object? postUrl = null,
  }) {
    return _then(_value.copyWith(
      build: null == build
          ? _value.build
          : build // ignore: cast_nullable_to_non_nullable
              as int,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      postUrl: null == postUrl
          ? _value.postUrl
          : postUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppReleaseImplCopyWith<$Res> implements $AppReleaseCopyWith<$Res> {
  factory _$$AppReleaseImplCopyWith(_$AppReleaseImpl value, $Res Function(_$AppReleaseImpl) then) = __$$AppReleaseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int build, String version, String postUrl});
}

/// @nodoc
class __$$AppReleaseImplCopyWithImpl<$Res> extends _$AppReleaseCopyWithImpl<$Res, _$AppReleaseImpl> implements _$$AppReleaseImplCopyWith<$Res> {
  __$$AppReleaseImplCopyWithImpl(_$AppReleaseImpl _value, $Res Function(_$AppReleaseImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? build = null,
    Object? version = null,
    Object? postUrl = null,
  }) {
    return _then(_$AppReleaseImpl(
      build: null == build
          ? _value.build
          : build // ignore: cast_nullable_to_non_nullable
              as int,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      postUrl: null == postUrl
          ? _value.postUrl
          : postUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AppReleaseImpl extends _AppRelease {
  const _$AppReleaseImpl({required this.build, required this.version, required this.postUrl}) : super._();

  @override
  final int build;
  @override
  final String version;

  /// Club post with the changelog, e.g. `/discussion/24237/id/123456`.
  @override
  final String postUrl;

  @override
  String toString() {
    return 'AppRelease(build: $build, version: $version, postUrl: $postUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppReleaseImpl &&
            (identical(other.build, build) || other.build == build) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.postUrl, postUrl) || other.postUrl == postUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, build, version, postUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppReleaseImplCopyWith<_$AppReleaseImpl> get copyWith => __$$AppReleaseImplCopyWithImpl<_$AppReleaseImpl>(this, _$identity);
}

abstract class _AppRelease extends AppRelease {
  const factory _AppRelease({required final int build, required final String version, required final String postUrl}) = _$AppReleaseImpl;
  const _AppRelease._() : super._();

  @override
  int get build;
  @override
  String get version;
  @override

  /// Club post with the changelog, e.g. `/discussion/24237/id/123456`.
  String get postUrl;
  @override
  @JsonKey(ignore: true)
  _$$AppReleaseImplCopyWith<_$AppReleaseImpl> get copyWith => throw _privateConstructorUsedError;
}
