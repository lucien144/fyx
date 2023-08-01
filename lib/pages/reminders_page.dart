import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/discussion_page_scaffold.dart';
import 'package:fyx/components/list_header.dart';
import 'package:fyx/components/post/post_list_item.dart';
import 'package:fyx/components/pull_to_refresh_list.dart';
import 'package:fyx/controllers/AnalyticsProvider.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/pages/DiscussionPage.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  int _refreshData = 0;

  refreshData() {
    setState(() => _refreshData = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void initState() {
    AnalyticsProvider().setScreen('Reminders', 'Reminders');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Skin.of(context).theme.colors;

    return DiscussionPageScaffold(
      title: 'Uložené příspěvky',
      child: PullToRefreshList(
        rebuild: _refreshData,
        isInfinite: true,
        dataProvider: (lastId) async {
          var response = await ApiController().reminders();
          var posts = response.data['posts'] as List;

          List data = posts
              .map((post) => Post.fromJson(post, post['discussion_id'], isCompact: MainRepository().settings.useCompactMode))
              .where((post) => !MainRepository().settings.isPostBlocked(post.id))
              .where((post) => !MainRepository().settings.isUserBlocked(post.nick))
              .map((post) => Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(children: [
                        PostListItem(
                          post,
                          onUpdate: this.refreshData,
                          disabled: true,
                        ),
                        Positioned.fill(
                            child: GestureDetector(
                                onTap: () {
                                  var arguments = DiscussionPageArguments(post.idKlub, postId: post.id + 1);
                                  Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container()))
                      ]),
                      if (post.discussionName != null)
                        GestureDetector(
                          onTap: () {
                            var arguments = DiscussionPageArguments(post.idKlub);
                            Navigator.of(context, rootNavigator: true).pushNamed('/discussion', arguments: arguments);
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(MdiIcons.bookmark, size: 32),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        post.discussionName!,
                                        softWrap: true,
                                        style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                    ],
                  ))
              .toList();

          int? id = posts.length > 0 ? posts.last['id'] : null;
          return DataProviderResult(data, lastId: id);
        },
      ),
    );
  }
}
