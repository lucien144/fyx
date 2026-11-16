import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/features/mail/domain/repositories/mail_settings_repository.dart';

/// [MailSettingsRepository] backed by the app settings (Hive).
class MailSettingsRepositoryImpl implements MailSettingsRepository {
  @override
  bool get isNsfw => SettingsProvider().nsfwMail;

  @override
  set isNsfw(bool value) => SettingsProvider().nsfwMail = value;
}
