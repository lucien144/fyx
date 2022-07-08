import 'package:flutter/cupertino.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';

class ThemeModel extends ChangeNotifier {
  final ThemeEnum initialTheme;
  final double initialFontSize;
  ThemeModel(this.initialTheme, this.initialFontSize);

  ThemeEnum? _theme;
  double? _fontSize;

  ThemeEnum get theme => _theme == null ? this.initialTheme : _theme!;

  double get fontSize => _fontSize == null ? this.initialFontSize : _fontSize!;

  void setTheme(ThemeEnum val) {
    _theme = val;
    notifyListeners();
  }

  void setFontSize(double val) {
    _fontSize = val;
    notifyListeners();
  }
}
