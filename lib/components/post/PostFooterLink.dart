import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/model/post/Link.dart';

class PostFooterLink extends StatelessWidget {
  final Link link;

  PostFooterLink(this.link);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PlatformTheme.openLink(link.url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(color: PlatformTheme.of(context).primaryColor, borderRadius: BorderRadius.circular(4)),
                child: Icon(
                  Icons.link,
                  color: Colors.white,
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
