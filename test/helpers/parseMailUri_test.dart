import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/theme/Helpers.dart';

void main() {
  test('Should parse mail deeplink', () {
    int id = 1234;
    var result = Helpers.parseMailUri('/mail/id/$id');
    expect(result[INTERNAL_URI_PARSER.mailId], id);
  });

  test('Should NOT parse mail deeplink', () {
    var result = Helpers.parseMailUri('/mail/id');
    expect(result[INTERNAL_URI_PARSER.mailId], null);
  });

  test('Should NOT parse mail deeplink', () {
    var result = Helpers.parseMailUri('/mail/id/asd');
    expect(result[INTERNAL_URI_PARSER.mailId], null);
  });
}
