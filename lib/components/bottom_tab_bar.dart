import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomTabBar extends StatefulWidget {
  final List items;
  final ValueChanged<int>? onTap;

  const BottomTabBar({Key? key, required this.items, this.onTap}) : super(key: key);

  @override
  _BottomTabBarState createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return DecoratedBox(
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
                            )))))));
  }
}
