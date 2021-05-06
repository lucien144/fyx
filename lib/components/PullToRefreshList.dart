import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:fyx/model/MainRepository.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';

// ignore: must_be_immutable
class PullToRefreshList extends StatefulWidget {
  final TDataProvider dataProvider;
  Function sliverListBuilder;
  bool _disabled;
  bool _isInfinite;
  int _rebuild;
  final Widget pinnedWidget;

  PullToRefreshList({@required this.dataProvider, isInfinite = false, int rebuild = 0, this.sliverListBuilder, bool disabled = false, this.pinnedWidget})
      : _isInfinite = isInfinite,
        _rebuild = rebuild,
        _disabled = disabled,
        assert(dataProvider != null);

  @override
  _PullToRefreshListState createState() => _PullToRefreshListState();
}

class _PullToRefreshListState extends State<PullToRefreshList> {
  ScrollController _controller = ScrollController();
  bool _isLoading = true;
  bool _hasPulledDown = false;
  bool _hasError = false;
  DataProviderResult _result;
  int _lastId;
  var _slivers = <Widget>[];
  int _lastRebuild = 0;

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
        // TODO: Refactor, use ScrollNotification ?
        // Display loading and load next page if we are at the end of the list
        if (_controller.position.userScrollDirection == ScrollDirection.reverse && _controller.position.outOfRange) {
          if (_slivers.last is! SliverPadding) {
            setState(() => _slivers.add(SliverPadding(padding: EdgeInsets.symmetric(vertical: 16), sliver: SliverToBoxAdapter(child: CupertinoActivityIndicator()))));
            this.loadData(append: true);
          }
        }
      });
    }

    // Add the refresh control on first position
    _slivers.add(CupertinoSliverRefreshControl(
      builder: Platform.isIOS ? CupertinoSliverRefreshControl.buildRefreshIndicator : buildAndroidRefreshIndicator,
      onRefresh: () {
        setState(() => _hasPulledDown = true);
        if (!widget._disabled) {
          return this.loadData();
        }
        return Future.wait([]);
      },
    ));

    this.loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget._rebuild > _lastRebuild && !_isLoading) {
      setState(() => _lastRebuild = widget._rebuild);
      this.loadData();
    }

    if (_hasError) {
      return T.feedbackScreen(isLoading: _isLoading, onPress: loadData, label: L.GENERAL_REFRESH);
    }

    if (_slivers.length == 1 && !_isLoading) {
      return Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(),
            Text(
              L.GENERAL_EMPTY,
              textAlign: TextAlign.center,
            ),
            Image.asset('travolta.gif')
          ],
        ),
      );
    }

    return CupertinoScrollbar(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: Platform.isIOS ? const AlwaysScrollableScrollPhysics() : const RefreshScrollPhysics(),
                  slivers: _slivers,
                  controller: _controller,
                ),
              ),
            ],
          ),
          Visibility(
            visible: _isLoading && !_hasPulledDown, // Show only when not pulling down the list
            child: Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                child: LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  backgroundColor: T.COLOR_PRIMARY,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> buildTheList(List _data) {
    // If the list contains widgets
    if (_data.first is Widget) {
      if (widget.sliverListBuilder is Function) {
        return <Widget>[widget.sliverListBuilder(_data)];
      } else {
        return [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _data[i],
              childCount: _data.length,
            ),
          )
        ];
      }
    }

    // If the list contains category headers
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

  loadData({bool append = false}) async {
    setState(() => _isLoading = true);

    try {
      _result = await widget.dataProvider(append ? _lastId : null);
      if (_result.data.length > 0) {
        if (append) {
          _slivers.removeLast(); // Remove the loading indicator
        } else {
          _slivers.removeRange(1, _slivers.length);
        }
        _slivers.addAll(this.buildTheList(_result.data));
        setState(() => _hasError = false);
        setState(() => _lastId = _result.lastId);
      }

      if (widget.pinnedWidget is Widget) {
        _slivers.insert(0, SliverToBoxAdapter(child: widget.pinnedWidget));
      }
    } catch (error) {
      setState(() => _hasError = true);

      print('[PullToRefresh error]: $error');
      print(StackTrace.current);
      MainRepository().sentry.captureException(exception: error);
    } finally {
      setState(() {
        _hasPulledDown = false;
        _isLoading = false;
      });
    }
  }

  Widget buildAndroidRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    const Curve opacityCurve = const Interval(0.4, 0.8, curve: Curves.easeInOut);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: refreshState == RefreshIndicatorMode.drag
            ? Opacity(
                opacity: opacityCurve.transform(min(pulledExtent / refreshTriggerPullDistance, 1.0)),
                child: const Icon(
                  Icons.arrow_downward,
                  color: CupertinoColors.inactiveGray,
                  size: 24.0,
                ),
              )
            : Opacity(
                opacity: opacityCurve.transform(min(pulledExtent / refreshIndicatorExtent, 1.0)),
                child: CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(T.COLOR_PRIMARY)),
              ),
      ),
    );
  }
}

class RefreshScrollPhysics extends BouncingScrollPhysics {
  const RefreshScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  RefreshScrollPhysics applyTo(ScrollPhysics ancestor) {
    return RefreshScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    return true;
  }
}

class DataProviderResult {
  final List data;
  final dynamic lastId;

  DataProviderResult(this.data, {this.lastId});
}

typedef Future<DataProviderResult> TDataProvider(int id);
