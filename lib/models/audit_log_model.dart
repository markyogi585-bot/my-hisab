class AuditLogModel {
  final String id;
  final String householdId;
  final String action;
  final String transactionId;
  final String userId;
  final String userDisplayName;
  final DateTime timestamp;
  final String oldValue;
  final String newValue;

  const AuditLogModel({
    required this.id,
    required this.householdId,
    required this.action,
    required this.transactionId,
    required this.userId,
    required this.userDisplayName,
    required this.timestamp,
    this.oldValue = '',
    this.newValue = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'householdId': householdId,
      'action': action,
      'transactionId': transactionId,
      'userId': userId,
      'userDisplayName': userDisplayName,
      'timestamp': timestamp.toIso8601String(),
      'oldValue': oldValue,
      'newValue': newValue,
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AuditLogModel(
      id: id ?? map['id'] as String? ?? '',
      householdId: map['householdId'] as String? ?? '',
      action: map['action'] as String? ?? '',
      transactionId: map['transactionId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userDisplayName: map['userDisplayName'] as String? ?? 'Member',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      oldValue: map['oldValue'] as String? ?? '',
      newValue: map['newValue'] as String? ?? '',
    );
  }
}
