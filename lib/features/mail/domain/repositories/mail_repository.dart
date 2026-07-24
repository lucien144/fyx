import 'package:fyx/features/mail/domain/entities/mail_page_entity.dart';

abstract interface class MailRepository {
  Future<MailPageEntity> loadMailPage({int? lastId, String? searchTerm});
}
