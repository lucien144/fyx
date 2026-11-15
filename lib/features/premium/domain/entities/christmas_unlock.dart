/// Easter egg: premium features are free for everyone from December 24 to 31.
class ChristmasUnlock {
  static const int firstDay = 24;
  static const int lastDay = 31;

  static bool isActive(DateTime now) => now.month == DateTime.december && now.day >= firstDay && now.day <= lastDay;
}
