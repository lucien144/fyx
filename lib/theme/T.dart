// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

// Theme helpers
class T {
  // Colors
  // Color scheme -> https://mycolor.space/?hex=%231AD592&sub=1
  static const Color COLOR_PRIMARY = Color(0xFF196378);
  static const Color COLOR_LIGHT = Color(0xffE9F3F5);
  static const Color COLOR_SECONDARY = Color(0xff007F90);
  static const Color COLOR_BLACK = Color(0xFF282828);
  static const Color COLOR_ACCENT = Color(0xffB60F0F);

  // Others
  static final BoxShadow BOX_SHADOW = BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), offset: Offset(0, 0), blurRadius: 16);
  static final BoxDecoration TEXTFIELD_DECORATION = BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white, border: Border.all(color: COLOR_SECONDARY));
  static final BoxDecoration CARD_DECORATION = BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: COLOR_SECONDARY));
  static final BoxDecoration CARD_SHADOW_DECORATION =
      BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: COLOR_SECONDARY), boxShadow: [BOX_SHADOW]);
  static final LinearGradient GRADIENT = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xff2F4858)]);

  // ************************
  // Icons
  // ************************
  static final ICO_REPLY = Icon(
    Icons.reply,
    color: Colors.black38,
  );
  static final ICO_UNREAD = Icon(
    Icons.markunread_mailbox,
    color: Colors.black38,
  );

  static String parseTime(int time) {
    var duration = Duration(seconds: ((DateTime.now().millisecondsSinceEpoch / 1000).floor() - time));
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
