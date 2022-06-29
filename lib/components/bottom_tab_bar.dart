import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

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
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: .3,
                  child: GestureDetector(
                      child: Column(
                    children: [
                      Icon(Icons.hourglass_top, size: 34, color: CupertinoColors.inactiveGray),
                      Text(
                        'Poslední',
                        style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
                      )
                    ],
                  )),
                ),
              ),
              Expanded(
                  child: Opacity(
                opacity: .3,
                child: GestureDetector(
                    child: Column(
                  children: [
                    Icon(Icons.shopping_cart, size: 34, color: CupertinoColors.inactiveGray),
                    Text(
                      'Tržiště',
                      style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
                    )
                  ],
                )),
              )),
              Expanded(
                  child: Opacity(
                opacity: .3,
                child: GestureDetector(
                    child: Column(
                  children: [
                    Icon(Icons.search, size: 34, color: CupertinoColors.inactiveGray),
                    Text(
                      'Hledání',
                      style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
                    )
                  ],
                )),
              )),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            children: [
              Expanded(
                  child: Opacity(
                opacity: .3,
                child: GestureDetector(
                    child: Column(
                  children: [
                    Icon(Icons.bookmark, size: 34, color: CupertinoColors.inactiveGray),
                    Text(
                      'Uložené',
                      style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
                    )
                  ],
                )),
              )),
              Expanded(
                  child: GestureDetector(
                      onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/settings'),
                      child: Column(
                        children: [
                          Icon(Icons.settings, size: 34, color: CupertinoColors.inactiveGray),
                          Text(
                            'Nastavení',
                            style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
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
                          Icon(Icons.report, size: 34, color: CupertinoColors.inactiveGray),
                          Text(
                            'Nahlásit chybu',
                            style: TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
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
                    children: List.generate(
                        widget.items.length,
                        (i) => Expanded(
                            child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: widget.onTap == null
                                    ? null
                                    : () {
                                        widget.onTap!(i);
                                      },
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: bottomPadding),
                                  child: widget.items[i],
                                )))))))
      ],
    );
  }
}
