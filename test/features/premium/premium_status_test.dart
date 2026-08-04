import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/domain/entities/premium_status.dart';
import 'package:fyx/features/premium/domain/enums/premium_freshness.dart';

void main() {
  final fetchedAt = DateTime(2026, 8, 1, 12);

  PremiumStatus subscriber({DateTime? validTo, bool isGod = false}) =>
      PremiumStatus(nickname: 'lucien144', isGod: isGod, validTo: validTo, fetchedAt: fetchedAt);

  group('premium with validTo', () {
    final status = subscriber(validTo: DateTime(2026, 9, 1));

    test('fresh until validTo', () {
      expect(status.freshnessAt(DateTime(2026, 8, 31, 23, 59)), PremiumFreshness.fresh);
      expect(status.isPremiumAt(DateTime(2026, 8, 31, 23, 59)), true);
    });

    test('grace from validTo for 7 days', () {
      expect(status.freshnessAt(DateTime(2026, 9, 1)), PremiumFreshness.grace);
      expect(status.freshnessAt(DateTime(2026, 9, 7, 23, 59)), PremiumFreshness.grace);
      expect(status.isPremiumAt(DateTime(2026, 9, 7, 23, 59)), true);
    });

    test('expired after grace; premium off', () {
      expect(status.freshnessAt(DateTime(2026, 9, 8)), PremiumFreshness.expired);
      expect(status.isPremiumAt(DateTime(2026, 9, 8)), false);
    });
  });

  group('god', () {
    final status = subscriber(isGod: true);

    test('fresh for 7 days from fetch', () {
      expect(status.freshnessAt(DateTime(2026, 8, 8, 11, 59)), PremiumFreshness.fresh);
      expect(status.isPremiumAt(DateTime(2026, 8, 8, 11, 59)), true);
    });

    test('grace for another 7 days, then expired', () {
      expect(status.freshnessAt(DateTime(2026, 8, 8, 12)), PremiumFreshness.grace);
      expect(status.freshnessAt(DateTime(2026, 8, 15, 11, 59)), PremiumFreshness.grace);
      expect(status.freshnessAt(DateTime(2026, 8, 15, 12)), PremiumFreshness.expired);
      expect(status.isPremiumAt(DateTime(2026, 8, 15, 12)), false);
    });

    test('god with a later validTo stays fresh until validTo', () {
      final godWithValidTo = subscriber(isGod: true, validTo: DateTime(2026, 10, 1));
      expect(godWithValidTo.freshnessAt(DateTime(2026, 9, 15)), PremiumFreshness.fresh);
    });
  });

  group('not premium', () {
    final status = subscriber(); // no validTo, not god

    test('fresh for 24 h, then stale; never premium', () {
      expect(status.freshnessAt(DateTime(2026, 8, 2, 11, 59)), PremiumFreshness.fresh);
      expect(status.freshnessAt(DateTime(2026, 8, 2, 12)), PremiumFreshness.stale);
      expect(status.isPremiumAt(DateTime(2026, 8, 1, 13)), false);
      expect(status.isPremiumAt(DateTime(2026, 8, 20)), false);
    });

    test('validTo already past at fetch counts as not premium', () {
      final lapsed = subscriber(validTo: DateTime(2026, 7, 1));
      expect(lapsed.wasPremiumAtFetch, false);
      expect(lapsed.freshnessAt(DateTime(2026, 8, 2, 13)), PremiumFreshness.stale);
      expect(lapsed.isPremiumAt(DateTime(2026, 8, 1, 13)), false);
    });
  });
}
