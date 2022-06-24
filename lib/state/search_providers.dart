import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchHistoryProvider = StateProvider<String?>(
  // We return the default sort type, here name.
  (ref) => null,
);

final searchBookmarksProvider = StateProvider<String?>(
  // We return the default sort type, here name.
  (ref) => null,
);
