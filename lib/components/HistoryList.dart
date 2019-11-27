import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/model/Category.dart';
import 'package:fyx/model/Discussion.dart';

class HistoryList extends StatefulWidget {
  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  List<Category> _headers = [];
  List<Discussion> _list = [];
  bool _isLoading = false;
  bool _showIndicator = false;
  ScrollController _controller = ScrollController();

  loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var response = await Dio().get('http://localhost/lucien144/fyx/assets/json/bookmarks.all.json');
      setState(() {
        _list = (response.data['data']['discussions'] as List).map((discussion) => Discussion.fromJson(discussion)).toList();
        _headers = [];
        if ((response.data['data'] as Map).containsKey('categories')) {
          _headers = (response.data['data']['categories'] as List).map((category) => Category.fromJson(category)).toList();
        }
        _isLoading = false;
      });
    } catch (error) {
      // TODO: Show error
      print(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    const treshold = -10;

    _controller.addListener(() {
      if (_controller.position.pixels < treshold && !_showIndicator) {
        setState(() {
          loadHistory();
          _showIndicator = true;
        });
      }

      if (_controller.position.pixels >= treshold && _showIndicator && !_isLoading) {
        setState(() {
          _showIndicator = false;
        });
      }
    });

    loadHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemBuilder: (context, position) {
        if (position == 0) {
          return Column(
            children: <Widget>[
              Visibility(
                  visible: _showIndicator,
                  child: CupertinoActivityIndicator(
                    animating: true,
                  )),
              DiscussionListItem(_list[position]),
            ],
          );
        }
        return DiscussionListItem(_list[position]);
      },
      itemCount: _list.length,
    );
  }
}
