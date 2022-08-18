import 'package:flutter/cupertino.dart';
import 'package:fyx/model/enums/SkinEnum.dart';

abstract class SkinData<C> {
  abstract final String name;
  abstract final SkinEnum id;

  late final SkinBrightnessData<C> lightData;
  late final SkinBrightnessData<C> darkData;

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
    required this.skins,
    required this.brightness,
    required Widget child,
  }) : super(key: key, child: child);

  final SkinEnum skin;
  final List<SkinData> skins;
  final Brightness brightness;

  SkinBrightnessData get theme {
    final _selectedSkin = skins.firstWhere((skin) => skin.id == this.skin);
    return this.brightness == Brightness.light ? _selectedSkin.lightData : _selectedSkin.darkData;
  }

  static Skin of(BuildContext context) {
    final Skin? result = context.dependOnInheritedWidgetOfExactType<Skin>();
    assert(result != null, 'No Skin found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Skin old) => brightness != old.brightness;
}
