import 'package:flutter/cupertino.dart';
import 'package:fyx/theme/L.dart';

class SearchNotFound extends StatelessWidget {
  const SearchNotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(bottom: bottom * .8),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
        Container(),
        Text(
          L.GENERAL_EMPTY,
          textAlign: TextAlign.center,
        ),
        Image.asset('assets/travolta.gif')
        ],
        ),
      ),
    );
  }
}
