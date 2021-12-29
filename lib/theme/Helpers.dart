import 'package:fyx/theme/L.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';

enum INTERNAL_URI_PARSER { discussionId, postId, search }

class Helpers {
  static stripHtmlTags(String html) {
    final document = parse(html);
    return parse(document.body?.text).documentElement?.text.trim();
  }

  static String absoluteTime(int time) {
    final DateTime then = DateTime.fromMillisecondsSinceEpoch(time);
    final DateFormat formatter = DateFormat(then.year == DateTime.now().year ? 'd. M. HH:mm' : 'd. M. y HH:mm');
    return formatter.format(then);
  }

  static String relativeTime(int time) {
    var duration = Duration(milliseconds: ((DateTime.now().millisecondsSinceEpoch).floor() - time));
    if (duration.inSeconds <= 0) {
      return L.GENERAL_NOW;
    }
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    }
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m';
    }
    if (duration.inHours < 24) {
      return '${duration.inHours}H';
    }
    if (duration.inDays < 30) {
      return '${duration.inDays}D';
    }

    var months = (duration.inDays / 30).round(); // Approx
    if (months < 12) {
      return '${months}M';
    }

    var years = (months / 12).round();
    return '${years}Y';
  }

  static double ratingRange(int rating) {
    final opacity = {
      0.2: [0, 20],
      0.4: [20, 80],
      0.6: [80, 150],
      0.8: [150, 250],
      0.9: [250, 350],
    };

    for (var entry in opacity.entries) {
      if (rating == rating.clamp(entry.value[0], entry.value[1])) {
        return entry.key;
      }
    }

    return 1.0;
  }

  static Map<INTERNAL_URI_PARSER, int> parseDiscussionPostUri(String uri) {
    RegExp test = new RegExp(r"(\?l=topic;id=([0-9]+);wu=([0-9]+))|(/discussion/([0-9]+)/id/([0-9]+))$");
    Iterable<RegExpMatch> matches = test.allMatches(uri);
    if (matches.length == 1) {
      int discussionId = int.parse(matches.elementAt(0).group(2) ?? '0');
      int postId = int.parse(matches.elementAt(0).group(3) ?? '0');
      if (discussionId == 0 && postId == 0) {
        discussionId = int.parse(matches.elementAt(0).group(5) ?? '0');
        postId = int.parse(matches.elementAt(0).group(6) ?? '0');
      }
      return {INTERNAL_URI_PARSER.discussionId: discussionId, INTERNAL_URI_PARSER.postId: postId};
    }
    return {};
  }

  static Map<INTERNAL_URI_PARSER, dynamic> parseDiscussionUri(String uri) {
    RegExp test = new RegExp(r"(\?l=topic;id=([0-9]+))|(/discussion/([0-9]+)(\?(.*))?)$");
    final parsed = Uri.parse(uri);

    Iterable<RegExpMatch> matches = test.allMatches(uri);
    if (matches.length == 1) {
      int discussionId = int.parse(matches.elementAt(0).group(2) ?? '0');
      if (discussionId == 0) {
        discussionId = int.parse(matches.elementAt(0).group(4) ?? '0');
      }
      return {INTERNAL_URI_PARSER.discussionId: discussionId, INTERNAL_URI_PARSER.search: parsed.queryParameters['text']};
    }
    return {};
  }

  static String? fileExtension(String filePath) {
    final regexp = RegExp(r'\.(?<ext>[a-z]{3,})$', caseSensitive: false);
    final matches = regexp.allMatches(filePath);

    if (matches.isNotEmpty) {
      return matches.last.namedGroup('ext');
    }

    throw Exception('Unknown file type');
  }

  static String avatarUrl(String username) {
    return 'https://nyx.cz/${username.substring(0, 1)}/$username.gif';
  }
}