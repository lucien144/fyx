import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/data/models/premium_status_model.dart';

void main() {
  final fetchedAt = DateTime(2026, 8, 1, 12);

  test('fromRow maps a subscriber row', () {
    final model = PremiumStatusModel.fromRow(
      {'nickname': 'lucien144', 'valid_to': '2026-09-01T00:00:00', 'is_god': false},
      nickname: 'lucien144',
      fetchedAt: fetchedAt,
    );
    expect(model.nickname, 'lucien144');
    expect(model.isGod, false);
    expect(model.validTo, DateTime.parse('2026-09-01T00:00:00'));
    expect(model.toEntity().wasPremiumAtFetch, true);
  });

  test('fromRow maps a missing row to a negative status', () {
    final model = PremiumStatusModel.fromRow(null, nickname: 'lucien144', fetchedAt: fetchedAt);
    expect(model.isGod, false);
    expect(model.validTo, isNull);
    expect(model.toEntity().wasPremiumAtFetch, false);
  });

  test('fromRow tolerates null valid_to and true is_god', () {
    final model = PremiumStatusModel.fromRow(
      {'nickname': 'lucien144', 'valid_to': null, 'is_god': true},
      nickname: 'lucien144',
      fetchedAt: fetchedAt,
    );
    expect(model.isGod, true);
    expect(model.validTo, isNull);
    expect(model.toEntity().wasPremiumAtFetch, true);
  });

  test('toJson/fromJson round-trips', () {
    final model = PremiumStatusModel(
      nickname: 'lucien144',
      isGod: true,
      validTo: DateTime(2026, 9, 1),
      fetchedAt: fetchedAt,
    );
    final restored = PremiumStatusModel.fromJson(model.toJson());
    expect(restored, model);
  });

  test('toEntity carries all fields', () {
    final entity = PremiumStatusModel(
      nickname: 'lucien144',
      isGod: false,
      validTo: DateTime(2026, 9, 1),
      fetchedAt: fetchedAt,
    ).toEntity();
    expect(entity.nickname, 'lucien144');
    expect(entity.validTo, DateTime(2026, 9, 1));
    expect(entity.fetchedAt, fetchedAt);
  });
}
