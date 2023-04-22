import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/theme/Helpers.dart';

void main() {
  test('Should parse search URI', () {
    var result = Helpers.parseSearchUri('https://nyx.cz/search?text=Nekane%20img%20src');
    expect(result, 'Nekane%20img%20src');
  });

  test('Should be null', () {
    var result = Helpers.parseSearchUri('/discussion/123?text=%23hashtag');
    expect(result, null);
  });
}