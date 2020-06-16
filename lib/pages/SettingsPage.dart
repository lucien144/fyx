import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:fyx/theme/T.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CSWidgetStyle brightnessStyle = const CSWidgetStyle(icon: const Icon(Icons.view_compact, color: Colors.black54));

    return CupertinoTabView(builder: (context) {
      return CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.white,
              middle: Text('Nastavení'),
              leading: CupertinoNavigationBarBackButton(
                color: T.COLOR_PRIMARY,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              )),
          child: CupertinoSettings(items: <Widget>[
            const CSHeader('Příspěvky'),
            CSControl(
              nameWidget: Text('Kompaktní zobrazení'),
              contentWidget: CupertinoSwitch(value: false),
              style: brightnessStyle,
            ),
            CSDescription(
              'Kompaktní zobrazení je zobrazení obrázků po stranách pokud to obsah příspěvku dovoluje (nedojde tak k narušení kontextu).',
            ),
            CSHeader('Úvodní obrazovka'),
            CSSelection<int>(
              items: const <CSSelectionItem<int>>[
                CSSelectionItem<int>(text: 'Historie (vše)', value: 0),
                CSSelectionItem<int>(text: 'Historie (nepřečtené)', value: 1),
                CSSelectionItem<int>(text: 'Sledované (vše)', value: 2),
                CSSelectionItem<int>(text: 'Sledované (nepřečtené)', value: 3),
              ],
              onSelected: (index) {
                print(index);
              },
              currentSelection: 0,
            ),
            const CSHeader(''),
            CSButton(CSButtonType.DEFAULT, "Nahlásit chybu", () {
              print("It works!");
            }),
            CSButton(CSButtonType.DEFAULT, "O aplikaci", () {
              print("It works!");
            }),
            CSButton(CSButtonType.DEFAULT, "Podpořit vývoj", () {
              print("It works!");
            }),
            const CSHeader(''),
            CSButton(CSButtonType.DESTRUCTIVE, "Odhlásit", () {}),
            CSButton(CSButtonType.DESTRUCTIVE, "Odhlásit (bez resetu)", () {}),
            CSDescription(
              'Verze: 0.3.0',
            )
          ]));
    });

    return Container(
      color: Colors.white,
      child: CupertinoSettings(items: <Widget>[
        const CSHeader('Brightness'),
        CSWidget(CupertinoSlider(value: 0.5), style: brightnessStyle),
        CSControl(
          nameWidget: Text('Auto brightness'),
          contentWidget: CupertinoSwitch(value: true),
          style: brightnessStyle,
        ),
        CSHeader('Selection'),
        CSSelection<int>(
          items: const <CSSelectionItem<int>>[
            CSSelectionItem<int>(text: 'Day mode', value: 0),
            CSSelectionItem<int>(text: 'Night mode', value: 1),
          ],
          onSelected: (index) {
            print(index);
          },
          currentSelection: 0,
        ),
        CSDescription(
          'Using Night mode extends battery life on devices with OLED display',
        ),
        const CSHeader(''),
        CSControl(
          nameWidget: Text('Loading...'),
          contentWidget: CupertinoActivityIndicator(),
        ),
        CSButton(CSButtonType.DEFAULT, "Licenses", () {
          print("It works!");
        }),
        const CSHeader(''),
        CSButton(CSButtonType.DESTRUCTIVE, "Delete all data", () {})
      ]),
    );
  }
}
