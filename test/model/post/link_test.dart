import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/model/post/Link.dart';

void main() {
  test('Link without title has a normalized URL as titile.', () {
    var link = Link('http://www.csfd.cz/film/6677-amerika/');
    expect(link.title, 'csfd.cz/film/6677-amerika/');
  });

  test('General link test', () {
    var link = Link('https://www.csfd.cz/film/6677-amerika/', title: 'Amerika');
    expect(link.title, 'Amerika');
    expect(link.url, 'https://www.csfd.cz/film/6677-amerika/');
    expect(link.fancyUrl, 'csfd.cz/film/6677-amerika/');
  });
}
