import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';

part 'premium_status_model.freezed.dart';

/// Data model for [PremiumStatus]: maps the Supabase `subscribers` row and
/// the SharedPreferences cache JSON.
@freezed
class PremiumStatusModel with _$PremiumStatusModel {
  const PremiumStatusModel._();

  const factory PremiumStatusModel({
    required String nickname,
    required bool isGod,
    DateTime? validTo,
    required DateTime fetchedAt,
  }) = _PremiumStatusModel;

  /// Maps a `subscribers` row; a null [row] means the user is not a
  /// subscriber and yields a negative status.
  factory PremiumStatusModel.fromRow(Map<String, dynamic>? row, {required String nickname, required DateTime fetchedAt}) {
    return PremiumStatusModel(
      nickname: nickname,
      isGod: row?['is_god'] == true,
      validTo: row?['valid_to'] != null ? DateTime.tryParse(row!['valid_to'].toString()) : null,
      fetchedAt: fetchedAt,
    );
  }

  factory PremiumStatusModel.fromJson(Map<String, dynamic> json) {
    return PremiumStatusModel(
      nickname: json['nickname'] as String,
      isGod: json['isGod'] == true,
      validTo: json['validTo'] != null ? DateTime.parse(json['validTo'] as String) : null,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'isGod': isGod,
        'validTo': validTo?.toIso8601String(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  PremiumStatus toEntity() => PremiumStatus(nickname: nickname, isGod: isGod, validTo: validTo, fetchedAt: fetchedAt);
}
