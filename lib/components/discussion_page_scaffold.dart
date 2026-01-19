import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/theme/skin/Skin.dart';

class DiscussionPageScaffold extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  const DiscussionPageScaffold({Key? key, required this.title, required this.child, this.trailing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Skin.of(context).theme.colors;
    final width = MediaQuery.sizeOf(context).width;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          leading: CupertinoNavigationBarBackButton(
            color: colors.primary,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          middle: Container(
              alignment: Alignment.center,
              width: width - 120,
              child: Tooltip(
                message: title,
                child: Text(
                    // https://github.com/flutter/flutter/issues/18761
                    Characters(title).replaceAll(Characters(''), Characters('\u{200B}')).toString(),
                    style: TextStyle(color: colors.text),
                    overflow: TextOverflow.ellipsis),
                padding: EdgeInsets.all(8.0), // needed until https://github.com/flutter/flutter/issues/86170 is fixed
                margin: EdgeInsets.all(8.0),
                showDuration: Duration(seconds: 3),
              )),
          trailing: this.trailing),
      child: this.child,
    );
  }
}
