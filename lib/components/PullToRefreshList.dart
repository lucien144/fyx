import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:fyx/theme/skin/SkinColors.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:sentry/sentry.dart';
import 'package:fyx/theme/L.dart';
import 'package:fyx/theme/T.dart';

// ignore: must_be_immutable
class PullToRefreshList extends StatefulWidget {
  final TDataProvider dataProvider;
  final Function? sliverListBuilder;
  bool _disabled;
  bool _isInfinite;
  int _rebuild;
  final Widget? pinnedWidget;

  PullToRefreshList(
      {required this.dataProvider, isInfinite = false, int rebuild = 0, this.sliverListBuilder, bool disabled = false, this.pinnedWidget})
      : _isInfinite = isInfinite,
        _rebuild = rebuild,
        _disabled = disabled,
        assert(dataProvider != null);

  @override
  _PullToRefreshListState createState() => _PullToRefreshListState();
}

class _PullToRefreshListState extends State<PullToRefreshList> {
  ScrollController? _controller;
  bool _isLoading = true;
  bool _hasPulledDown = false;
  bool _hasError = false;
  DataProviderResult? _result;
  int? _lastId;
  int? _prevLastId; // ID of last item loaded previously.
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

    () async {
      await Future.delayed(Duration.zero);
      _controller = PrimaryScrollController.of(context);

      if (widget._isInfinite) {
        _controller!.addListener(() {
          // TODO: Refactor, use ScrollNotification ?
          // Display loading and load next page if we are at the end of the list
          if (_controller!.position.userScrollDirection == ScrollDirection.reverse && _controller!.position.outOfRange) {
            if (_slivers.last is! SliverPadding) {
              setState(() => _slivers
                  .add(SliverPadding(padding: EdgeInsets.symmetric(vertical: 16), sliver: SliverToBoxAdapter(child: CupertinoActivityIndicator()))));
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
    }();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    if (widget._rebuild > _lastRebuild && !_isLoading) {
      setState(() => _lastRebuild = widget._rebuild);
      this.loadData();
    }

    if (_hasError) {
      return T.feedbackScreen(context, isLoading: _isLoading, onPress: loadData, label: L.GENERAL_REFRESH);
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
                  backgroundColor: colors.primaryColor,
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
        return <Widget>[widget.sliverListBuilder!(_data)];
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
        _list.add(SliverStickyHeader(
          header: block['header'],
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

    if (!append) {
      // Not using setState on purpose -> we don't want to rebuild the widget tree, it's not needed.
      // TODO: See if this affects performance and if we can do it on other places too.
      _lastId = null;
    }

    // If we try to append the data but the last ID
    // from where we try to load the posts is same as the ID of
    // last item ID loaded previously.
    // Hide the loading indicator and stop.
    if (append && _prevLastId == _lastId) {
      _slivers.removeLast(); // Remove the loading indicator
      setState(() => _isLoading = false);
      return;
    } else {
      // Otherwise save the current last ID for the next loadData() to check
      _prevLastId = _lastId;
    }

    try {
      _result = await widget.dataProvider(append ? _lastId : null);
      bool makeInactive = false;

      // If the ID of the last ID is same as the ID of currently loaded last ID
      // Make the list inactive (makeInactive = true)
      if (_lastId != null && _result!.lastId == _lastId) {
        makeInactive = true;
        if (append) {
          // ... and if also appending, remove the loading indicator
          _slivers.removeLast(); // Remove the loading indicator
        }
      }

      // Load the data only if there are any data AND should not be inactive.
      if (_result!.data.length > 0 && !makeInactive) {
        if (append) {
          _slivers.removeLast(); // Remove the loading indicator
        } else {
          _slivers.removeRange(1, _slivers.length);
        }
        _slivers.addAll(this.buildTheList(_result!.data));
        setState(() => _hasError = false);
        setState(() => _lastId = _result!.lastId);
      }

      // Add the pinned widget only if the list is active
      if (widget.pinnedWidget is Widget && !makeInactive) {
        _slivers.insert(0, SliverToBoxAdapter(child: widget.pinnedWidget));
      }
    } catch (error) {
      setState(() => _hasError = true);

      print('[PullToRefresh error]: $error');
      print(StackTrace.current);
      Sentry.captureException(error);
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
    SkinColors colors = Skin.of(context).theme.colors;
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
                child: CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(colors.primaryColor)),
              ),
      ),
    );
  }
}

class RefreshScrollPhysics extends BouncingScrollPhysics {
  const RefreshScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  RefreshScrollPhysics applyTo(ScrollPhysics? ancestor) {
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

typedef Future<DataProviderResult> TDataProvider(int? id);
