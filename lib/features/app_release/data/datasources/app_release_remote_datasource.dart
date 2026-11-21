import 'package:fyx/shared/services/supabase_service.dart';

class AppReleaseRemoteDatasource {
  final SupabaseService _supabase;

  AppReleaseRemoteDatasource(this._supabase);

  /// The row with the highest build for [platform] (`ios` / `android`), or
  /// null when nothing has been published yet.
  Future<Map<String, dynamic>?> fetchLatest(String platform) async {
    final client = await _supabase.client;
    return client
        .from('app_releases')
        .select('build, version, post_url')
        .eq('platform', platform)
        .order('build', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  /// The row with the highest build not above [build] for [platform].
  Future<Map<String, dynamic>?> fetchUpTo(String platform, int build) async {
    final client = await _supabase.client;
    return client
        .from('app_releases')
        .select('build, version, post_url')
        .eq('platform', platform)
        .lte('build', build)
        .order('build', ascending: false)
        .limit(1)
        .maybeSingle();
  }
}
