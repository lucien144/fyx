import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/model/post/Link.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class PostFooterLink extends StatelessWidget {
  final Link link;

  PostFooterLink(this.link);

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      onTap: () => T.openLink(link.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(color: colors.primaryColor, borderRadius: BorderRadius.circular(4)),
                child: Icon(
                  Icons.link,
                  color: colors.scaffoldBackgroundColor,
                )),
            SizedBox(
              width: 4,
            ),
            Expanded(
                child: Text(
              link.title,
              softWrap: false,
              overflow: TextOverflow.fade,
            ))
          ],
        ),
      ),
    );
  }
}
