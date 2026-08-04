import 'dart:convert';

import 'package:fyx/features/premium/data/models/premium_status_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the single cached [PremiumStatusModel] as JSON in
/// SharedPreferences. Corrupt content reads as "no cache", never a crash.
class PremiumLocalDatasource {
  static const _key = 'premium_status';

  Future<PremiumStatusModel?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return PremiumStatusModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_key);
      return null;
    }
  }

  Future<void> write(PremiumStatusModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(model.toJson()));
  }

  Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
