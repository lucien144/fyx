import 'package:flutter/widgets.dart';

class ContextMenuGrid extends StatelessWidget {
  final List<Widget> children;
  const ContextMenuGrid({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        physics: NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 48),
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 3 : (MediaQuery.of(context).size.width / 140).round(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        children: children);
  }
}
