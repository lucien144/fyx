import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fyx/model/Settings.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';
import 'package:fyx/theme/skin/SkinColors.dart';

class SearchBox extends ConsumerStatefulWidget {
  final String? label;
  final ValueChanged onSearch;
  final VoidCallback? onClear;
  final String? searchTerm;
  final int limit;
  final bool loading;

  SearchBox({Key? key, required this.onSearch, this.onClear, this.searchTerm, this.limit = 3, this.label = 'Hledej', this.loading = false})
      : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends ConsumerState<SearchBox> with TickerProviderStateMixin {
  final FocusNode focus = FocusNode();
  late AnimationController searchAnimation;
  Timer? _debounce;
  String searchTerm = '';
  bool _loading = false;

  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();

    searchAnimation = AnimationController(vsync: this, value: widget.searchTerm == null ? 0 : 1);
    searchController.text = widget.searchTerm ?? '';
    _loading = widget.loading;
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
    } else if (widget.searchTerm == '' && oldWidget.searchTerm != '') {
      focus.requestFocus();
    }

    // Update the loading only if has finished outside,
    // otherwise this Widget handles the state itself.
    if (oldWidget.loading != widget.loading && !widget.loading) {
      setState(() => _loading = widget.loading);
    }
  }

  @override
  void dispose() {
    focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _submit(String term) {
    if (term.length > 0 && term.length < widget.limit) {
      T.warn('Zadejte alespoň ${widget.limit} písmena...');
      setState(() => _loading = false);
    } else {
      widget.onSearch(term);
      setState(() => _loading = true);
    }
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
            style: TextStyle(fontSize: Settings().fontSize, color: colors.text),
            placeholderStyle: TextStyle(fontSize: Settings().fontSize, color: colors.text.withOpacity(.5)),
            backgroundColor: colors.text.withOpacity(.1),
            focusNode: focus,
            placeholder: widget.label,
            controller: searchController,
            prefixIcon: _loading ? const CupertinoActivityIndicator(radius: 10) : Icon(CupertinoIcons.search, color: colors.text.withOpacity(.5)),
            onChanged: (term) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 650), () {
                _submit(term);
              });
            },
            onSubmitted: _submit,
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
