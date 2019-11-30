import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/DiscussionListItem.dart';
import 'package:fyx/components/ListHeader.dart';
import 'package:fyx/model/Category.dart';
import 'package:fyx/model/Discussion.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HistoryList extends StatefulWidget {
  String dataUrl;

  HistoryList({@required this.dataUrl});

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  List<Category> _headers = [];
  List<Discussion> _list = [];
  double _indicatorRadius = 0.1;
  bool _isLoading = false;
  bool _showIndicator = false;
  ScrollController _controller = ScrollController();

  loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var response = await Dio().get(widget.dataUrl);
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
    const treshold = -1;

    _controller.addListener(() {
      setState(() {
        var radius = _controller.position.pixels.abs();
        radius = radius == 0 ? 0.1 : radius;
        radius = radius > 20 ? 20 : radius;
        _indicatorRadius = radius;
      });

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemBuilder: (context, position) {
        if (_headers.length == 0) {
          if (position == 0) {
            return refreshHeader(DiscussionListItem(_list[position]));
          }
          return DiscussionListItem(_list[position]);
        }

        return StickyHeader(
            header: position == 0
                ? refreshHeader(ListHeader(
                    title: _headers[position].jmeno,
                  ))
                : ListHeader(
                    title: _headers[position].jmeno,
                  ),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(children: _list.where((discussion) => discussion.idCat == _headers[position].idCat).map((discussion) => DiscussionListItem(discussion)).toList()),
            ));
      },
      itemCount: _headers.length == 0 ? _list.length : _headers.length,
    );
  }

  Widget refreshHeader(Widget item) {
    return Column(
      children: <Widget>[
        Visibility(
            visible: _showIndicator,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoActivityIndicator(
                radius: _indicatorRadius,
                animating: true,
              ),
            )),
        item,
      ],
    );
  }
}
