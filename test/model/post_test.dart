import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/post/Image.dart';

void main() {
  test('Parse basic post with one internal image.', () {
    var post = Post.fromJson({
      "id_wu": "51360794",
      "nick": "LOJZEE",
      "time": "1573934376",
      "content":
          "James Caan on set of The Godfather.<br><br><!-- http,img,attachment --><a href=\"http://i.nyx.cz/files/00/00/20/68/2068213_7dde4d7aa8e3021dd610.jpg?name=11.jpg\"><img src=\"http://www.nyx.cz/i/t/b0ccf0fde73a5840dea9f0dbc5d18e6d.png?url=http%3A%2F%2Fi.nyx.cz%2Ffiles%2F00%2F00%2F20%2F68%2F2068213_7dde4d7aa8e3021dd610.jpg%3Fname%3D11.jpg\" class=\"thumb\"></a>",
      "wu_rating": "8",
      "wu_type": "0"
    });
    expect(post.id, 51360794);
    expect(post.nick, 'LOJZEE');
    expect(post.avatar, 'https://i.nyx.cz/L/LOJZEE.gif');
    expect(post.time, 1573934376);
    expect(post.rating, 8);
    expect(post.type, 0);
    expect(post.rawContent,
        "James Caan on set of The Godfather.<br><br><!-- http,img,attachment --><a href=\"http://i.nyx.cz/files/00/00/20/68/2068213_7dde4d7aa8e3021dd610.jpg?name=11.jpg\"><img src=\"http://www.nyx.cz/i/t/b0ccf0fde73a5840dea9f0dbc5d18e6d.png?url=http%3A%2F%2Fi.nyx.cz%2Ffiles%2F00%2F00%2F20%2F68%2F2068213_7dde4d7aa8e3021dd610.jpg%3Fname%3D11.jpg\" class=\"thumb\"></a>");

    var imagesMatcher = [
      Image('http://i.nyx.cz/files/00/00/20/68/2068213_7dde4d7aa8e3021dd610.jpg?name=11.jpg',
          'http://www.nyx.cz/i/t/b0ccf0fde73a5840dea9f0dbc5d18e6d.png?url=http%3A%2F%2Fi.nyx.cz%2Ffiles%2F00%2F00%2F20%2F68%2F2068213_7dde4d7aa8e3021dd610.jpg%3Fname%3D11.jpg')
    ];

    Function deepEq = const DeepCollectionEquality().equals;
    expect(deepEq(post.images, imagesMatcher), true);

    expect(post.links.length, 0);
  });
}
