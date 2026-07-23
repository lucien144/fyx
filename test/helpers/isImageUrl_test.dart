import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/theme/Helpers.dart';

void main() {
  test('Should recognize an image URL', () {
    expect(Helpers.isImageUrl('http://i.mg/full.jpg'), true);
    expect(Helpers.isImageUrl('http://i.mg/full.jpeg'), true);
    expect(Helpers.isImageUrl('http://i.mg/full.png'), true);
    expect(Helpers.isImageUrl('http://i.mg/full.gif'), true);
    expect(Helpers.isImageUrl('http://i.mg/full.webp'), true);
  });

  test('Should ignore the case of the extension', () {
    expect(Helpers.isImageUrl('http://i.mg/FULL.JPG'), true);
    expect(Helpers.isImageUrl('http://i.mg/Full.PnG'), true);
  });

  test('Should recognize an image URL with a query string', () {
    expect(Helpers.isImageUrl('http://i.nyx.cz/files/00/00/20/68/2068213.jpg?name=11.jpg'), true);
    expect(Helpers.isImageUrl('http://i.mg/full.PNG?v=2'), true);
  });

  test('Should NOT recognize a non-image URL', () {
    expect(Helpers.isImageUrl('https://ibb.co/SDTtqGf'), false);
    expect(Helpers.isImageUrl('https://nyx.cz/discussion/17739'), false);
    expect(Helpers.isImageUrl('http://i.mg/full.jpg.html'), false);
    expect(Helpers.isImageUrl(''), false);
    expect(Helpers.isImageUrl(null), false);
  });
}
