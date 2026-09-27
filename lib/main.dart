import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_colors.dart';
import 'data/local/preferences_service.dart';
import 'data/local/database_service.dart';
import 'providers/database_provider.dart';
import 'providers/settings_provider.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom fail-safe error widget to prevent black screens
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'My Hisab',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Securing your financial ledger...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // Set immersive edge-to-edge transparent system navigation
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF090D1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  PreferencesService? prefsService;
  try {
    prefsService = await PreferencesService.init();
  } catch (e) {
    debugPrint('PreferencesService init notice: $e');
  }

  final dbService = DatabaseService();

  // On first install, populate demo seed data matching the reference screenshot
  if (prefsService != null && prefsService.isFirstLaunch) {
    try {
      await dbService.seedInitialData();
      await prefsService.setInitialBalance(810000.0);
      await prefsService.setSeedDataLoaded(true);
      await prefsService.setFirstLaunchCompleted();
    } catch (e) {
      debugPrint('First launch seed notice: $e');
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        if (prefsService != null)
          preferencesServiceProvider.overrideWithValue(prefsService),
        databaseServiceProvider.overrideWithValue(dbService),
      ],
      child: const MyHisabApp(),
    ),
  );
}

class MyHisabApp extends ConsumerWidget {
  const MyHisabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = createRouter(isFirstLaunch: false);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}
