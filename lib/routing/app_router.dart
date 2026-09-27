import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/add_transaction/screens/add_transaction_screen.dart';
import '../features/categories/screens/categories_screen.dart';
import '../features/export/screens/export_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/settings/screens/initial_balance_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/transactions/screens/transaction_detail_screen.dart';
import '../features/transactions/screens/transactions_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorHomeKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorTransactionsKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorReportsKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey = GlobalKey<NavigatorState>();

GoRouter createRouter({required bool isFirstLaunch}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: isFirstLaunch ? '/initial-balance' : '/',
    routes: [
      // First Launch Initial Balance Setup
      GoRoute(
        path: '/initial-balance',
        builder: (context, state) => const InitialBalanceScreen(),
      ),

      // Stateful Shell Route for Persistent Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: Stack(
              children: [
                navigationShell,
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AppBottomNavBar(
                    currentIndex: navigationShell.currentIndex,
                    onTabSelected: (index) {
                      navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      );
                    },
                    onAddPressed: () {
                      context.push('/add-transaction');
                    },
                  ),
                ),
              ],
            ),
          );
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Transactions
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTransactionsKey,
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),
          // Branch 2: Reports
          StatefulShellBranch(
            navigatorKey: _shellNavigatorReportsKey,
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          // Branch 3: Settings
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Full-screen Routes
      GoRoute(
        path: '/add-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/edit-transaction/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return AddTransactionScreen(editTransactionId: id);
        },
      ),
      GoRoute(
        path: '/transaction-detail/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TransactionDetailScreen(transactionId: id);
        },
      ),
      GoRoute(
        path: '/categories',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/export',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExportScreen(),
      ),
    ],
  );
}
