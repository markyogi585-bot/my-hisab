import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import 'transaction_provider.dart';
import 'balance_provider.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String currencySymbol;
  final bool isBiometricEnabled;
  final bool isHapticEnabled;
  final double initialBalance;

  const SettingsState({
    required this.themeMode,
    required this.currencySymbol,
    required this.isBiometricEnabled,
    required this.isHapticEnabled,
    required this.initialBalance,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? currencySymbol,
    bool? isBiometricEnabled,
    bool? isHapticEnabled,
    double? initialBalance,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isHapticEnabled: isHapticEnabled ?? this.isHapticEnabled,
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref)
      : super(
          const SettingsState(
            themeMode: ThemeMode.dark,
            currencySymbol: '₹',
            isBiometricEnabled: false,
            isHapticEnabled: true,
            initialBalance: 0.0,
          ),
        ) {
    loadSettings();
  }

  void loadSettings() {
    final repo = _ref.read(settingsRepositoryProvider);
    ThemeMode mode = ThemeMode.dark;
    if (repo.themeMode == 'light') {
      mode = ThemeMode.light;
    } else if (repo.themeMode == 'system') {
      mode = ThemeMode.system;
    }

    state = SettingsState(
      themeMode: mode,
      currencySymbol: repo.currencySymbol,
      isBiometricEnabled: repo.isBiometricEnabled,
      isHapticEnabled: repo.isHapticEnabled,
      initialBalance: repo.initialBalance,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final repo = _ref.read(settingsRepositoryProvider);
    String modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.system) modeStr = 'system';
    await repo.setThemeMode(modeStr);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setCurrency(String symbol) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setCurrencySymbol(symbol);
    state = state.copyWith(currencySymbol: symbol);
  }

  Future<void> setBiometric(bool enabled) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setBiometricEnabled(enabled);
    state = state.copyWith(isBiometricEnabled: enabled);
  }

  Future<void> setHaptic(bool enabled) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setHapticEnabled(enabled);
    state = state.copyWith(isHapticEnabled: enabled);
  }

  Future<void> setInitialBalance(double balance) async {
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setInitialBalance(balance);
    state = state.copyWith(initialBalance: balance);
    _ref.read(balanceProvider.notifier).calculateBalance();
  }

  Future<void> loadSeedData() async {
    final repo = _ref.read(transactionRepositoryProvider);
    await repo.seedData();
    await setInitialBalance(810000.0);
    await _ref.read(transactionListProvider.notifier).reloadAll();
  }

  Future<void> clearAllData() async {
    final txRepo = _ref.read(transactionRepositoryProvider);
    await txRepo.clearAll();
    await setInitialBalance(0.0);
    await _ref.read(transactionListProvider.notifier).reloadAll();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
