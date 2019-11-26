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

  loadHistory() async {
    var response = await Dio().get('http://localhost/lucien144/fyx/assets/json/bookmarks.history.json');
    setState(() {
      _list = (response.data['data']['discussions'] as List).map((discussion) => Discussion.fromJson(discussion)).toList();
    });
  }


  @override
  void initState() {
    loadHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, position) => DiscussionListItem(_list[position]), itemCount: _list.length,);
  }
}
