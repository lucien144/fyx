import 'package:flutter/widgets.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class WhatsNew extends StatelessWidget {
  const WhatsNew({Key? key}) : super(key: key);

  Widget item({required IconData icon, required String title, required String description, required context}) {
    SkinColors colors = Skin.of(context).theme.colors;

    return Padding(
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
                      color: colors.primary
                    )),
                Text(
                  description,
                  softWrap: true,
                )
              ],
            ),
          )
        ],
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
          color: colors.primary,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 4),
      Text(
        'Verze $version',
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.primary, fontFamily: 'JetBrainsMono', fontSize: 13),
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
          description: 'Nově lze hledat ve všech příspěvcích napříč Nyxem. Funkce je dostupná z hlavního menu.'),
      item(
          context: context,
          icon: MdiIcons.bug,
          title: 'Opravy.',
          description: 'Krátký spoiler, odpověď na inzerát, otevírání odkazů, indikace přečteno v poště, možnost zobrazení výsledků ankety, indikátor galerie a další...'),
    ]);
  }
}
