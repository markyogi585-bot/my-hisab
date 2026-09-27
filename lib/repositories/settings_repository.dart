import '../data/local/preferences_service.dart';

class SettingsRepository {
  final PreferencesService _prefs;

  SettingsRepository(this._prefs);

  bool get isFirstLaunch => _prefs.isFirstLaunch;
  Future<void> setFirstLaunchCompleted() => _prefs.setFirstLaunchCompleted();

  double get initialBalance => _prefs.initialBalance;
  Future<void> setInitialBalance(double balance) => _prefs.setInitialBalance(balance);

  bool get isBalanceVisible => _prefs.isBalanceVisible;
  Future<void> setBalanceVisible(bool visible) => _prefs.setBalanceVisible(visible);

  String get currencySymbol => _prefs.currencySymbol;
  Future<void> setCurrencySymbol(String symbol) => _prefs.setCurrencySymbol(symbol);

  String get themeMode => _prefs.themeMode;
  Future<void> setThemeMode(String mode) => _prefs.setThemeMode(mode);

  bool get isBiometricEnabled => _prefs.isBiometricEnabled;
  Future<void> setBiometricEnabled(bool enabled) => _prefs.setBiometricEnabled(enabled);

  bool get isHapticEnabled => _prefs.isHapticEnabled;
  Future<void> setHapticEnabled(bool enabled) => _prefs.setHapticEnabled(enabled);

  bool get isSeedDataLoaded => _prefs.isSeedDataLoaded;
  Future<void> setSeedDataLoaded(bool loaded) => _prefs.setSeedDataLoaded(loaded);

  Future<void> clearAll() => _prefs.clearAll();
}
