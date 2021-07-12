import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/CircleAvatar.dart' as component;
import 'package:fyx/components/ContentBoxLayout.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/post/content/Regular.dart';
import 'package:fyx/model/reponses/FeedNoticesResponse.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/theme/Helpers.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';

class NoticesPage extends StatefulWidget {
  NoticesPage({Key key}) : super(key: key);

  @override
  _NoticesPageState createState() => _NoticesPageState();
}

class _NoticesPageState extends State<NoticesPage> with WidgetsBindingObserver {
  int _refreshData = 0;

  refresh() {
    setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AnalyticsProvider().setScreen('Notices', 'NoticesPage');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && ModalRoute.of(context).isCurrent) {
      this.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
            backgroundColor: Colors.white,
            middle: Text(L.NOTICES),
            leading: CupertinoNavigationBarBackButton(
              color: T.COLOR_PRIMARY,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            )),
        child: PullToRefreshList(
            rebuild: _refreshData,
            dataProvider: (lastId) async {
              var result = await ApiController().loadFeedNotices();
              var feed = result.data.map((NoticeItem item) {
                var highlight = false;
                item.replies.forEach((NoticeReplies reply) => highlight = reply.time > result.lastVisit ? true : highlight);
                item.thumbsUp.forEach((NoticeThumbsUp thumbUp) => highlight = thumbUp.time > result.lastVisit ? true : highlight);

                return ContentBoxLayout(
                  onTap: () => Navigator.of(context).pushNamed('/discussion', arguments: DiscussionPageArguments(item.idKlub, postId: item.idWu + 1)),
                  content: ContentRegular(item.content),
                  isHighlighted: highlight,
                  topRightWidget: Text(
                    item.wuRating > 0 ? '+${item.wuRating}' : item.wuRating.toString(),
                    style: TextStyle(fontSize: 14, color: item.wuRating > 0 ? Colors.green : (item.wuRating < 0 ? Colors.redAccent : Colors.black38)),
                  ),
                  topLeftWidget: Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/discussion', arguments: DiscussionPageArguments(item.idKlub)),
                      child: Text(
                        item.discussionName,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  bottomWidget: Column(
                    children: [
                      if (item.thumbsUp.length > 0) buildLikes(context, item.thumbsUp, result.lastVisit),
                      SizedBox(
                        height: 8,
                      ),
                      if (item.replies.length > 0) buildReplies(context, item.replies, result.lastVisit),
                    ],
                  ),
                );
              }).toList();
              return DataProviderResult(feed);
            }));
  }

  Widget buildLikes(BuildContext context, List<NoticeThumbsUp> thumbsUp, int lastVisit) {
    var avatars = thumbsUp
        .map((thumbUp) => Tooltip(
              message: thumbUp.nick,
              waitDuration: Duration(milliseconds: 0),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 5),
                child: component.CircleAvatar(
                  Helpers.avatarUrl(thumbUp.nick),
                  size: 22,
                  isHighlighted: thumbUp.time > lastVisit,
                ),
              ),
            ))
        .toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(
            Icons.thumb_up,
            size: 22,
          ),
        ),
        Expanded(
          child: Wrap(children: avatars),
        )
      ],
    );
  }

  Widget buildReplies(BuildContext context, List<NoticeReplies> replies, int lastVisit) {
    List<Widget> replyRows = replies.map((reply) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/discussion', arguments: DiscussionPageArguments(reply.idKlub, postId: reply.idWu + 1)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 5,
              ),
              component.CircleAvatar(
                Helpers.avatarUrl(reply.nick),
                size: 22,
                isHighlighted: reply.time > lastVisit,
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(Helpers.stripHtmlTags(reply.text), style: TextStyle(fontSize: 14, fontWeight: reply.time > lastVisit ? FontWeight.bold : FontWeight.normal)),
              ))
            ],
          ),
        ),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.reply_rounded, size: 22),
        Expanded(
          child: Column(
            children: replyRows,
          ),
        )
      ],
    );
  }
}
