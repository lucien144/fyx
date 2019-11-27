import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/model/Discussion.dart';

class HistoryList extends StatefulWidget {
  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  List<Discussion> _list = [];
  bool _isLoading = false;
  bool _showIndicator = false;
  ScrollController _controller = ScrollController();

  loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    var response = await Dio().get('http://localhost/lucien144/fyx/assets/json/bookmarks.history.json');
    setState(() {
      _list = (response.data['data']['discussions'] as List).map((discussion) => Discussion.fromJson(discussion)).toList();
      _isLoading = false;
    });
  }

  @override
  void initState() {
    loadHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _controller.addListener(() {
      if (_controller.position.pixels < -10) {
        setState(() {
          _showIndicator = true;
        });
      } else {
        setState(() {
          _showIndicator = false;
        });
      }
    });

    return ListView.builder(
      controller: _controller,
      itemBuilder: (context, position) {
        return position == 0
            ? Visibility(
                visible: _showIndicator,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CupertinoActivityIndicator(),
                ))
            : DiscussionListItem(_list[position - 1]);
      },
      itemCount: _list.length + 1,
    );
  }
}
