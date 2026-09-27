import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/local/database_service.dart';
import '../models/transaction_model.dart';
import '../models/audit_log_model.dart';

enum SyncStatus {
  offline,
  syncing,
  synced,
  syncFailed,
}

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _localDb;
  StreamSubscription? _remoteSubscription;
  final ValueNotifier<SyncStatus> statusNotifier = ValueNotifier<SyncStatus>(SyncStatus.synced);

  SyncService(this._localDb);

  /// Initializes realtime listener for the selected household / space
  void startRealtimeSync({
    required String householdId,
    required Function(List<TransactionModel>) onTransactionsUpdated,
  }) {
    _remoteSubscription?.cancel();
    statusNotifier.value = SyncStatus.syncing;

    try {
      _remoteSubscription = _firestore
          .collection('households')
          .doc(householdId)
          .collection('transactions')
          .where('isDeleted', isEqualTo: false)
          .snapshots()
          .listen(
        (snapshot) async {
          final List<TransactionModel> remoteList = [];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final tx = TransactionModel.fromMap(data, id: doc.id);
            remoteList.add(tx);
            // Upsert into local SQLite cache
            await _localDb.insertTransaction(tx.copyWith(isSynced: true));
          }
          statusNotifier.value = SyncStatus.synced;
          onTransactionsUpdated(remoteList);
        },
        onError: (error) {
          debugPrint('Sync listener error (working offline): $error');
          statusNotifier.value = SyncStatus.offline;
        },
      );
    } catch (e) {
      statusNotifier.value = SyncStatus.offline;
    }
  }

  /// Pushes all locally pending un-synced transactions to Firestore
  Future<void> syncPendingLocalChanges(String householdId) async {
    statusNotifier.value = SyncStatus.syncing;

    try {
      final localAll = await _localDb.getAllTransactions();
      final pending = localAll.where((t) => !t.isSynced).toList();

      for (final tx in pending) {
        final docRef = _firestore
            .collection('households')
            .doc(householdId)
            .collection('transactions')
            .doc(tx.id);

        await docRef.set(tx.toMap(), SetOptions(merge: true));

        // Mark local as synced
        await _localDb.updateTransaction(tx.copyWith(isSynced: true));
      }

      statusNotifier.value = SyncStatus.synced;
    } catch (e) {
      debugPrint('Sync failed: $e');
      statusNotifier.value = SyncStatus.syncFailed;
    }
  }

  /// Push deletion to Firestore and store in deleted_transactions archive
  Future<void> syncDeleteTransaction(String householdId, TransactionModel tx, {required String deletedBy}) async {
    try {
      final now = DateTime.now();
      // 1. Mark as deleted in transactions subcollection
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('transactions')
          .doc(tx.id)
          .set({
        'isDeleted': true,
        'deletedAt': now.toIso8601String(),
        'deletedBy': deletedBy,
      }, SetOptions(merge: true));

      // 2. Also archive into dedicated deleted_transactions collection for audit
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('deleted_transactions')
          .doc(tx.id)
          .set({
        ...tx.toMap(),
        'isDeleted': true,
        'deletedAt': now.toIso8601String(),
        'deletedBy': deletedBy,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Cloud sync delete fallback (saved offline): $e');
    }
  }

  /// Push restore to Firestore
  Future<void> syncRestoreTransaction(String householdId, String txId) async {
    try {
      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('transactions')
          .doc(txId)
          .update({
        'isDeleted': false,
        'deletedAt': null,
        'deletedBy': null,
      });

      await _firestore
          .collection('households')
          .doc(householdId)
          .collection('deleted_transactions')
          .doc(txId)
          .delete();
    } catch (e) {
      debugPrint('Cloud sync restore fallback: $e');
    }
  }

  /// Appends an immutable audit log to Firestore
  Future<void> recordAuditLog(AuditLogModel log) async {
    try {
      await _firestore
          .collection('households')
          .doc(log.householdId)
          .collection('auditLogs')
          .doc(log.id)
          .set(log.toMap());
    } catch (e) {
      debugPrint('Error recording audit log (offline): $e');
    }
  }

  void dispose() {
    _remoteSubscription?.cancel();
    statusNotifier.dispose();
  }
}
