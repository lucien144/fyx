import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/features/mail/data/models/mail_model.dart';
import 'package:fyx/features/mail/data/models/mail_page_model.dart';

class MailRemoteDataSource {
  MailRemoteDataSource(this._apiController);

  final ApiController _apiController;

  Future<MailPageModel> loadMailPage({int? lastId, String? searchTerm}) async {
    final response = await _apiController.loadMail(lastId: lastId, search: searchTerm);
    final mailModels = response.mails
        .cast<Map<String, dynamic>>()
        .map(MailModel.fromApiJson)
        .toList(growable: false);

    final nextLastId = mailModels.isEmpty ? lastId : mailModels.last.id;

    return MailPageModel(mails: mailModels, nextLastId: nextLastId);
  }
}
