import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/household_model.dart';
import '../../../providers/household_provider.dart';
import '../../../widgets/liquid_glass_card.dart';

class SpaceSwitcherSheet extends ConsumerWidget {
  const SpaceSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdState = ref.watch(householdProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C101E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Hisab Space',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'All members have shared cloud sync & access',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white60),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Spaces list
          ...householdState.availableHouseholds.map((space) {
            final isSelected = space.id == householdState.activeHousehold.id;

            return LiquidGlassCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 1.5)
                  : null,
              backgroundColor: isSelected
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.white.withOpacity(0.04),
              onTap: () {
                ref.read(householdProvider.notifier).switchHousehold(space);
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppColors.primaryGradient
                          : const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF334155)],
                            ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      space.type == HouseholdType.personal
                          ? Icons.person_rounded
                          : space.type == HouseholdType.family
                              ? Icons.family_restroom_rounded
                              : Icons.business_center_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          space.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${space.memberCount} Admin Members • Cloud Synced',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Add New Space Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.15)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Create New Space / Household'),
            onPressed: () {
              Navigator.pop(context);
              _showCreateSpaceDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

  void _showCreateSpaceDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    HouseholdType selectedType = HouseholdType.family;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Hisab Space', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'e.g. Shop Hisab, Home Ledger',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: const Text('Family'),
                    selected: selectedType == HouseholdType.family,
                    onSelected: (val) => setDialogState(() => selectedType = HouseholdType.family),
                  ),
                  ChoiceChip(
                    label: const Text('Business'),
                    selected: selectedType == HouseholdType.business,
                    onSelected: (val) => setDialogState(() => selectedType = HouseholdType.business),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  ref.read(householdProvider.notifier).createHousehold(
                    name: name,
                    type: selectedType,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create Space'),
            ),
          ],
        ),
      ),
    );
  }
}
