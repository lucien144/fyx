import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:fyx/controllers/ApiController.dart';

abstract class PlatformAwareWidget<A extends Widget, I extends Widget> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ApiController mus thave the correct context in order to use Provider.of<>, therefore it's here.
    ApiController().context = context;

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
