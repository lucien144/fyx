import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/avatar.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BottomTabBar extends StatefulWidget {
  final List items;
  final ValueChanged<int>? onTap;
  final bool activeSubmenu;

  const BottomTabBar({Key? key, required this.items, this.onTap, this.activeSubmenu = false}) : super(key: key);

  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  final submenuKey = GlobalKey();
  late SkinColors colors;
  bool _activeSubmenu = false;

  @override
  void initState() {
    _activeSubmenu = widget.activeSubmenu;
    super.initState();
  }

  Widget submenu() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        color: CupertinoTheme.of(context).barBackgroundColor,
        boxShadow: [
          BoxShadow(
              color: colors.grey.withOpacity(0.4), //New
              blurRadius: 15.0,
              offset: Offset(0, 0))
        ],
      ),
      key: submenuKey,
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 375 ? 20 : 40),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Avatar(MainRepository().credentials!.avatar, size: 24),
                const SizedBox(width: 4),
                Text(
                  'Fyxbot'.toUpperCase(),
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/discussion', arguments: DiscussionPageArguments(24237)),
              behavior: HitTestBehavior.translucent,
              child: Container(
                padding: EdgeInsets.all(2),
                child: Row(
                  children: [
                    Icon(
                      MdiIcons.bullhornOutline,
                      color: colors.text,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sleduj vývoj Fyxu',
                      style: TextStyle(fontSize: 12),
                    )
                  ],
                ),
              ),
            )
          ]),
          const SizedBox(height: 8),
          Divider(
            color: colors.grey,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Opacity(
                  opacity: .35,
                  child: GestureDetector(
                      child: Column(
                    children: [
                      Icon(MdiIcons.flashOutline, size: 34, color: colors.grey),
                      Text(
                        'Poslední',
                        style: TextStyle(fontSize: 11, color: colors.grey),
                      )
                    ],
                  )),
                ),
              ),
              Expanded(
                  child: Opacity(
                opacity: .35,
                child: GestureDetector(
                    child: Column(
                  children: [
                    Icon(MdiIcons.pinOutline, size: 34, color: colors.grey),
                    Text(
                      'Uložené',
                      style: TextStyle(fontSize: 11, color: colors.grey),
                    )
                  ],
                )),
              )),
              Expanded(
                  child: Opacity(
                opacity: .35,
                child: GestureDetector(
                    child: Column(
                  children: [
                    Icon(MdiIcons.magnify, size: 34, color: colors.grey),
                    Text(
                      'Hledání',
                      style: TextStyle(fontSize: 11, color: colors.grey),
                    )
                  ],
                )),
              )),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/discussion', arguments: DiscussionPageArguments(17067)),
                      child: Column(
                        children: [
                          Icon(MdiIcons.shoppingOutline, size: 34, color: colors.grey),
                          Text(
                            'Tržiště',
                            style: TextStyle(fontSize: 11, color: colors.grey),
                          )
                        ],
                      ))),
              Expanded(
                  child: GestureDetector(
                      onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/settings'),
                      child: Column(
                        children: [
                          Icon(MdiIcons.cogOutline, size: 34, color: colors.grey),
                          Text(
                            L.SETTINGS,
                            style: TextStyle(fontSize: 11, color: colors.grey),
                          )
                        ],
                      ))),
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        T.prefillGithubIssue(appContext: MainRepository(), user: MainRepository().credentials!.nickname);
                        AnalyticsProvider().logEvent('reportBug');
                      },
                      child: Column(
                        children: [
                          Icon(MdiIcons.bugOutline, size: 34, color: colors.grey),
                          Text(
                            'Nahlásit chybu',
                            style: TextStyle(fontSize: 11, color: colors.grey),
                          )
                        ],
                      ))),
            ],
          )
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (oldWidget.activeSubmenu != widget.activeSubmenu) {
      setState(() => _activeSubmenu = widget.activeSubmenu);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    colors = Skin.of(context).theme.colors;
    double submenuHeight = MediaQuery.of(context).size.height / 2;

    final box = submenuKey.currentContext?.findRenderObject();
    submenuHeight = box is RenderBox ? box.size.height : submenuHeight;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AnimatedPositioned(
          curve: Curves.linearToEaseOut,
          duration: Duration(milliseconds: 300),
          bottom: _activeSubmenu ? 50 + bottomPadding : -submenuHeight,
          left: 0,
          right: 0,
          child: AnimatedOpacity(
            opacity: _activeSubmenu ? 1 : 0,
            curve: Curves.linearToEaseOut,
            duration: Duration(milliseconds: 200),
            child: submenu(),
          ),
        ),
        DecoratedBox(
            decoration: BoxDecoration(color: CupertinoTheme.of(context).barBackgroundColor),
            child: SizedBox(
                height: 50 + bottomPadding, // Standard iOS 10 tab bar height.
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(
                        widget.items.length,
                        (i) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.onTap == null
                                ? null
                                : () {
                                    widget.onTap!(i);
                                  },
                            child: Padding(
                              padding: EdgeInsets.only(bottom: bottomPadding),
                              child: widget.items[i],
                            ))))))
      ],
    );
  }
}
