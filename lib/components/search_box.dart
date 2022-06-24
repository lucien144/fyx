import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class SearchBox extends ConsumerStatefulWidget {
  final String? label;
  final ValueChanged onSearch;
  final VoidCallback? onClear;
  final String? searchTerm;
  final int limit;

  SearchBox({Key? key, required this.onSearch, this.onClear, this.searchTerm, this.limit = 3, this.label = 'Hledej'}) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends ConsumerState<SearchBox> with TickerProviderStateMixin {
  final FocusNode focus = FocusNode();
  late AnimationController searchAnimation;
  String searchTerm = '';

  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();

    searchAnimation = AnimationController(vsync: this, value: widget.searchTerm == null ? 0 : 1);
    searchController.text = widget.searchTerm ?? '';
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchTerm != widget.searchTerm) {
      if (widget.searchTerm == null) {
        searchController.clear();
      }
      searchAnimation.animateTo(
        widget.searchTerm == null ? 0 : 1,
        curve: Curves.easeOutExpo,
        duration: const Duration(milliseconds: 600),
      );
    }
    if (widget.searchTerm == null) {
      focus.unfocus();
    } else if (widget.searchTerm == '') {
      focus.requestFocus();
    }
  }

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SkinColors colors = Skin.of(context).theme.colors;

    return SizeTransition(
        sizeFactor: CurvedAnimation(
          curve: Curves.ease,
          parent: searchAnimation,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: CupertinoSearchTextField(
            focusNode: focus,
            placeholder: widget.label,
            controller: searchController,
            onSubmitted: (term) {
              if (term.length < widget.limit) {
                T.warn('Zkus hledat víc jak ${widget.limit} znaky...');
              } else {
                widget.onSearch(term);
              }
            },
            onSuffixTap: () {
              widget.onSearch('');
              searchController.clear();
              if (widget.onClear != null) {
                widget.onClear!();
              }
            },
            autocorrect: false,
          ),
          color: colors.barBackground,
        ));
  }
}
