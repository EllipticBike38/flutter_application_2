import 'package:flutter/material.dart';
import 'settings_service.dart';

/// A class that many Widgets can interact with to read user settings, update
/// user settings, or listen to user settings changes.
///
/// Controllers glue Data Services to Flutter Widgets. The SettingsController
/// uses the SettingsService to store and retrieve user settings.
class SettingsController with ChangeNotifier {
  SettingsController(this._settingsService);

  // Make SettingsService a private variable so it is not used directly.
  final SettingsService _settingsService;

  // Make ThemeMode a private variable so it is not updated directly without
  // also persisting the changes with the SettingsService.
  late ThemeMode _themeMode;
  late int _partTimePercentage;
  late String _tmzLocation;
  late bool _isUserLogged;
  late String _companyName;
  late String _companyAddress;

  // Allow Widgets to read the user's preferred ThemeMode.
  ThemeMode get themeMode => _themeMode;
  int get partTimePercentage => _partTimePercentage;
  String get tmzLocation => _tmzLocation;
  bool get isUserLogged => _isUserLogged;
  String get companyName => _companyName;
  String get companyAddress => _companyAddress;

  /// Load the user's settings from the SettingsService. It may load from a
  /// local database or the internet. The controller only knows it can load the
  /// settings from the service.
  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _partTimePercentage = await _settingsService.partTimePercentage();
    _tmzLocation = await _settingsService.tmzLocation();
    _isUserLogged = await _settingsService.isUserLogged();
    _companyName = await _settingsService.companyName();
    _companyAddress = await _settingsService.companyAddress();

    // Important! Inform listeners a change has occurred.
    notifyListeners();
  }

  /// Update and persist the ThemeMode based on the user's selection.
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    // Do not perform any work if new and old ThemeMode are identical
    if (newThemeMode == _themeMode) return;

    // Otherwise, store the new ThemeMode in memory
    _themeMode = newThemeMode;

    // Important! Inform listeners a change has occurred.
    notifyListeners();

    // Persist the changes to a local database or the internet using the
    // SettingService.
    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updatePartTimePercentage(int? newPartTimePercentage) async {
    if (newPartTimePercentage == null) return;
    if (newPartTimePercentage == _partTimePercentage) return;

    _partTimePercentage = newPartTimePercentage;

    notifyListeners();

    await _settingsService.updatePartTimePercentage(newPartTimePercentage);
  }

  Future<void> updateTmzLocation(String? newTmzLocation) async {
    if (newTmzLocation == null) return;
    if (newTmzLocation == _tmzLocation) return;

    _tmzLocation = newTmzLocation;

    notifyListeners();

    await _settingsService.updateTmzLocation(newTmzLocation);
  }

  Future<void> updateIsUserLogged(bool? newIsUserLogged) async {
    if (newIsUserLogged == null) return;
    if (newIsUserLogged == _isUserLogged) return;

    _isUserLogged = newIsUserLogged;

    notifyListeners();

    await _settingsService.updateUserLogged(newIsUserLogged);
  }

  Future<void> updateCompanyName(String? newCompanyName) async {
    if (newCompanyName == null) return;
    if (newCompanyName == _companyName) return;

    _companyName = newCompanyName;

    notifyListeners();

    await _settingsService.updateCompanyName(newCompanyName);
  }

  Future<void> updateCompanyAddress(String? newCompanyAddress) async {
    if (newCompanyAddress == null) return;
    if (newCompanyAddress == _companyAddress) return;

    _companyAddress = newCompanyAddress;

    notifyListeners();

    await _settingsService.updateCompanyAddress(newCompanyAddress);
  }
}
