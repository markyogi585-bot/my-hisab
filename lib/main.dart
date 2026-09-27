import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'data/local/preferences_service.dart';
import 'data/local/database_service.dart';
import 'providers/database_provider.dart';
import 'providers/settings_provider.dart';
import 'routing/app_router.dart';
import 'services/biometric_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive edge-to-edge transparent system navigation
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final prefsService = await PreferencesService.init();
  final dbService = DatabaseService();

  // On first install, populate demo seed data matching the reference screenshot
  if (prefsService.isFirstLaunch) {
    await dbService.seedInitialData();
    await prefsService.setInitialBalance(810000.0);
    await prefsService.setSeedDataLoaded(true);
    await prefsService.setFirstLaunchCompleted();
  }

  // Biometric gate check if enabled
  if (prefsService.isBiometricEnabled) {
    final bio = BiometricService();
    final authenticated = await bio.authenticate(
      reason: 'Please authenticate to open My Hisab',
    );
    if (!authenticated) {
      SystemNavigator.pop();
      return;
    }
  }

  runApp(
    ProviderScope(
      overrides: [
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
