import 'package:hive_flutter/hive_flutter.dart';

class ThemeHelper {
  static const _boxName = 'themeBox';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static Future<void> setDarkMode(bool isDark) async {
    final box = Hive.box(_boxName);
    box.put('isDark', isDark);
  }

  static bool getDarkMode() {
    final box = Hive.box(_boxName);
    return box.get('isDark', defaultValue: false);
  }
}
