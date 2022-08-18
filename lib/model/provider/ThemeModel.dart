import 'package:flutter/cupertino.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';

class ThemeModel extends ChangeNotifier {
  final ThemeEnum initialTheme;
  final SkinEnum initialSkin;
  final double initialFontSize;
  ThemeModel(this.initialTheme, this.initialFontSize, {this.initialSkin = SkinEnum.fyx});

  ThemeEnum? _theme;
  SkinEnum? _skin;
  double? _fontSize;

  ThemeEnum get theme => _theme == null ? this.initialTheme : _theme!;

  SkinEnum get skin => _skin == null ? this.initialSkin : _skin!;

  double get fontSize => _fontSize == null ? this.initialFontSize : _fontSize!;

  void setTheme(ThemeEnum val) {
    _theme = val;
    notifyListeners();
  }

  void setFontSize(double val) {
    _fontSize = val;
    notifyListeners();
  }

  void setSkin(SkinEnum skin) {
    _skin = skin;
    notifyListeners();
  }
}
