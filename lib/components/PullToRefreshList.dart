import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fyx/PlatformTheme.dart';
import 'package:fyx/components/ListItemWithCategory.dart';
import 'package:sticky_headers/sticky_headers.dart';

typedef Future<dynamic> LoadDataCallbackType();
typedef List<T> ItemBuilderType<T extends ListItemWithCategory>(dynamic data);
typedef List<H> HeaderBuilderType<H extends ListItemWithCategory>(dynamic data);

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
  bool _hasError = false;
  bool _isLoading = false;
  bool _showIndicator = false;
  ScrollController _controller = ScrollController();

  loadData() async {
    try {
      setState(() {
        _hasError = false;
        _isLoading = true;
      });
      var data = await widget.loadData();
      setState(() {
        _list = widget.itemBuilder == null ? [] : widget.itemBuilder(data);
        _headers = widget.headerBuilder == null ? [] : widget.headerBuilder(data);
        _isLoading = false;
      });
    } catch (error) {
      PlatformTheme.error(error.toString());
      setState(() {
        _hasError = true;
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
          loadData();
          _showIndicator = true;
        });
      }

      if (_controller.position.pixels >= treshold && _showIndicator && !_isLoading) {
        setState(() {
          _showIndicator = false;
        });
      }
    });

    loadData();
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
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Visibility(
            visible: !_hasError,
            child: CupertinoActivityIndicator(
              radius: 16,
            ),
          ),
          Visibility(
            visible: _hasError,
            child: CupertinoButton(
              color: Colors.black26,
              child: Text('Načíst znovu...'),
              onPressed: () {
                loadData();
              },
            ),
          )
        ],
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
