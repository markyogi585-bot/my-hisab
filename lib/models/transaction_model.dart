import 'package:uuid/uuid.dart';

enum TransactionType {
  expense,
  income;

  bool get isExpense => this == TransactionType.expense;
  bool get isIncome => this == TransactionType.income;

  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense (Debit)';
      case TransactionType.income:
        return 'Income (Credit)';
    }
  }

  String get shortName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }
}

class TransactionModel {
  final String id;
  final String householdId;
  final TransactionType type;
  final int amountMinor; // Stored in minor units (paise: ₹50,000 = 5,000,000 paise)
  final String currency;
  final String categoryId;
  final String categoryName;
  final String title;
  final String description;
  final DateTime dateTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String createdByName;
  final String updatedBy;
  final String deviceId;
  final int version; // For concurrent edit protection
  final bool isDeleted; // Soft delete
  final DateTime? deletedAt;
  final String? deletedBy;
  final String clientOperationId; // Deduplication & idempotency key
  final String? receiptId;
  final String? receiptUrl;
  final String? localReceiptPath;
  final bool isSynced;
  final bool isTemplate;

  const TransactionModel({
    required this.id,
    this.householdId = 'default_household',
    required this.type,
    required this.amountMinor,
    this.currency = 'INR',
    required this.categoryId,
    required this.categoryName,
    required this.title,
    this.description = '',
    required this.dateTime,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = 'user',
    this.createdByName = 'You',
    this.updatedBy = 'user',
    this.deviceId = 'device_local',
    this.version = 1,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    required this.clientOperationId,
    this.receiptId,
    this.receiptUrl,
    this.localReceiptPath,
    this.isSynced = true,
    this.isTemplate = false,
  });

  /// Rupee representation computed from minor units
  double get amount => amountMinor / 100.0;
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get hasReceipt => (receiptUrl != null && receiptUrl!.isNotEmpty) || (localReceiptPath != null && localReceiptPath!.isNotEmpty);

  /// Helper factory creating from Rupees (e.g. 50000.0)
  factory TransactionModel.create({
    String? id,
    String householdId = 'default_household',
    required TransactionType type,
    required double amountInRupees,
    String currency = 'INR',
    required String categoryId,
    required String categoryName,
    required String title,
    String description = '',
    required DateTime dateTime,
    String createdBy = 'user',
    String createdByName = 'You',
    String? receiptId,
    String? receiptUrl,
    String? localReceiptPath,
    bool isTemplate = false,
  }) {
    final now = DateTime.now();
    final uid = id ?? const Uuid().v4();
    return TransactionModel(
      id: uid,
      householdId: householdId,
      type: type,
      amountMinor: (amountInRupees * 100).round(),
      currency: currency,
      categoryId: categoryId,
      categoryName: categoryName,
      title: title,
      description: description,
      dateTime: dateTime,
      createdAt: now,
      updatedAt: now,
      createdBy: createdBy,
      createdByName: createdByName,
      updatedBy: createdBy,
      deviceId: 'device_local',
      version: 1,
      isDeleted: false,
      clientOperationId: const Uuid().v4(),
      receiptId: receiptId,
      receiptUrl: receiptUrl,
      localReceiptPath: localReceiptPath,
      isSynced: false,
      isTemplate: isTemplate,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? householdId,
    TransactionType? type,
    int? amountMinor,
    double? amountInRupees,
    String? currency,
    String? categoryId,
    String? categoryName,
    String? title,
    String? description,
    DateTime? dateTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? createdByName,
    String? updatedBy,
    String? deviceId,
    int? version,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    String? clientOperationId,
    String? receiptId,
    String? receiptUrl,
    String? localReceiptPath,
    bool? isSynced,
    bool? isTemplate,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      type: type ?? this.type,
      amountMinor: amountMinor ?? (amountInRupees != null ? (amountInRupees * 100).round() : this.amountMinor),
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      updatedBy: updatedBy ?? this.updatedBy,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      clientOperationId: clientOperationId ?? this.clientOperationId,
      receiptId: receiptId ?? this.receiptId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      localReceiptPath: localReceiptPath ?? this.localReceiptPath,
      isSynced: isSynced ?? this.isSynced,
      isTemplate: isTemplate ?? this.isTemplate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'householdId': householdId,
      'type': type.name,
      'amountMinor': amountMinor,
      'amount': amount, // Keep double for SQLite backward compatibility
      'currency': currency,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'updatedBy': updatedBy,
      'deviceId': deviceId,
      'version': version,
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt?.toIso8601String(),
      'deletedBy': deletedBy,
      'clientOperationId': clientOperationId,
      'receiptId': receiptId,
      'receiptUrl': receiptUrl,
      'localReceiptPath': localReceiptPath,
      'isSynced': isSynced ? 1 : 0,
      'isTemplate': isTemplate ? 1 : 0,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map, {String? id}) {
    // Determine amountMinor
    int minor = 0;
    if (map['amountMinor'] != null) {
      minor = (map['amountMinor'] as num).toInt();
    } else if (map['amount'] != null) {
      minor = ((map['amount'] as num).toDouble() * 100).round();
    }

    final typeStr = map['type'] as String? ?? 'expense';
    final parsedType = typeStr == 'income' ? TransactionType.income : TransactionType.expense;

    final isDel = map['isDeleted'] == 1 || map['isDeleted'] == true;
    final isSync = map['isSynced'] == 1 || map['isSynced'] == true;
    final isTpl = map['isTemplate'] == 1 || map['isTemplate'] == true;

    return TransactionModel(
      id: id ?? map['id'] as String? ?? const Uuid().v4(),
      householdId: map['householdId'] as String? ?? 'default_household',
      type: parsedType,
      amountMinor: minor,
      currency: map['currency'] as String? ?? 'INR',
      categoryId: map['categoryId'] as String? ?? 'other',
      categoryName: map['categoryName'] as String? ?? 'Other',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dateTime: map['dateTime'] != null ? DateTime.parse(map['dateTime'] as String) : DateTime.now(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : DateTime.now(),
      createdBy: map['createdBy'] as String? ?? 'user',
      createdByName: map['createdByName'] as String? ?? 'You',
      updatedBy: map['updatedBy'] as String? ?? 'user',
      deviceId: map['deviceId'] as String? ?? 'device_local',
      version: (map['version'] as num?)?.toInt() ?? 1,
      isDeleted: isDel,
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt'] as String) : null,
      deletedBy: map['deletedBy'] as String?,
      clientOperationId: map['clientOperationId'] as String? ?? const Uuid().v4(),
      receiptId: map['receiptId'] as String?,
      receiptUrl: map['receiptUrl'] as String?,
      localReceiptPath: map['localReceiptPath'] as String?,
      isSynced: isSync,
      isTemplate: isTpl,
    );
  }
}
