import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fyx/components/PullToRefreshList.dart';
import 'package:fyx/components/post/PostListItem.dart';
import 'package:fyx/controllers/ApiController.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:fyx/model/Post.dart';
import 'package:fyx/pages/NewMessagePage.dart';
import 'package:fyx/theme/T.dart';

class DiscussionPage extends StatefulWidget {
  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> with WidgetsBindingObserver {
  int _refreshList = 0;

  refresh() {
    setState(() => _refreshList = DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      this.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Discussion discussion = ModalRoute.of(context).settings.arguments;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        previousPageTitle: 'as',
        leading: CupertinoNavigationBarBackButton(
          color: T.COLOR_PRIMARY,
        ),
        middle: Text(discussion.jmeno, overflow: TextOverflow.ellipsis),
      ),
      child: Stack(
        children: [
          PullToRefreshList(
            rebuild: _refreshList,
            isInfinite: true,
            dataProvider: (lastId) async {
              var result = await ApiController().loadDiscussion(discussion.idKlub, lastId: lastId);
              var data = (result as List).map((post) => PostListItem(Post.fromJson(post, discussion.idKlub), onUpdate: this.refresh)).toList();
              var id = Post.fromJson((result as List).last, discussion.idKlub).id;
              return DataProviderResult(data, lastId: id);
            },
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: SafeArea(
              child: FloatingActionButton(
                backgroundColor: T.COLOR_PRIMARY,
                child: Icon(Icons.add),
                onPressed: () => Navigator.of(context).pushNamed('/discussion/new-message', arguments: NewMessageSettings(discussion.idKlub, onClose: this.refresh)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
