import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Settings.dart';
import 'package:fyx/model/enums/SkinEnum.dart';
import 'package:fyx/model/enums/ThemeEnum.dart';
import 'package:fyx/model/provider/ThemeModel.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsDesignScreen extends StatefulWidget {
  const SettingsDesignScreen({Key? key}) : super(key: key);

  @override
  _SettingsDesignScreenState createState() => _SettingsDesignScreenState();
}

class _SettingsDesignScreenState extends State<SettingsDesignScreen> {
  ThemeEnum _theme = ThemeEnum.light;

  @override
  void initState() {
    super.initState();

    _theme = MainRepository().settings.theme;
    AnalyticsProvider().setScreen('Settings / Design', 'SettingsDesignScreen');
  }

  SettingsTile _themeFactory(String label, ThemeEnum theme) {
    return SettingsTile(
      title: Text(label),
      trailing: _theme == theme ? Icon(CupertinoIcons.check_mark) : null,
      onPressed: (_) {
        setState(() => _theme = theme);
        MainRepository().settings.theme = theme;
        Provider.of<ThemeModel>(context, listen: false).setTheme(theme);
      },
    );
  }

  SettingsTile _skinFactory(String label, SkinEnum skin, {String? description}) {
    return SettingsTile(
      title: Text(label),
      trailing: MainRepository().settings.skin == skin ? Icon(CupertinoIcons.check_mark) : null,
      description: description != null ? Text(description) : null,
      onPressed: (_) {
        MainRepository().settings.skin = skin;
        Provider.of<ThemeModel>(context, listen: false).setSkin(skin);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkinColors colors = Skin.of(context).theme.colors;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            middle: Text(
              L.SETTINGS,
              style: TextStyle(color: colors.text),
            ),
            leading: CupertinoNavigationBarBackButton(
              color: colors.primary,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            )),
        child: CupertinoScrollbar(
            child: SettingsList(
          lightTheme: SettingsThemeData(
              settingsSectionBackground: colors.barBackground,
              settingsListBackground: colors.background,
              settingsTileTextColor: colors.text,
              tileHighlightColor: colors.primary.withOpacity(0.1),
              dividerColor: colors.background),
          sections: [
            SettingsSection(
              title: Text('Barevný režim'),
              tiles: <SettingsTile>[
                _themeFactory('Světlý', ThemeEnum.light),
                _themeFactory('Tmavý', ThemeEnum.dark),
                _themeFactory('Podle systému', ThemeEnum.system),
              ],
            ),
            SettingsSection(
              title: Text('Skin'),
              tiles: Skin.of(context).skins.map((skin) => _skinFactory('${skin.name}${skin.darkMode ? '' : '*'}', skin.id, description: skin.id == SkinEnum.greymatter ? '* nepodporuje 🌗 dark mode.' : null)).toList(),
            ),
            SettingsSection(
              title: Text('Velikost písma'),
              tiles: <SettingsTile>[
                SettingsTile(
                  title: CupertinoSlider(
                    min: 10,
                    max: 24,
                    value: Provider.of<ThemeModel>(context, listen: false).fontSize,
                    onChanged: (double val) {
                      final size = val.round().toDouble();
                      MainRepository().settings.fontSize = size;
                      Provider.of<ThemeModel>(context, listen: false).setFontSize(size);
                    },
                  ),
                  value: SizedBox(
                    width: 20,
                    child: Text(
                      '${Provider.of<ThemeModel>(context, listen: false).fontSize.toInt()}',
                      style: TextStyle(fontSize: Settings().fontSize),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                SettingsTile(
                  title: Text(
                    'Ukázka velikosti textu... 👍',
                    style: TextStyle(fontSize: Provider.of<ThemeModel>(context, listen: false).fontSize),
                    textAlign: TextAlign.center,
                  ),
                ),
                SettingsTile(
                    title: Text('Resetovat', style: TextStyle(color: colors.danger), textAlign: TextAlign.center),
                    onPressed: (_) {
                      MainRepository().settings.fontSize = Settings().fontSize;
                      Provider.of<ThemeModel>(context, listen: false).setFontSize(Settings().fontSize);
                    }),
              ],
            ),
          ],
        )));
  }
}
