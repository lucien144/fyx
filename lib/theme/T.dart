// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class T {
  // Colors
  // Color scheme -> https://mycolor.space/?hex=%231AD592&sub=1
  static final Color COLOR_PRIMARY = Color(0xFF196378);
  static final Color COLOR_SECONDARY = Color(0xff007F90);
  static final Color COLOR_BLACK = Color(0xFF282828);

  // Others
  static final BoxShadow BOX_SHADOW = BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), offset: Offset(0, 0), blurRadius: 16);
  static final BoxDecoration TEXTFIELD_DECORATION = BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white, border: Border.all(color: COLOR_SECONDARY));
  static final BoxDecoration CARD_DECORATION = BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: COLOR_SECONDARY));
  static final BoxDecoration CARD_SHADOW_DECORATION =
      BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: COLOR_SECONDARY), boxShadow: [BOX_SHADOW]);
  static final LinearGradient GRADIENT = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xff1AD592), Color(0xff2F4858)]);
}
