import 'package:flutter/cupertino.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/search_page.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class WhatsNewAction {
  final VoidCallback action;
  final String label;

  WhatsNewAction({required this.action, required this.label});
}

class WhatsNew extends StatelessWidget {
  const WhatsNew({Key? key}) : super(key: key);

  Widget item({required IconData icon, required String title, required String description, required context, WhatsNewAction? action}) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      onTap: action?.action,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Row(
          children: [
            Icon(icon, size: 40),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      )),
                  Text(
                    description,
                    softWrap: true,
                  ),
                  if (action != null)
                    Text(
                      action.label,
                      style: TextStyle(color: colors.primary, decoration: TextDecoration.underline),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;
    var pkg = MainRepository().packageInfo;
    var version = '${pkg.version} (${pkg.buildNumber})';

    return ListView(shrinkWrap: true, padding: const EdgeInsets.only(left: 32, top: 32, right: 32, bottom: 48), children: [
      Text(
        'Co je nového?',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 4),
      Text(
        'Verze $version',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13),
      ),
      SizedBox(height: 24),
      item(
          context: context,
          icon: MdiIcons.select,
          title: 'Výběr textu',
          description: 'Dlouho požadovaná funkce je zde: nyní je možné vybrat text příspěvku pouze označením jeho textu!'),
      item(
          context: context,
          icon: MdiIcons.magnifyPlus,
          title: 'Uložená hledání',
          description: 'Často hledaná slova si nově můžete pro rychlé hledání uložit. Typicky třeba svůj nick.'),
      item(
          context: context,
          icon: MdiIcons.themeLightDark,
          title: 'Nový skin: Dark',
          description: 'Přidal jsem další klasický skin, který znáte z Nyxu - Dark.'),
      CupertinoButton(child: Text('Pokračovat', style: TextStyle(color: colors.background),), onPressed: () => Navigator.of(context).pop(), color: colors.primary)
    ]);
  }
}
