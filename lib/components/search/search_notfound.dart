import 'package:flutter/cupertino.dart';
import 'package:fyx/theme/L.dart';

class SearchNotFound extends StatelessWidget {
  const SearchNotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(),
          Text(
            L.GENERAL_EMPTY,
            textAlign: TextAlign.center,
          ),
          Image.asset('travolta.gif')
        ],
      ),
    ));
  }
}
