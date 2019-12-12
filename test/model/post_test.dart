import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/model/post/Image.dart';
import 'package:fyx/model/post/Video.dart';
import 'package:html/parser.dart';

void main() {
  const _json = {"id_wu": "51360794", "nick": "TOMMYSHELBY", "time": "1573934376", "wu_rating": "8", "wu_type": "0"};

  test('Post has one internal image and one internal link.', () {
    var content = """
          James Caan on set of The Godfather.<br><br>
          <!-- http,img,attachment -->
          <a href="http://i.nyx.cz/files/00/00/20/68/2068213_7dde4d7aa8e3021dd610.jpg?name=11.jpg">
          <img src="http://www.nyx.cz/i/t/b0ccf0fde73a5840dea9f0dbc5d18e6d.png?url=http%3A%2F%2Fi.nyx.cz%2Ffiles%2F00%2F00%2F20%2F68%2F2068213_7dde4d7aa8e3021dd610.jpg%3Fname%3D11.jpg" class="thumb">
          </a>
          <a href="?l=topic;id=14158;wu=51447388" class="r" data-link-topic="14158" data-link-wu="51447388" data-reply-to="replytoJAKKILLER">JAKKILLER</a>: 
          ale jo, to patri, ale o tom ten muj post nebyl. Vsechno jde udelat vkusne a nebo hnusne. O tom to je. Na ty budejarne MNE OSOBNE prijdou ty reklamy jako pest na oko...
    """;

    var json = Map<String, dynamic>.from(_json);
    json.putIfAbsent("content", () => content);

    var post = Post.fromJson(json);
    expect(post.id, 51360794);
    expect(post.nick, 'TOMMYSHELBY');
    expect(post.avatar, 'https://i.nyx.cz/T/TOMMYSHELBY.gif');
    expect(post.time, 1573934376);
    expect(post.rating, 8);
    expect(post.type, 0);
    expect(post.rawContent, content);
    expect(0, parse(post.content).querySelectorAll('a > img').length, reason: 'Images have been removed.');
    expect(1, parse(post.content).querySelectorAll('a').length, reason: 'Other links remains');

    var imagesMatcher = [
      Image('http://i.nyx.cz/files/00/00/20/68/2068213_7dde4d7aa8e3021dd610.jpg?name=11.jpg',
          'http://www.nyx.cz/i/t/b0ccf0fde73a5840dea9f0dbc5d18e6d.png?url=http%3A%2F%2Fi.nyx.cz%2Ffiles%2F00%2F00%2F20%2F68%2F2068213_7dde4d7aa8e3021dd610.jpg%3Fname%3D11.jpg')
    ];

    Function deepEq = const DeepCollectionEquality().equals;
    expect(deepEq(post.images, imagesMatcher), true);

    expect(post.links.length, 0, reason: 'Internal link is not treated as attachment.');
  });

  test('Post has more internal images', () {
    var content = """
    sem ned\u00e1vno \u0161el ve\u010der kolem DBK, v\u017edycky m\u011b ta budova fascinovala sv\u00fdm brutalismem, jen mn\u011b na n\u00ed v\u017edycky serou ty reklamy, \u00fapln\u011b to kaz\u00ed ten \u00fa\u017easnej potenci\u00e1l minimalistick\u00fd dekorace... 
    tak sem to narychlo umazal, vypadalo by to super! Jak n\u011bjakej bar\u00e1k z Bladerunnera :)<br><br>
    <!-- http,img,attachment --><a href="http://i.nyx.cz/files/00/00/20/77/2077557_48d4a18f67ad53d7572e.jpg?name=dbk2.jpg"><img src="http://www.nyx.cz/i/t/6a6f8dae07571ecfb1510c18e6dd6d0a.png?url=http%3A%2F%2Fi.nyx.cz%2Ffiles%2F00%2F00%2F20%2F77%2F2077557_48d4a18f67ad53d7572e.jpg%3Fname%3Ddbk2.jpg" class="thumb"></a><br><br>
    <!-- http,img,attachment --><a href="http://i.nyx.cz/files/00/00/20/77/2077556_45259e39b491933bb483.jpg?name=dbk.jpg"><img src="http://www.nyx.cz/i/t/8697a44511a1664f7adc53b39821ce7c.png?url=http%3A%2F%2Fi.nyx.cz%2Ffiles%2F00%2F00%2F20%2F77%2F2077556_45259e39b491933bb483.jpg%3Fname%3Ddbk.jpg" class="thumb"></a>
    """;

    var json = Map<String, dynamic>.from(_json);
    json.putIfAbsent("content", () => content);

    var post = Post.fromJson(json);
    expect(post.images.length, 2);
    expect(post.images[0].image, 'http://i.nyx.cz/files/00/00/20/77/2077557_48d4a18f67ad53d7572e.jpg?name=dbk2.jpg');
    expect(post.images[1].image, 'http://i.nyx.cz/files/00/00/20/77/2077556_45259e39b491933bb483.jpg?name=dbk.jpg');
    expect(post.images[0].thumb,
        'http://www.nyx.cz/i/t/6a6f8dae07571ecfb1510c18e6dd6d0a.png?url=http%3A%2F%2Fi.nyx.cz%2Ffiles%2F00%2F00%2F20%2F77%2F2077557_48d4a18f67ad53d7572e.jpg%3Fname%3Ddbk2.jpg');
    expect(post.images[1].thumb,
        'http://www.nyx.cz/i/t/8697a44511a1664f7adc53b39821ce7c.png?url=http%3A%2F%2Fi.nyx.cz%2Ffiles%2F00%2F00%2F20%2F77%2F2077556_45259e39b491933bb483.jpg%3Fname%3Ddbk.jpg');
    expect(post.links.length, 0);
    expect(0, parse(post.content).querySelectorAll('a > img').length);
  });

  test('Post is mixed vide Youtube, links and images', () {
    var content = """
        jen tak na okraj:<br \/>\r\n<br \/>\r\n
        Viktoriiny vodop\u00e1dy, fotka publikovan\u00e1 v roce 2015:<br \/>\r\n<br \/>\r\n
        <a href=\"https:\/\/web.archive.org\/web\/20170331170530im_\/https:\/\/africageographic.com\/wp-content\/uploads\/2015\/11\/vic-falls-dry.jpg\">
          <img src=\"http:\/\/www.nyx.cz\/i\/t\/90f094a7ebd94d45db45cbddc9243717.png?url=https%3A%2F%2Fweb.archive.org%2Fweb%2F20170331170530im_%2Fhttps%3A%2F%2Fafricageographic.com%2Fwp-content%2Fuploads%2F2015%2F11%2Fvic-falls-dry.jpg\" class=\"thumb\">
        <\/a><br \/>\r\n<br \/>
        \r\nzdroj:<br \/>\r\n<br \/>\r\n
        <b>Victoria Falls has not dried up - here\u2019s the proof - Africa Geographic<\/b><br \/>\n
        <a href=\"https:\/\/web.archive.org\/web\/20170331170530\/https:\/\/africageographic.com\/blog\/victoria-falls-not-dried-heres-proof\/\" class=\"odkaz\" rel=\"nofollow\">
          https:\/\/web.archive.org\/...0\/https:\/\/africageographic.com\/blog\/victoria-falls-not-dried-heres-proof\/
        <\/a>
        <br \/>\n\r<br \/>\n\r<br \/>\n
        Such\u00e9 obdob\u00ed v roce 2013 (druh\u00e1 p\u016flka videa):<br \/>\r\n
        <b>\u65c5\u3059\u308b\u9234\u6728436:Victoria Falls in Dry season @Zimbabwe<\/b><br \/>\n
        <a href=\"http:\/\/www.youtube.com\/watch?v=B1_gcCu0-oI\" class=\"odkaz\" rel=\"nofollow\">
          http:\/\/www.youtube.com\/watch?v=B1_gcCu0-oI
        <\/a><br \/>\n
        <div class=\"embed-wrapper\" data-embed-type=\"youtube\" data-embed-value=\"B1_gcCu0-oI\" data-embed-hd=\"1\">
          <a href=\"http:\/\/img.youtube.com\/vi\/B1_gcCu0-oI\/0.jpg\">
            <img src=\"http:\/\/www.nyx.cz\/i\/t\/e8464b77ee2b7a726f174be309201ade.png?url=http%3A%2F%2Fimg.youtube.com%2Fvi%2FB1_gcCu0-oI%2F0.jpg\" class=\"thumb\">
          <\/a>
        <\/div>
        <br \/>\n\r<br \/>\n\r<br \/>\n
        Na tom videu je nav\u00edc moc p\u011bkn\u011b vid\u011bt, jak d\u016fle\u017eit\u00fd je \u00fahel pohledu.
        <a target="_blank" href="http://nyx.cz">Tohle je link bez title</a>
        """;

    var json = Map<String, dynamic>.from(_json);
    json.putIfAbsent("content", () => content);

    var post = Post.fromJson(json);

    // Testing videos
    expect(post.videos.length, 1);
    expect(post.videos[0].id, 'B1_gcCu0-oI');
    expect(post.videos[0].type, VIDEO_TYPE.youtube);
    expect(post.videos[0].image, 'http://img.youtube.com/vi/B1_gcCu0-oI/0.jpg');
    expect(post.videos[0].thumb, 'http://www.nyx.cz/i/t/e8464b77ee2b7a726f174be309201ade.png?url=http%3A%2F%2Fimg.youtube.com%2Fvi%2FB1_gcCu0-oI%2F0.jpg');
    expect(post.videos[0].link, 'https://www.youtube.com/watch?v=B1_gcCu0-oI');
    expect(0, parse(post.content).querySelectorAll('div[data-embed-value="B1_gcCu0-oI"]').length);

    // Test images
    expect(post.images.length, 1);

    // Test links
    expect(post.links.length, 3);
    expect(post.links[0].title, 'Victoria Falls has not dried up - here\u2019s the proof - Africa Geographic');
    expect(post.links[0].url, 'https://web.archive.org/web/20170331170530/https://africageographic.com/blog/victoria-falls-not-dried-heres-proof/');
    expect(post.links[1].title, '\u65c5\u3059\u308b\u9234\u6728436:Victoria Falls in Dry season @Zimbabwe');
    expect(post.links[1].url, 'http://www.youtube.com/watch?v=B1_gcCu0-oI');
    expect(post.links[2].title, 'Tohle je link bez title');
    expect(post.links[2].url, 'http://nyx.cz');

    expect(post.countAttachments, 5);
  });
}
