import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class DataProviderResult {
  final List data;
  final dynamic lastId;

  DataProviderResult(this.data, {this.lastId});
}

typedef Future<DataProviderResult> TDataProvider(dynamic id);

class PullToRefreshList extends StatefulWidget {
  final TDataProvider dataProvider;
  bool _isInfinite;

  PullToRefreshList({@required this.dataProvider, isInfinite = false})
      : _isInfinite = isInfinite,
        assert(dataProvider != null);

  @override
  _PullToRefreshListState createState() => _PullToRefreshListState();
}

class _PullToRefreshListState extends State<PullToRefreshList> {
  ScrollController _controller = ScrollController();
  bool _isLoading = true;
  bool _hasError = false;
  DataProviderResult _result;
  int _lastId;
  var _slivers = <Widget>[];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget._isInfinite) {
      _controller.addListener(() {
        // Display loading and load next page if we are at the end of the list
        if (_controller.position.userScrollDirection == ScrollDirection.reverse && _controller.position.outOfRange) {
          if (_slivers.last is! SliverPadding) {
            setState(() => _slivers.add(SliverPadding(padding: EdgeInsets.symmetric(vertical: 16), sliver: SliverToBoxAdapter(child: CupertinoActivityIndicator()))));
            this.appendData();
          }
        }
      });
    }

    // Add the refresh control on first position
    _slivers.add(CupertinoSliverRefreshControl(
      onRefresh: () => this.initData(),
    ));

    this.initData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _hasError
        ? errorScreen()
        : CustomScrollView(
            slivers: _slivers,
            controller: _controller,
          );
  }

  List<Widget> buildTheList(List _data) {
    if (_data.first is Widget) {
      return [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => _data[i],
            childCount: _data.length,
          ),
        )
      ];
    }

    if (_data.first is Map && (_data.first as Map).containsKey('header')) {
      List<Widget> _list = [];

      _data.cast<Map>().forEach((block) {
        _list.add(SliverStickyHeaderBuilder(
          builder: (context, state) => block['header'],
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => block['items'][i],
              childCount: block['items'].length,
            ),
          ),
        ));
      });

      return _list;
    }

    throw Exception('Data in the PullToRefresh must be instance of Widget or Map{header, items}');
  }

  Widget errorScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Visibility(
          visible: _isLoading,
          child: CupertinoActivityIndicator(
            radius: 16,
          ),
        ),
        Visibility(
          visible: !_isLoading,
          child: CupertinoButton(
            color: Colors.black26,
            child: Text('Načíst znovu...'),
            onPressed: () => initData(),
          ),
        )
      ],
    );
  }

  initData() async {
    setState(() => _isLoading = true);

    try {
      _result = await widget.dataProvider(null);
      if (_result.data.length > 0) {
        _slivers.removeRange(1, _slivers.length);
        _slivers.addAll(this.buildTheList(_result.data));
        setState(() => _hasError = false);
        setState(() => _lastId = _result.lastId);
      } else {
        setState(() => _hasError = true);
      }
    } catch (error) {
      print(error);
      print(StackTrace.current);
      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  appendData() async {
    setState(() => _isLoading = true);

    try {
      _result = await widget.dataProvider(_lastId);
      if (_result.data.length > 0) {
        _slivers.removeLast(); // Remove the loading indicator
        _slivers.addAll(this.buildTheList(_result.data));
        setState(() => _hasError = false);
        setState(() => _lastId = _result.lastId);
      } else {
        setState(() => _hasError = true);
      }
    } catch (error) {
      print(error);
      print(StackTrace.current);
      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
