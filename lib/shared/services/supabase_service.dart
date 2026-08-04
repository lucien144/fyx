import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lazily initializes the shared Supabase client on first use.
///
/// Keeping the initialization here (instead of app startup) means the app
/// never pays for — or fails on — Supabase unless a feature actually needs it.
/// A failed initialization is forgotten so the next caller retries.
class SupabaseService {
  Future<SupabaseClient>? _client;

  Future<SupabaseClient> get client async {
    final pending = _client ??= _init();
    try {
      return await pending;
    } catch (_) {
      if (identical(_client, pending)) _client = null;
      rethrow;
    }
  }

  Future<SupabaseClient> _init() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
    return Supabase.instance.client;
  }
}
