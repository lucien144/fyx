import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/discussion_list_item_base.dart';
import 'package:fyx/model/BookmarkedDiscussion.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class DiscussionListItem extends StatelessWidget {
  final BookmarkedDiscussion discussion;

  DiscussionListItem(this.discussion);

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return DiscussionListItemBase(
        discussionId: this.discussion.idKlub,
        child: Row(
          children: <Widget>[
            discussion.unread == 0
                ? Container(
                    width: 24,
                  )
                : Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: discussion.replies > 0 ? colors.danger : colors.primary),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Center(
                        child: AutoSizeText(
                          discussion.unread > 999 ? '∞' : discussion.unread.toString(), //discussion.unread.toString(),
                          maxFontSize: 12,
                          maxLines: 1,
                          minFontSize: 1,
                          style: TextStyle(color: colors.background, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )),
            SizedBox(
              width: 8,
            ),
            Expanded(child: Text(discussion.name, overflow: TextOverflow.ellipsis)),
            Visibility(visible: discussion.links > 0, child: Icon(Icons.link)),
            Visibility(visible: discussion.images > 0, child: Icon(Icons.image)),
          ],
        ));
  }
}
