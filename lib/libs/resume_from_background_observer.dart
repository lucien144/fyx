import 'package:flutter/widgets.dart';

/// Calls [onResumedFromBackground] when the app returns to the foreground after
/// being truly backgrounded (hidden/paused). A mere focus loss (inactive) caused
/// by e.g. the quick settings shade or a permission dialog does not trigger it.
mixin ResumeFromBackgroundObserver<T extends StatefulWidget> on State<T> {
  late final AppLifecycleListener _lifecycleListener;

  void onResumedFromBackground();

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onShow: () {
      // Only refresh when this page is the visible route. Without this check the
      // refresh also fired while another route was on top (e.g. during the login
      // flow after returning from the browser), which very rarely broke authorization.
      // Context: https://github.com/lucien144/fyx/issues/57 (original resume-refresh fix)
      if (ModalRoute.of(context)?.isCurrent == true) {
        onResumedFromBackground();
      }
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }
}