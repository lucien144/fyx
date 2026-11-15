import 'package:flutter/cupertino.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import 'package:fyx/controllers/SettingsProvider.dart';
import 'package:fyx/controllers/log_service.dart';
import 'package:fyx/model/enums/app_icon_enum.dart';
import 'package:fyx/theme/T.dart';
import 'package:fyx/theme/skin/Skin.dart';

/// Picker for the app launcher icon (iOS only).
///
/// iOS owns the truth: the currently applied icon is read back from
/// [FlutterDynamicIconPlus] on open and the persisted setting is realigned to
/// it, so the checkmark can never claim something the home screen contradicts.
class AppIconBottomSheet extends StatefulWidget {
  const AppIconBottomSheet({Key? key}) : super(key: key);

  @override
  State<AppIconBottomSheet> createState() => _AppIconBottomSheetState();
}

class _AppIconBottomSheetState extends State<AppIconBottomSheet> {
  late AppIconEnum _selected;
  bool _isSwitching = false;

  @override
  void initState() {
    super.initState();

    // Render immediately from the cached setting, then reconcile with iOS.
    _selected = SettingsProvider().appIcon;
    _syncWithSystem();
  }

  Future<void> _syncWithSystem() async {
    try {
      final applied = AppIconEnum.fromAlternateIconName(await FlutterDynamicIconPlus.alternateIconName);
      if (applied == _selected) return;
      SettingsProvider().appIcon = applied;
      if (mounted) setState(() => _selected = applied);
    } catch (error, stack) {
      LogService.captureError(error, stack: stack);
    }
  }

  Future<void> _select(AppIconEnum icon) async {
    if (_isSwitching || icon == _selected) return;

    setState(() => _isSwitching = true);
    try {
      await FlutterDynamicIconPlus.setAlternateIconName(iconName: icon.alternateIconName);
      SettingsProvider().appIcon = icon;
      if (mounted) setState(() => _selected = icon);
    } catch (error, stack) {
      LogService.captureError(error, stack: stack);
      T.error('Ikonu se nepodařilo změnit.');
    } finally {
      if (mounted) setState(() => _isSwitching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Skin.of(context).theme.colors;

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 32, top: 32, right: 32, bottom: 48),
      children: [
        Text(
          'Ikona aplikace',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: colors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'Vyber si jakou chceš ikonu na ploše.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: colors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ...AppIconEnum.values.map(_iconItem),
        Text(
          'Po změně ikony zobrazí iOS systémové upozornění.',
          style: TextStyle(fontSize: 13, color: colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _iconItem(AppIconEnum icon) {
    final colors = Skin.of(context).theme.colors;
    final isSelected = icon == _selected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _select(icon),
      child: Opacity(
        opacity: _isSwitching && !isSelected ? 0.5 : 1,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? colors.primary : colors.grey.withValues(alpha: 0.3), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(icon.preview, width: 56, height: 56),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(icon.label, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              ),
              Icon(
                isSelected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                size: 26,
                color: isSelected ? colors.primary : colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
