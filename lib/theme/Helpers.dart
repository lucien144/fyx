import 'package:fyx/theme/L.dart';
import 'package:html/parser.dart';

class Helpers {
  static stripHtmlTags(String html) {
    final document = parse(html);
    return parse(document.body.text).documentElement.text.trim();
  }

  static String parseTime(int time) {
    var duration = Duration(seconds: ((DateTime.now().millisecondsSinceEpoch / 1000).floor() - time));
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
}