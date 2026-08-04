import 'package:fyx/features/premium/data/datasources/premium_local_datasource.dart';
import 'package:fyx/features/premium/data/datasources/premium_remote_datasource.dart';
import 'package:fyx/features/premium/data/models/premium_status_model.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/repositories/premium_repository.dart';

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumLocalDatasource _local;
  final PremiumRemoteDatasource _remote;
  final DateTime Function() _clock;

  PremiumRepositoryImpl(this._local, this._remote, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  @override
  Future<PremiumStatus?> getCached(String nickname) async {
    final model = await _local.read();
    if (model == null) return null;
    if (model.nickname != nickname) {
      await _local.delete();
      return null;
    }
    return model.toEntity();
  }

  @override
  Future<PremiumStatus> refresh(String nickname) async {
    final row = await _remote.fetchSubscriber(nickname);
    final model = PremiumStatusModel.fromRow(row, nickname: nickname, fetchedAt: _clock());
    await _local.write(model);
    return model.toEntity();
  }
}
