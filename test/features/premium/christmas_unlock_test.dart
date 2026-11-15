import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/domain/entities/christmas_unlock.dart';

void main() {
  test('is active from December 24 to 31 inclusive', () {
    expect(ChristmasUnlock.isActive(DateTime(2026, 12, 23, 23, 59)), isFalse);
    expect(ChristmasUnlock.isActive(DateTime(2026, 12, 24)), isTrue);
    expect(ChristmasUnlock.isActive(DateTime(2026, 12, 28, 12)), isTrue);
    expect(ChristmasUnlock.isActive(DateTime(2026, 12, 31, 23, 59)), isTrue);
    expect(ChristmasUnlock.isActive(DateTime(2027, 1, 1)), isFalse);
    expect(ChristmasUnlock.isActive(DateTime(2026, 11, 24)), isFalse);
  });
}
