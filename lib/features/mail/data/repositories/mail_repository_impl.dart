import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/features/mail/data/models/mail_model.dart';
import 'package:fyx/features/mail/domain/repositories/mail_repository.dart';

/// [MailRepository] backed by the Nyx API through [ApiController].
class MailRepositoryImpl implements MailRepository {
  @override
  Future<MailPage> getMails({int? lastId, String? search, bool isCompact = false}) async {
    final response = await ApiController().loadMail(lastId: lastId, search: search);
    final mails = response.mails.map((raw) => MailModel.fromJson(raw, isCompact: isCompact).toEntity()).toList();
    // Keep the previous cursor when the page is empty so pagination can stop.
    final nextId = mails.isEmpty ? lastId : mails.last.id;
    return MailPage(mails: mails, lastId: nextId);
  }
}
