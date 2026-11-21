import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fyx/features/app_release/presentation/app_release_post.dart';
import 'package:fyx/features/app_release/presentation/viewmodel/app_release_viewmodel.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/shared/services/analytics/analytics_service.dart';
import 'package:fyx/shared/services/service_locator.dart';
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

  /// Closes the sheet and opens the installed release's post, or the Fyx club.
  void _openChangelog(BuildContext context) {
    final state = getIt<AppReleaseViewModel>().state;
    getIt<AnalyticsService>().logEvent('open_changelog', parameters: {'build': state.currentBuild, 'found': state.installed != null ? 1 : 0});
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed('/discussion', arguments: releasePostArguments(state.installed?.postUrl));
  }

  Widget item({required IconData icon, required String title, required String description, required context, WhatsNewAction? action}) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      onTap: action?.action,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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

    return SafeArea(
      child: ListView(shrinkWrap: true, padding: const EdgeInsets.only(left: 32, top: 32, right: 32, bottom: 48), children: [
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
            icon: MdiIcons.bugOutline,
            title: 'Větší opravy',
            description: 'Hodně menších, ale i větších vylepšení pod kapotou. Videa by již měla fungovat pro fullscreen a být trochu svižnější.',),
        if (Platform.isIOS) item(
            context: context,
            icon: MdiIcons.appsBox,
            title: 'Vlastní ikona',
            description: 'Nice to have - vlastní ikona aplikace. Pouze pro podporovatele a iOS uživatele.',),
        item(
            context: context,
            icon: MdiIcons.themeLightDark,
            title: 'Nový skin: Dracula 🧛‍♂️',
            description: 'Skin známý spíše vývojářům - Dracula / Alucard. Stále WIP.'),
        CupertinoButton(child: Text('Pokračovat', style: TextStyle(color: colors.background),), onPressed: () => Navigator.of(context).pop(), color: colors.primary),
        SizedBox(height: 8),
        CupertinoButton(child: Text('Zobrazit celý changelog'), onPressed: () => _openChangelog(context)),
      ]),
    );
  }
}
