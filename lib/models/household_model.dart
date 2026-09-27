enum HouseholdType {
  personal,
  family,
  business;

  String get displayName {
    switch (this) {
      case HouseholdType.personal:
        return 'Personal Hisab';
      case HouseholdType.family:
        return 'Family Hisab';
      case HouseholdType.business:
        return 'Business Hisab';
    }
  }
}

class HouseholdModel {
  final String id;
  final String name;
  final HouseholdType type;
  final String currency;
  final int openingBalanceMinor;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int memberCount;

  const HouseholdModel({
    required this.id,
    required this.name,
    this.type = HouseholdType.personal,
    this.currency = 'INR',
    this.openingBalanceMinor = 0,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.memberCount = 1,
  });

  double get openingBalanceInRupees => openingBalanceMinor / 100.0;

  HouseholdModel copyWith({
    String? id,
    String? name,
    HouseholdType? type,
    String? currency,
    int? openingBalanceMinor,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? memberCount,
  }) {
    return HouseholdModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'currency': currency,
      'openingBalanceMinor': openingBalanceMinor,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'memberCount': memberCount,
    };
  }

  factory HouseholdModel.fromMap(Map<String, dynamic> map, {String? id}) {
    HouseholdType hType = HouseholdType.personal;
    final t = map['type'] as String?;
    if (t == 'family') hType = HouseholdType.family;
    if (t == 'business') hType = HouseholdType.business;

    return HouseholdModel(
      id: id ?? map['id'] as String? ?? 'default_household',
      name: map['name'] as String? ?? 'My Hisab Space',
      type: hType,
      currency: map['currency'] as String? ?? 'INR',
      openingBalanceMinor: (map['openingBalanceMinor'] as num?)?.toInt() ?? 0,
      createdBy: map['createdBy'] as String? ?? 'owner',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
      memberCount: (map['memberCount'] as num?)?.toInt() ?? 1,
    );
  }
}
