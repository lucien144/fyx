import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/model/BookmarkedDiscussion.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class DiscussionListItem extends StatelessWidget {
  final BookmarkedDiscussion discussion;

  DiscussionListItem(this.discussion);

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: DiscussionPageArguments(discussion.idKlub)),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.greyColor.withOpacity(.12)))),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: <Widget>[
            discussion.unread == 0
                ? Container(
                    width: 24,
                  )
                : Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: discussion.replies > 0 ? colors.dangerColor : colors.primaryColor),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Center(
                        child: AutoSizeText(
                          discussion.unread > 999 ? '∞' : discussion.unread.toString(), //discussion.unread.toString(),
                          maxFontSize: 12,
                          maxLines: 1,
                          minFontSize: 1,
                          style: TextStyle(color: CupertinoTheme.of(context).scaffoldBackgroundColor, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: Text(
              discussion.name,
              overflow: TextOverflow.ellipsis
            )),
            Visibility(visible: discussion.links > 0, child: Icon(Icons.link)),
            Visibility(visible: discussion.images > 0, child: Icon(Icons.image)),
          ],
        ),
      ),
    );
  }
}
