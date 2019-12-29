import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef Future<List> TDataProvider();

class PullToRefreshNew extends StatefulWidget {
  final TDataProvider dataProvider;

  PullToRefreshNew({@required this.dataProvider});

  @override
  _PullToRefreshNewState createState() => _PullToRefreshNewState();
}

class _PullToRefreshNewState extends State<PullToRefreshNew> {
  var isLoading = true;
  var hasError = false;
  var data = [];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverRefreshControl(
          onRefresh: () => this.loadData(),
        ),
        data.length > 0
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => data[i],
                  childCount: data.length,
                ),
              )
            : SliverFillRemaining(
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
              )
      ],
    );
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
