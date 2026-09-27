import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Picks image from Camera or Gallery and saves locally
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
      final savedFile = await File(image.path).copy(localPath);

      // Attempt upload if connected
      String? remoteUrl;
      bool isUploaded = false;

      try {
        final storageRef = _storage.ref(
          'households/$householdId/transactions/$transactionId/receipts/$receiptId.jpg',
        );
        final uploadTask = await storageRef.putFile(
          savedFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        remoteUrl = await uploadTask.ref.getDownloadURL();
        isUploaded = true;
      } catch (e) {
        debugPrint('Receipt saved locally; upload queued for later sync: $e');
      }

      return ReceiptAttachmentResult(
        receiptId: receiptId,
        localPath: localPath,
        remoteUrl: remoteUrl,
        isUploaded: isUploaded,
      );
    } catch (e) {
      debugPrint('Error picking receipt: $e');
      return null;
    }
  }

  /// Syncs any locally pending receipt to Cloud Storage
  Future<String?> uploadPendingReceipt({
    required String localPath,
    required String householdId,
    required String transactionId,
    required String receiptId,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;

      final storageRef = _storage.ref(
        'households/$householdId/transactions/$transactionId/receipts/$receiptId.jpg',
      );
      final uploadTask = await storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading pending receipt: $e');
      return null;
    }
  }
}
