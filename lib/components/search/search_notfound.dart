import 'package:flutter/cupertino.dart';
import 'package:fyx/theme/L.dart';

class SearchNotFound extends StatelessWidget {
  const SearchNotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom * .8),
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
      ),
    );
  }
}
