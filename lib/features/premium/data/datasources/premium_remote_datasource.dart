import 'package:fyx/shared/services/supabase_service.dart';

/// Fetches the raw subscriber row. No server-side `valid_to`/`is_god` filter:
/// evaluation happens locally so `valid_to` can be cached (ADR 0002).
class PremiumRemoteDatasource {
  final SupabaseService _supabase;

  PremiumRemoteDatasource(this._supabase);

  /// Returns the row for [nickname] (lowercase), or null when not a subscriber.
  Future<Map<String, dynamic>?> fetchSubscriber(String nickname) async {
    final client = await _supabase.client;
    return client.from('subscribers').select('nickname, valid_to, is_god').eq('nickname', nickname).maybeSingle();
  }
}
