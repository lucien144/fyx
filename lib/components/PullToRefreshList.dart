import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/components/ListItemWithCategory.dart';
import 'package:sticky_headers/sticky_headers.dart';

typedef Future<Response> LoadDataCallbackType();
typedef List<T> ItemBuilderType<T extends ListItemWithCategory>(Response<dynamic> response);
typedef List<H> HeaderBuilderType<H extends ListItemWithCategory>(Response<dynamic> response);

class PullToRefreshList<T extends ListItemWithCategory, H extends ListItemWithCategory> extends StatefulWidget {
  final LoadDataCallbackType loadData;
  final HeaderBuilderType<H> headerBuilder;
  final ItemBuilderType<T> itemBuilder;

  PullToRefreshList({@required this.loadData, this.headerBuilder, this.itemBuilder});

  @override
  _PullToRefreshListState createState() => _PullToRefreshListState<T, H>();
}

class _PullToRefreshListState<T extends ListItemWithCategory, H extends ListItemWithCategory> extends State<PullToRefreshList> {
  List<H> _headers = [];
  List<T> _list = [];
  double _indicatorRadius = 0.1;
  bool _isLoading = false;
  bool _showIndicator = false;
  ScrollController _controller = ScrollController();

  loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var response = await widget.loadData();
      setState(() {
        _list = widget.itemBuilder == null ? [] : widget.itemBuilder(response);
        _headers = widget.headerBuilder == null ? [] : widget.headerBuilder(response);
        _isLoading = false;
      });
    } on DioError catch (error) {
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
    if (_list.length == 0) {
      return CupertinoActivityIndicator(
        radius: 16,
      );
    }

    return ListView.builder(
      controller: _controller,
      itemBuilder: (context, position) {
        // If there are no headers, return list item directly.
        if (_headers.length == 0) {
          if (position == 0) {
            // If we are at the first position, show the refresh indicator.
            return refreshHeader(_list[position]);
          }
          return _list[position];
        }

        return StickyHeader(
            header: position == 0 ? refreshHeader(_headers[position]) : _headers[position],
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(children: _list.where((T item) => item.category == _headers[position].category).toList()),
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