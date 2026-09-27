import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  bool get isFirstLaunch => _prefs.getBool(AppConstants.prefIsFirstLaunch) ?? true;
  Future<void> setFirstLaunchCompleted() async {
    await _prefs.setBool(AppConstants.prefIsFirstLaunch, false);
  }

  double get initialBalance => _prefs.getDouble(AppConstants.prefInitialBalance) ?? 0.0;
  Future<void> setInitialBalance(double balance) async {
    await _prefs.setDouble(AppConstants.prefInitialBalance, balance);
  }

  bool get isBalanceVisible => _prefs.getBool(AppConstants.prefBalanceVisible) ?? true;
  Future<void> setBalanceVisible(bool visible) async {
    await _prefs.setBool(AppConstants.prefBalanceVisible, visible);
  }

  String get currencySymbol => _prefs.getString(AppConstants.prefCurrencySymbol) ?? AppConstants.defaultCurrencySymbol;
  Future<void> setCurrencySymbol(String symbol) async {
    await _prefs.setString(AppConstants.prefCurrencySymbol, symbol);
  }

  String get themeMode => _prefs.getString(AppConstants.prefThemeMode) ?? 'dark';
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(AppConstants.prefThemeMode, mode);
  }

  bool get isBiometricEnabled => _prefs.getBool(AppConstants.prefBiometricEnabled) ?? false;
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.prefBiometricEnabled, enabled);
  }

  bool get isHapticEnabled => _prefs.getBool(AppConstants.prefHapticFeedback) ?? true;
  Future<void> setHapticEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.prefHapticFeedback, enabled);
  }

  bool get isSeedDataLoaded => _prefs.getBool(AppConstants.prefSeedDataLoaded) ?? false;
  Future<void> setSeedDataLoaded(bool loaded) async {
    await _prefs.setBool(AppConstants.prefSeedDataLoaded, loaded);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
