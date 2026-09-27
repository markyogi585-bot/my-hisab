import '../models/transaction_model.dart';

enum ConflictResolutionChoice {
  keepMine,
  useLatest,
  mergeManual,
}

class TransactionConflict {
  final TransactionModel localVersion;
  final TransactionModel remoteVersion;

  const TransactionConflict({
    required this.localVersion,
    required this.remoteVersion,
  });

  bool get hasAmountConflict => localVersion.amountMinor != remoteVersion.amountMinor;
  bool get hasTitleConflict => localVersion.title != remoteVersion.title;
  bool get hasCategoryConflict => localVersion.categoryId != remoteVersion.categoryId;
}

class ConflictResolverService {
  const ConflictResolverService();

  /// Check whether remote modification conflicts with unsynced local version
  bool hasConflict(TransactionModel local, TransactionModel remote) {
    if (local.id != remote.id) return false;
    // Conflict exists if local is un-synced and remote version is greater or different
    if (!local.isSynced && remote.version > local.version) {
      return true;
    }
    return false;
  }

  /// Resolve conflict based on user's selected choice
  TransactionModel resolve({
    required TransactionConflict conflict,
    required ConflictResolutionChoice choice,
  }) {
    switch (choice) {
      case ConflictResolutionChoice.keepMine:
        return conflict.localVersion.copyWith(
          version: conflict.remoteVersion.version + 1,
          updatedAt: DateTime.now(),
          isSynced: false,
        );
      case ConflictResolutionChoice.useLatest:
        return conflict.remoteVersion.copyWith(
          isSynced: true,
        );
      case ConflictResolutionChoice.mergeManual:
        return conflict.localVersion.copyWith(
          version: conflict.remoteVersion.version + 1,
          updatedAt: DateTime.now(),
          isSynced: false,
        );
    }
  }
}
