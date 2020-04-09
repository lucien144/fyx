import 'package:flutter/cupertino.dart';

class SettingsModel extends ChangeNotifier {
  bool _useHeroPosts = true;

  // TODO: persistence
  bool get useHeroPosts => _useHeroPosts;

  void toggleUseHeroPosts() {
    _useHeroPosts = !_useHeroPosts;
    notifyListeners();
  }
}
