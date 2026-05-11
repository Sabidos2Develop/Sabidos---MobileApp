import 'package:flutter/material.dart';
import 'theme_storage.dart';

class ThemeController extends ChangeNotifier {
  final ThemeStorage _storage;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeController(this._storage);

  Future<void> loadTheme() async {
    _themeMode = await _storage.loadTheme();
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;

    await _storage.saveTheme(mode);

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setTheme(ThemeMode.light);
    } else {
      await setTheme(ThemeMode.dark);
    }
  }
}
