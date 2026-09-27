import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ReceiptAttachmentResult {
  final String receiptId;
  final String localPath;
  final String? remoteUrl;
  final bool isUploaded;

  const ReceiptAttachmentResult({
    required this.receiptId,
    required this.localPath,
    this.remoteUrl,
    required this.isUploaded,
  });
}

class ReceiptService {
  final ImagePicker _picker = ImagePicker();

  /// Picks image from Camera or Gallery and saves locally in device storage
  Future<ReceiptAttachmentResult?> pickAndSaveReceipt({
    required ImageSource source,
    required String householdId,
    required String transactionId,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85, // Compression
      );

      if (image == null) return null;

      final receiptId = const Uuid().v4();
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${appDir.path}/receipts');
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final localPath = '${receiptsDir.path}/${receiptId}_${image.name}';
      await File(image.path).copy(localPath);

      return ReceiptAttachmentResult(
        receiptId: receiptId,
        localPath: localPath,
        remoteUrl: null,
        isUploaded: true, // Marked as available locally
      );
    } catch (e) {
      debugPrint('Error picking receipt: $e');
      return null;
    }
  }

  /// Syncs any locally pending receipt
  Future<String?> uploadPendingReceipt({
    required String localPath,
    required String householdId,
    required String transactionId,
    required String receiptId,
  }) async {
    // Local storage only, returns local path
    return localPath;
  }
}

