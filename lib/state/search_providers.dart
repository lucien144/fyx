import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class Search {
  const Search({this.history = false, this.historyTerm = '', this.bookmarks = false, this.bookmarksTerm = ''});

  final bool history;
  final String historyTerm;
  final bool bookmarks;
  final String bookmarksTerm;

  Search copyWith({bool? history, String? historyTerm, bool? bookmarks, String? bookmarksTerm}) {
    return Search(
      history: history ?? this.history,
      historyTerm: historyTerm ?? this.historyTerm,
      bookmarks: bookmarks ?? this.bookmarks,
      bookmarksTerm: bookmarksTerm ?? this.bookmarksTerm,
    );
  }
}

class SearchNotifier extends StateNotifier<Search> {
  SearchNotifier(): super(new Search());

  void enableHistory() {
    state = state.copyWith(history: true);
  }

  void disableHistory({bool erase = true}) {
    state = state.copyWith(history: false, historyTerm: erase ? '' : state.historyTerm);
  }

  void setHistoryTerm(String term) {
    state = state.copyWith(historyTerm: term);
  }
  void enableBookmarks() {
    state = state.copyWith(bookmarks: true);
  }

  void disableBookmarks({bool erase = true}) {
    state = state.copyWith(bookmarks: false, bookmarksTerm: erase ? '' : state.bookmarksTerm);
  }

  void setBookmarksTerm(String term) {
    state = state.copyWith(bookmarksTerm: term);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, Search>((ref) {
  return SearchNotifier();
});