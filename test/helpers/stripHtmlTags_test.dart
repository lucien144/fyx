import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/theme/Helpers.dart';

void main() {
  test('Should preserve newlines from <br> tags', () {
    var result = Helpers.stripHtmlTags('Line one<br>Line two<br />Line three');
    expect(result, 'Line one\nLine two\nLine three');
  });

  test('Should strip other tags without affecting newlines', () {
    var result = Helpers.stripHtmlTags('<b>Bold</b><br><i>Italic</i>');
    expect(result, 'Bold\nItalic');
  });

  test('Should still trim surrounding whitespace', () {
    var result = Helpers.stripHtmlTags('<br>  Text  <br>');
    expect(result, 'Text');
  });
}