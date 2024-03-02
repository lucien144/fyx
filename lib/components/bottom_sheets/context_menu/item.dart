import 'package:flutter/widgets.dart';
import 'package:fyx/theme/skin/Skin.dart';

class ContextMenuItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Function()? onTap;
  final bool danger;

  const ContextMenuItem({Key? key, required this.label, this.icon, this.onTap, this.danger = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var colors = Skin.of(context).theme.colors;

    return GestureDetector(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: danger ? colors?.danger.withOpacity(0.1) : colors?.barBackground, borderRadius: BorderRadius.circular(8)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(icon, size: 32, color: danger ? colors?.danger : colors?.primary),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: danger ? colors?.danger : colors?.primary),
            )
          ]),
        ),
        onTap: onTap);
  }
}
