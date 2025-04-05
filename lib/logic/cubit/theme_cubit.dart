import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/theme_helper.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit()
    : super(ThemeHelper.getDarkMode() ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    ThemeHelper.setDarkMode(!isDark);
    emit(newMode);
  }
}
