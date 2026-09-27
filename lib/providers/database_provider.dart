import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database_service.dart';
import '../data/local/preferences_service.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/biometric_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError('Initialize preferencesServiceProvider in main');
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return TransactionRepository(db);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseServiceProvider);
  return CategoryRepository(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return SettingsRepository(prefs);
});
