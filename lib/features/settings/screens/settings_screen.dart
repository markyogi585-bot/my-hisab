import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/database_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showInitialBalanceDialog(BuildContext context, WidgetRef ref, double currentBal) {
    final controller = TextEditingController(text: currentBal.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Update Starting Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: AppColors.surfaceCard,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newBal = double.tryParse(controller.text.replaceAll(',', '').trim()) ?? 0.0;
              await ref.read(settingsProvider.notifier).setInitialBalance(newBal);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear All Data', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w700)),
        content: const Text(
          'This will permanently delete all your transactions and restore default categories. This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).clearAllData();
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared'),
                    backgroundColor: AppColors.expense,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance'),
              Container(
                decoration: _containerDecoration(),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                      title: const Text('Theme Mode', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        settings.themeMode == ThemeMode.dark ? 'Dark Mode (Active)' : 'Light Mode',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: DropdownButton<ThemeMode>(
                        value: settings.themeMode,
                        dropdownColor: AppColors.surfaceElevated,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        items: const [
                          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                          DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                          DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            ref.read(settingsProvider.notifier).setThemeMode(mode);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Ledger & Currency Section
              _buildSectionHeader('Ledger & Balance'),
              Container(
                decoration: _containerDecoration(),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.secondary),
                      title: const Text('Starting Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        CurrencyFormatter.format(settings.initialBalance),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
                      onTap: () => _showInitialBalanceDialog(context, ref, settings.initialBalance),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.currency_rupee_rounded, color: AppColors.income),
                      title: const Text('Currency Symbol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: const Text('₹ INR (Indian Rupee)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      trailing: const Text('₹', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Security Section
              _buildSectionHeader('Security'),
              Container(
                decoration: _containerDecoration(),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.accentCyan),
                      title: const Text('Biometric App Lock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Require fingerprint/face to open app', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      value: settings.isBiometricEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (val) async {
                        if (val) {
                          final bioService = ref.read(biometricServiceProvider);
                          final authSuccess = await bioService.authenticate();
                          if (authSuccess) {
                            await ref.read(settingsProvider.notifier).setBiometric(true);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Biometric verification failed')),
                              );
                            }
                          }
                        } else {
                          await ref.read(settingsProvider.notifier).setBiometric(false);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data & Tools Section
              _buildSectionHeader('Data Management'),
              Container(
                decoration: _containerDecoration(),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.file_upload_outlined, color: AppColors.primary),
                      title: const Text('Export Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Generate PDF, CSV or text statements', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/export'),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.category_outlined, color: AppColors.warning),
                      title: const Text('Manage Categories', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Add, edit, or customize categories', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      onTap: () => context.push('/categories'),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary),
                      title: const Text('Load Demo / Sample Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Populate sample transactions matching design mockup', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      onTap: () async {
                        await ref.read(settingsProvider.notifier).loadSeedData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Demo transactions loaded successfully!'),
                              backgroundColor: AppColors.income,
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.delete_forever_rounded, color: AppColors.expense),
                      title: const Text('Clear All Data', style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Delete all entries and reset balances', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      onTap: () => _confirmClearData(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // About & App Info
              _buildSectionHeader('About'),
              Container(
                decoration: _containerDecoration(),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                      title: const Text(AppConstants.appName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Version ${AppConstants.appVersion} • Track • Manage • Grow', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 90), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textTertiary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border.withOpacity(0.5)),
    );
  }
}
