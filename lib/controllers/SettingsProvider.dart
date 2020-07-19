import 'package:fyx/model/Settings.dart';
import "package:hive/hive.dart";
import "package:hive_flutter/hive_flutter.dart";

class SettingsProvider<T> {
  static final SettingsProvider _singleton = SettingsProvider._internal();
  Settings _settings;
  Box<dynamic> _box;

  DefaultView get defaultView => _settings.defaultView;
  set defaultView(DefaultView view) {
    _box.put('defaultView', view);
    _settings.defaultView = view;
  }

  bool get useCompactMode => _settings.useCompactMode;
  set useCompactMode(bool mode) {
    _box.put('useCompactMode', mode);
    _settings.useCompactMode = mode;
  }

  factory SettingsProvider() {
    return _singleton;
  }

  SettingsProvider._internal();

  Future<SettingsProvider> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('settings');

    _settings = new Settings();
    _settings.defaultView = _box.get('defaultView', defaultValue: Settings().defaultView);
    _settings.useCompactMode = _box.get('useCompactMode', defaultValue: Settings().useCompactMode);

    return _singleton;
  }
}
