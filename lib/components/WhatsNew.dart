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
          icon: MdiIcons.imageAlbum,
          title: 'Změny v galerii.',
          description: 'Galerie se nově zavírá zahozením obrázku. Zoom by měl fungovat lépe. Na klik se schovají vešekré UI elementy.'),
      item(
          context: context,
          icon: MdiIcons.magnify,
          title: 'Fulltextové hledání.',
          description: 'Další novinkou je fulltextové hledání příspěvků napříč Nyxem. Hledání je dostupné z hlavního menu.',
          action: new WhatsNewAction(action: () {
            Navigator.of(context).pop();
            var arguments = SearchPageArguments(searchTerm: 'fyx');
            Navigator.of(context, rootNavigator: true).pushNamed('/search', arguments: arguments);
          }, label: 'Chci si vyzkoušet hledání.')),
      item(
          context: context,
          icon: MdiIcons.bug,
          title: 'Opravy a drobná vylepšení.',
          description:
              'Nehlasovat v anketě, neresetovat hodnocení při mínusu, krátký spoiler, ikona přečteno v pošte, odpověď na inzerát a další...'),
      CupertinoButton(child: Text('Pokračovat'), onPressed: () => Navigator.of(context).pop(), color: colors.primary)
    ]);
  }
}
