import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/app_release/domain/entities/app_release.dart';

part 'app_release_model.freezed.dart';

/// Data model for [AppRelease]: maps the Supabase `app_releases` row and the
/// SharedPreferences cache JSON.
@freezed
class AppReleaseModel with _$AppReleaseModel {
  const AppReleaseModel._();

  const factory AppReleaseModel({
    required int build,
    required String version,
    required String postUrl,
  }) = _AppReleaseModel;

  factory AppReleaseModel.fromRow(Map<String, dynamic> row) {
    return AppReleaseModel(
      build: (row['build'] as num).toInt(),
      version: row['version']?.toString() ?? '',
      postUrl: row['post_url']?.toString() ?? '',
    );
  }

  factory AppReleaseModel.fromJson(Map<String, dynamic> json) {
    return AppReleaseModel(
      build: json['build'] as int,
      version: json['version'] as String,
      postUrl: json['postUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'build': build, 'version': version, 'postUrl': postUrl};

  AppRelease toEntity() => AppRelease(build: build, version: version, postUrl: postUrl);
}
