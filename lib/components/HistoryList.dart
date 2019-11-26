import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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
    return ListView.builder(itemBuilder: (context, position) {
      return Container(
        color: position % 2 == 0 ? CupertinoColors.activeBlue : null,
        child: Column(
          children: <Widget>[
            SizedBox(height: 2,),
            Row(
              children: <Widget>[
                Text(_list[position].jmeno)
              ],
            ),
            SizedBox(height: 2,),
          ],
        ),
      );
    }, itemCount: _list.length,);
  }
}
