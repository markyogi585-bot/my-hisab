import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/balance_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/cashflow_summary_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/recent_transactions_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceProvider);
    final recentTxAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceElevated,
          onRefresh: () async {
            await ref.read(transactionListProvider.notifier).reloadAll();
            await ref.read(balanceProvider.notifier).calculateBalance();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Top Bar: Logo, App Title, Tagline, Notification Bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Hisab',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Track • Manage • Grow',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Notification Bell Icon with Badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.6),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.expense,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Main Balance Card
                balanceAsync.when(
                  data: (balanceState) => BalanceCard(
                    balanceState: balanceState,
                    onToggleVisibility: () {
                      ref.read(balanceProvider.notifier).toggleVisibility();
                    },
                  ),
                  loading: () => Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 16),

                // Cashflow Summary (Income / Expense)
                balanceAsync.when(
                  data: (balanceState) => CashflowSummaryCard(
                    totalIncome: balanceState.totalIncome,
                    totalExpense: balanceState.totalExpense,
                    isVisible: balanceState.isVisible,
                  ),
                  loading: () => const SizedBox(height: 80),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 20),

                // Quick Actions Row
                QuickActionsRow(
                  onAddTransaction: () => context.push('/add-transaction'),
                  onReports: () => context.go('/reports'),
                  onExport: () => context.push('/export'),
                  onMore: () => context.push('/categories'),
                ),
                const SizedBox(height: 24),

                // Recent Transactions List
                recentTxAsync.when(
                  data: (txList) => RecentTransactionsList(
                    transactions: txList,
                    onSeeAll: () => context.go('/transactions'),
                    onTransactionTap: (tx) => context.push('/transaction-detail/${tx.id}'),
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (e, _) => Text(
                    'Error: $e',
                    style: const TextStyle(color: AppColors.expense),
                  ),
                ),
                const SizedBox(height: 90), // Bottom padding for floating navigation bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
