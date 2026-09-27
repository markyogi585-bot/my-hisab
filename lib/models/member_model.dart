enum MemberRole {
  owner,
  admin,
  editor,
  viewer;

  String get displayName {
    switch (this) {
      case MemberRole.owner:
        return 'Owner';
      case MemberRole.admin:
        return 'Admin';
      case MemberRole.editor:
        return 'Editor';
      case MemberRole.viewer:
        return 'Viewer';
    }
  }

  bool get canWriteTransactions =>
      this == MemberRole.owner || this == MemberRole.admin || this == MemberRole.editor;

  bool get canManageMembers =>
      this == MemberRole.owner || this == MemberRole.admin;

  bool get canDeleteHousehold => this == MemberRole.owner;
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
    MemberRole parsedRole = MemberRole.editor;
    final r = (map['role'] as String?)?.toUpperCase();
    if (r == 'OWNER') parsedRole = MemberRole.owner;
    if (r == 'ADMIN') parsedRole = MemberRole.admin;
    if (r == 'EDITOR') parsedRole = MemberRole.editor;
    if (r == 'VIEWER') parsedRole = MemberRole.viewer;

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
