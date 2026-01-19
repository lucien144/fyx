import 'package:flutter/material.dart';
import 'package:fyx/model/enums/premium_feature_enum.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PremiumFeatureBottomSheet extends StatelessWidget {
  const PremiumFeatureBottomSheet({Key? key, this.feature, this.preview = false}) : super(key: key);
  final PremiumFeatureEnum? feature;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final colors = Skin.of(context).theme.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 24, left: 8, right: 8),
      controller: ModalScrollController.of(context),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 32, top: 32, right: 32, bottom: 48),
        children: [
          if(!preview) Icon(MdiIcons.lock),
          if(!preview) SizedBox(height: 4),
          Text(
            preview ? 'Tyto funkce jsou dostupné pouze podporovatelům Fyxu.' : 'Funkce je dostupná pouze podporovatelům Fyxu.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Text(
            'Nepleťte si s Nyx prémiovkou.\nVíce u ID LUCIEN nebo ve Fyx klubu.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: colors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          if ([null, PremiumFeatureEnum.markdown].contains(feature))
            featureItem(
              icon: MdiIcons.languageMarkdown,
              title: 'Markdown',
              description: 'Pište své příspěvky pomocí Markdownu a využijte tak pokročilé formátování textu.',
            ),
          if ([null, PremiumFeatureEnum.savedSearch].contains(feature))
            featureItem(
              icon: MdiIcons.magnifyPlus,
              title: 'Uložená hledání',
              description: 'Často hledaná slova si nově můžete pro rychlé hledání uložit. Typicky třeba svůj nick.',
            ),
          if ([null, PremiumFeatureEnum.jumpToFirstUnread].contains(feature))
            featureItem(
              icon: MdiIcons.arrowDown,
              title: 'Skok na první nepřečtený',
              description: 'Pokud chcete rychle pokračovat ve čtení diskuzí, skočte na první nepřečtený příspěvek.',
            ),
          if ([null, PremiumFeatureEnum.nsfw].contains(feature))
            featureItem(
              icon: MdiIcons.chiliHot,
              title: 'Peprný obsah',
              description: 'Pokud si označíte diskuzi jako peprnou, zobrazí se vám obrázky rozmazaně.',
            ),
          if ([null, PremiumFeatureEnum.skins].contains(feature))
            featureItem(
              icon: MdiIcons.invertColors,
              title: 'Skiny',
              description: 'Zobrazte si Fyx v různých barevných provedeních podle svého gusta.',
            ),
        ],
      ),
    );
  }

  Widget featureItem({required IconData icon, required String title, required String description}) {
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
                    )),
                Text(
                  description,
                  softWrap: true,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
