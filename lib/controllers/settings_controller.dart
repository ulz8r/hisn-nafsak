import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const String _prefDarkMode = 'isDarkMode';
  static const String _prefFontSize = 'fontSize';
  static const String _prefVibration = 'vibrationEnabled';
  static const String _prefAutoAdvance = 'autoAdvanceEnabled';

  bool _isDarkMode = false;
  double _fontSize = 22.0;
  bool _vibrationEnabled = true;
  bool _autoAdvanceEnabled = true;

  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get autoAdvanceEnabled => _autoAdvanceEnabled;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsController() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_prefDarkMode) ?? false;
      _fontSize = prefs.getDouble(_prefFontSize) ?? 22.0;
      _vibrationEnabled = prefs.getBool(_prefVibration) ?? true;
      _autoAdvanceEnabled = prefs.getBool(_prefAutoAdvance) ?? true;
      notifyListeners();
    } catch (_) {
      // In case SharedPreferences fails or running in test
    }
  }

  Future<void> toggleDarkMode(bool val) async {
    _isDarkMode = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefDarkMode, val);
  }

  Future<void> setFontSize(double val) async {
    _fontSize = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefFontSize, val);
  }

  Future<void> toggleVibration(bool val) async {
    _vibrationEnabled = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefVibration, val);
  }

  Future<void> toggleAutoAdvance(bool val) async {
    _autoAdvanceEnabled = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAutoAdvance, val);
  }

  void triggerTapFeedback() {
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    SystemSound.play(SystemSoundType.click);
  }

  void triggerCompletionFeedback() {
    if (_vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
    SystemSound.play(SystemSoundType.click);
  }
}
