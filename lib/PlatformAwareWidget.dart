import 'dart:io';

import 'package:flutter/widgets.dart';

abstract class PlatformAwareWidget<A extends Widget, I extends Widget> extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return createCupertinoWidget(context);
    }
    if (Platform.isAndroid) {
      return createAndroidWidget(context);
    }

    throw Exception('Invalid platform');
  }

  A createAndroidWidget(BuildContext context);
  I createCupertinoWidget(BuildContext context);
}