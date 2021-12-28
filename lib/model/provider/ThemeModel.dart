import 'package:flutter/cupertino.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';

class ThemeModel extends ChangeNotifier {
  final ThemeEnum initialTheme;
  ThemeModel(this.initialTheme);

  ThemeEnum? _theme;

  ThemeEnum get theme => _theme == null ? this.initialTheme : _theme!;

  void setTheme(ThemeEnum val) {
    _theme = val;
    notifyListeners();
  }
}
