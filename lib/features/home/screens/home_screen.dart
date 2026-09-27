import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/balance_provider.dart';
import '../../../providers/household_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../widgets/liquid_glass_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/cashflow_summary_card.dart';
import '../widgets/quick_actions_row.dart';
import '../widgets/daily_grouped_transactions.dart';
import '../widgets/space_switcher_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balanceProvider);
    final txListAsync = ref.watch(transactionListProvider);
    final householdState = ref.watch(householdProvider);

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
                // Top Navigation Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Icon & App Title
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/icons/app_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Hisab',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.4,
                              ),
                            ),
                            // Space Switcher button
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => const SpaceSwitcherSheet(),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.income,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    householdState.activeHousehold.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.accentCyan,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down_rounded,
                                    color: AppColors.accentCyan,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Top Actions: Recycle Bin & Cloud Sync indicator
                    Row(
                      children: [
                        // Recycle Bin Action
                        LiquidGlassCard(
                          padding: const EdgeInsets.all(8),
                          borderRadius: 14,
                          onTap: () => context.push('/recycle-bin'),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Space Settings / Household Action
                        LiquidGlassCard(
                          padding: const EdgeInsets.all(8),
                          borderRadius: 14,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const SpaceSwitcherSheet(),
                            );
                          },
                          child: const Icon(
                            Icons.groups_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Main Balance Card (Liquid Holographic Glass)
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
                const SizedBox(height: 14),

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
                const SizedBox(height: 18),

                // Quick Actions Row
                QuickActionsRow(
                  onAddTransaction: () => context.push('/add-transaction'),
                  onReports: () => context.go('/reports'),
                  onRecycleBin: () => context.push('/recycle-bin'),
                  onCategories: () => context.push('/categories'),
                ),
                const SizedBox(height: 22),

                // Daily Grouped Transactions Feed
                txListAsync.when(
                  data: (txList) => DailyGroupedTransactions(
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
                  error: (e, _) => Center(
                    child: Text(
                      'Notice: $e',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 90), // Bottom padding for navigation bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
