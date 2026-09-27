enum MemberRole {
  owner,
  admin,
  editor,
  viewer;

  String get displayName {
    switch (this) {
      case MemberRole.owner:
        return 'Owner / Admin';
      case MemberRole.admin:
      case MemberRole.editor:
      case MemberRole.viewer:
        return 'Admin';
    }
  }

  // In Personal and Family Hisab, all members have full Admin privileges
  bool get canWriteTransactions => true;

  bool get canManageMembers => true;

  bool get canDeleteHousehold => true;
}

class MemberModel {
  final String uid;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final MemberRole role;
  final DateTime joinedAt;

  const MemberModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'role': role.name.toUpperCase(),
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map, {String? uid}) {
    MemberRole parsedRole = MemberRole.admin;
    final r = (map['role'] as String?)?.toUpperCase();
    if (r == 'OWNER') {
      parsedRole = MemberRole.owner;
    } else {
      parsedRole = MemberRole.admin;
    }

    return MemberModel(
      uid: uid ?? map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Member',
      email: map['email'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      role: parsedRole,
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'] as String)
          : DateTime.now(),
    );
  }
}
