import 'package:fyx/model/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider {
  static final SettingsProvider _singleton = SettingsProvider._internal();
  Settings _settings;
  SharedPreferences _prefs;

  DefaultView get defaultView => _settings.defaultView;
  set defaultView(DefaultView view) {
    _prefs.setString('defaultView', view.toString());
    _settings.defaultView = view;
  }

  bool get useCompactMode => _settings.useCompactMode;
  set useCompactMode(bool mode) {
    _prefs.setBool('useCompactMode', mode);
    _settings.useCompactMode = mode;
  }

  factory SettingsProvider() {
    return _singleton;
  }

  SettingsProvider._internal();

  Future<SettingsProvider> init() async {
    _prefs = await SharedPreferences.getInstance();
    _settings = new Settings();
    _settings.defaultView = DefaultView.values.firstWhere((DefaultView view) => view.toString() == _prefs.get('defaultView'));
    _settings.useCompactMode = _prefs.get('useCompactMode');

    if (_settings.defaultView == null) {
      defaultView = Settings().defaultView;
    }

    if (_settings.useCompactMode == null) {
      useCompactMode = Settings().useCompactMode;
    }

    return _singleton;
  }
}
