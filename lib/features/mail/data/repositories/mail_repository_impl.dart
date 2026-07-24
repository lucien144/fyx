import 'package:fyx/features/mail/data/datasources/mail_remote_datasource.dart';
import 'package:fyx/features/mail/domain/entities/mail_page_entity.dart';
import 'package:fyx/features/mail/domain/repositories/mail_repository.dart';

class MailRepositoryImpl implements MailRepository {
  MailRepositoryImpl(this._remoteDataSource);

  final MailRemoteDataSource _remoteDataSource;

  @override
  Future<MailPageEntity> loadMailPage({int? lastId, String? searchTerm}) async {
    final result = await _remoteDataSource.loadMailPage(lastId: lastId, searchTerm: searchTerm);
    return result.toEntity();
  }
}
