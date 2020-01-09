import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

typedef Future<List> TDataProvider();

class PullToRefreshList extends StatefulWidget {
  final TDataProvider dataProvider;

  PullToRefreshList({@required this.dataProvider});

  @override
  _PullToRefreshListState createState() => _PullToRefreshListState();
}

class _PullToRefreshListState extends State<PullToRefreshList> {
  var isLoading = true;
  var hasError = false;
  var data = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    var slivers = <Widget>[];

    // Add the refresh control on first position
    slivers.add(CupertinoSliverRefreshControl(
      onRefresh: () => this.loadData(),
    ));

    if (data.length > 0) {
      slivers.addAll(this.buildTheList(data));
    } else {
      slivers.add(SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: !hasError,
              child: CupertinoActivityIndicator(
                radius: 16,
              ),
            ),
            Visibility(
              visible: hasError,
              child: CupertinoButton(
                color: Colors.black26,
                child: Text('Načíst znovu...'),
                onPressed: () {
                  loadData();
                },
              ),
            )
          ],
        ),
      ));
    }

    return CustomScrollView(
      slivers: slivers,
    );
  }

  List<Widget> buildTheList(List data) {
    if (data.first is Widget) {
      return [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) => data[i],
            childCount: data.length,
          ),
        )
      ];
    }

    if (data.first is Map && (data.first as Map).containsKey('header')) {
      List<Widget> _list = [];

      data.cast<Map>().forEach((block) {
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

  loadData() async {
    this.resetState();
    try {
      data = await widget.dataProvider();
    } catch (error) {
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  resetState() {
    setState(() {
      isLoading = true;
      hasError = false;
    });
  }

  @override
  void initState() {
    this.loadData();
    super.initState();
  }
}
