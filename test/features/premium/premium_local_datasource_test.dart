import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/features/premium/data/datasources/premium_local_datasource.dart';
import 'package:fyx/features/premium/data/models/premium_status_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final model = PremiumStatusModel(
    nickname: 'lucien144',
    isGod: false,
    validTo: DateTime(2026, 9, 1),
    fetchedAt: DateTime(2026, 8, 1, 12),
  );

  test('write/read round-trips', () async {
    SharedPreferences.setMockInitialValues({});
    final datasource = PremiumLocalDatasource();
    await datasource.write(model);
    expect(await datasource.read(), model);
  });

  test('read returns null when nothing is stored', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await PremiumLocalDatasource().read(), isNull);
  });

  test('corrupt JSON reads as null and is removed', () async {
    SharedPreferences.setMockInitialValues({'premium_status': 'not-json{'});
    final datasource = PremiumLocalDatasource();
    expect(await datasource.read(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('premium_status'), isNull);
  });

  test('delete removes the record', () async {
    SharedPreferences.setMockInitialValues({'premium_status': jsonEncode(model.toJson())});
    final datasource = PremiumLocalDatasource();
    await datasource.delete();
    expect(await datasource.read(), isNull);
  });
}
