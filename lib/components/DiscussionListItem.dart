import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/model/BookmarkedDiscussion.dart';
import 'package:fyx/pages/DiscussionPage.dart';

class DiscussionListItem extends StatelessWidget {
  final BookmarkedDiscussion discussion;

  DiscussionListItem(this.discussion);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: DiscussionPageArguments(discussion.idKlub)),
      child: Container(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: <Widget>[
            discussion.unread == 0
                ? Container(
                    width: 24,
                  )
                : Container(
                    width: 24,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: discussion.replies > 0 ? Colors.red : CupertinoTheme.of(context).primaryColor),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Center(
                        child: AutoSizeText(
                          discussion.unread > 199 ? '∞' : discussion.unread.toString(), //discussion.unread.toString(),
                          maxLines: 1,
                          minFontSize: 1,
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: Text(
              discussion.name,
              overflow: TextOverflow.ellipsis,
            )),
            Visibility(visible: discussion.links > 0, child: Icon(Icons.link)),
            Visibility(visible: discussion.images > 0, child: Icon(Icons.image)),
          ],
        ),
      ),
    );
  }
}
