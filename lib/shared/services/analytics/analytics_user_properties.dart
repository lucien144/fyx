import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/features/premium/presentation/viewmodel/premium_state.dart';
import 'package:fyx/shared/services/analytics/analytics_service.dart';

/// User settings sent as analytics user properties. Counts only, never the
/// content (who is blocked, which discussions are NSFW, ...).
///
/// Firebase allows at most 25 user properties; keep the map below that.
Map<String, Object> analyticsUserProperties(SettingsProvider settings, PremiumState premium) {
  return {
    'theme': settings.theme.name,
    'skin': settings.skin.name,
    'fontSize': settings.fontSize.toInt(),
    'appIcon': settings.appIcon.name,
    'compactMode': settings.useCompactMode,
    'markdown': settings.useMarkdown,
    'bulkActions': settings.useBulkActions,
    'autocorrect': settings.useAutocorrect,
    'quickRating': settings.quickRating,
    'fyxImageCache': settings.useFyxImageCache,
    'defaultView': settings.defaultView.name,
    'firstUnread': settings.firstUnread.name,
    'linksMode': settings.linksMode.name,
    'nsfwMail': settings.nsfwMail,
    'blockedUsers': settings.blockedUsers.length,
    'blockedPosts': settings.blockedPosts.length,
    'blockedMails': settings.blockedMails.length,
    'nsfwDiscussions': settings.nsfwDiscussionList.length,
    'savedSearches': settings.savedSearch.length,
    'premium': premium.isPremium,
    'premiumUnlocked': premium.isUnlocked,
  };
}

extension AnalyticsUserProperties on AnalyticsService {
  /// Sends the current settings; no-op when they did not change since the last call.
  Future<void> trackUserProperties(SettingsProvider settings, PremiumState premium) {
    return setUserProperties(analyticsUserProperties(settings, premium));
  }
}
