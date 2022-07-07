import 'package:flutter/cupertino.dart';

abstract class SkinData<C> {
  final SkinBrightnessData<C> lightData;
  final SkinBrightnessData<C> darkData;

  SkinData({required this.lightData, required this.darkData});
}

class SkinBrightnessData<C> {
  final CupertinoThemeData data;
  final C colors;

  SkinBrightnessData({required this.data, required this.colors});
}

class Skin extends InheritedWidget {
  Skin({
    Key? key,
    required this.skin,
    required this.brightness,
    required Widget child,
  }) : super(key: key, child: child);

  final SkinData skin;
  final Brightness brightness;

  SkinBrightnessData get theme => this.brightness == Brightness.light ? skin.lightData : skin.darkData;

  double get defaultFontSize => 16;

  static Skin of(BuildContext context) {
    final Skin? result = context.dependOnInheritedWidgetOfExactType<Skin>();
    assert(result != null, 'No Skin found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Skin old) => brightness != old.brightness;
}
