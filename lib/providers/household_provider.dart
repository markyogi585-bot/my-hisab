import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/household_model.dart';
import '../models/member_model.dart';
import 'database_provider.dart';

class HouseholdState {
  final HouseholdModel activeHousehold;
  final List<HouseholdModel> availableHouseholds;
  final List<MemberModel> members;
  final MemberRole currentRole;

  const HouseholdState({
    required this.activeHousehold,
    required this.availableHouseholds,
    required this.members,
    required this.currentRole,
  });

  HouseholdState copyWith({
    HouseholdModel? activeHousehold,
    List<HouseholdModel>? availableHouseholds,
    List<MemberModel>? members,
    MemberRole? currentRole,
  }) {
    return HouseholdState(
      activeHousehold: activeHousehold ?? this.activeHousehold,
      availableHouseholds: availableHouseholds ?? this.availableHouseholds,
      members: members ?? this.members,
      currentRole: currentRole ?? this.currentRole,
    );
  }
}

class HouseholdNotifier extends StateNotifier<HouseholdState> {
  final Ref _ref;

  static final HouseholdModel _defaultPersonal = HouseholdModel(
    id: 'personal_space',
    name: 'Personal Hisab',
    type: HouseholdType.personal,
    openingBalanceMinor: 81000000, // ₹8,10,000 in paise
    createdBy: 'current_user',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    memberCount: 1,
  );

  static final HouseholdModel _defaultFamily = HouseholdModel(
    id: 'family_space',
    name: 'Yogi Family Hisab',
    type: HouseholdType.family,
    openingBalanceMinor: 50000000,
    createdBy: 'current_user',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    memberCount: 3,
  );

  static final HouseholdModel _defaultBusiness = HouseholdModel(
    id: 'business_space',
    name: 'Business Hisab',
    type: HouseholdType.business,
    openingBalanceMinor: 100000000,
    createdBy: 'current_user',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    memberCount: 2,
  );

  HouseholdNotifier(this._ref)
      : super(
          HouseholdState(
            activeHousehold: _defaultPersonal,
            availableHouseholds: [_defaultPersonal, _defaultFamily, _defaultBusiness],
            members: [
              MemberModel(
                uid: 'current_user',
                displayName: 'You (Owner)',
                email: 'yogi@myhisab.com',
                role: MemberRole.owner,
                joinedAt: DateTime.now(),
              ),
              MemberModel(
                uid: 'member_2',
                displayName: 'Rahul',
                email: 'rahul@family.com',
                role: MemberRole.admin,
                joinedAt: DateTime.now(),
              ),
              MemberModel(
                uid: 'member_3',
                displayName: 'Pooja',
                email: 'pooja@family.com',
                role: MemberRole.admin,
                joinedAt: DateTime.now(),
              ),
            ],
            currentRole: MemberRole.owner,
          ),
        );

  void switchHousehold(HouseholdModel target) {
    state = state.copyWith(activeHousehold: target);
  }

  void switchHouseholdById(String id) {
    final found = state.availableHouseholds.firstWhere(
      (h) => h.id == id,
      orElse: () => state.activeHousehold,
    );
    state = state.copyWith(activeHousehold: found);
  }

  void createHousehold({required String name, required HouseholdType type}) {
    final newSpace = HouseholdModel(
      id: const Uuid().v4(),
      name: name,
      type: type,
      openingBalanceMinor: 0,
      createdBy: 'current_user',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      memberCount: 1,
    );
    state = state.copyWith(
      activeHousehold: newSpace,
      availableHouseholds: [...state.availableHouseholds, newSpace],
    );
  }

  Future<void> addMember({required String email, MemberRole role = MemberRole.admin}) async {
    if (state.members.length >= 4) {
      throw Exception('Hisab Space limit reached (Maximum 4 members allowed)');
    }

    final newMember = MemberModel(
      uid: const Uuid().v4(),
      displayName: email.split('@').first,
      email: email,
      role: MemberRole.admin,
      joinedAt: DateTime.now(),
    );

    final updated = [...state.members, newMember];
    state = state.copyWith(
      members: updated,
      activeHousehold: state.activeHousehold.copyWith(memberCount: updated.length),
    );
  }

  Future<void> removeMember(String uid) async {
    final updated = state.members.where((m) => m.uid != uid).toList();
    state = state.copyWith(
      members: updated,
      activeHousehold: state.activeHousehold.copyWith(memberCount: updated.length),
    );
  }
}

final householdProvider =
    StateNotifierProvider<HouseholdNotifier, HouseholdState>((ref) {
  return HouseholdNotifier(ref);
});
