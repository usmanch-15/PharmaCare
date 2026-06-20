import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/backup_entity.dart';

class BackupDataSource {
  BackupDataSource(this._fs, this._storage, this._userId);
  final FirebaseFirestore _fs;
  final FirebaseStorage   _storage;
  final String _userId;

  final _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;

  // Collections to back up
  static const _collections = [
    'medicines', 'batches', 'invoices', 'purchaseOrders',
    'customers', 'suppliers', 'stockAdjustments', 'stores',
  ];

  // ── CREATE BACKUP ─────────────────────────────────────────────────────────
  Future<BackupEntity> createBackup(
      {required String createdBy, String? branchId}) async {
    try {
      _progressController.add(0.0);
      final now      = DateTime.now();
      final fileName =
          'backup_${now.year}${_p(now.month)}${_p(now.day)}_${_p(now.hour)}${_p(now.minute)}.json';

      final Map<String, dynamic> backupData = {
        'metadata': {
          'createdAt': now.toIso8601String(),
          'createdBy': createdBy,
          'version':   '1.0',
          if (branchId != null) 'branchId': branchId,
        },
        'collections': {},
      };

      for (int i = 0; i < _collections.length; i++) {
        final col = _collections[i];
        _progressController.add((i + 0.5) / _collections.length);
        Query query = _fs.collection(col);
        if (branchId != null && col != 'stores') {
          try { query = query.where('branchId', isEqualTo: branchId); }
          catch (_) {}
        }
        final snap = await query.limit(5000).get();
        backupData['collections'][col] = {
          for (final doc in snap.docs) doc.id: doc.data()
        };
        _progressController.add((i + 1) / _collections.length);
      }

      // Upload to Firebase Storage
      final jsonBytes = utf8.encode(jsonEncode(backupData));
      final ref = _storage
          .ref()
          .child('backups/$_userId/$fileName');
      await ref.putData(jsonBytes as dynamic);
      final url = await ref.getDownloadURL();

      // Save metadata to Firestore
      final metaRef = await _fs
          .collection('users').doc(_userId)
          .collection('backups').add({
        'fileName':              fileName,
        'downloadUrl':           url,
        'sizeBytes':             jsonBytes.length,
        'status':                BackupStatus.completed.name,
        'createdBy':             createdBy,
        'collectionsIncluded':   _collections,
        if (branchId != null) 'branchId': branchId,
        'createdAt':             FieldValue.serverTimestamp(),
      });

      _progressController.add(1.0);

      return BackupEntity(
        id:                   metaRef.id,
        fileName:             fileName,
        createdAt:            now,
        sizeBytes:            jsonBytes.length,
        status:               BackupStatus.completed,
        createdBy:            createdBy,
        downloadUrl:          url,
        branchId:             branchId,
        collectionsIncluded:  _collections,
      );
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── GET HISTORY ───────────────────────────────────────────────────────────
  Future<List<BackupEntity>> getBackupHistory() async {
    try {
      final snap = await _fs
          .collection('users').doc(_userId)
          .collection('backups')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();
      return snap.docs.map((doc) {
        final d = doc.data();
        return BackupEntity(
          id:        doc.id,
          fileName:  d['fileName']    as String? ?? '',
          createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          sizeBytes: (d['sizeBytes'] as num?)?.toInt() ?? 0,
          status:    BackupStatus.fromString(d['status'] as String?),
          createdBy: d['createdBy']   as String? ?? '',
          downloadUrl: d['downloadUrl'] as String?,
          branchId:  d['branchId']    as String?,
          collectionsIncluded: List<String>.from(
              d['collectionsIncluded'] as List? ?? []),
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> deleteBackup(String backupId) async {
    try {
      final doc = await _fs
          .collection('users').doc(_userId)
          .collection('backups').doc(backupId).get();
      if (!doc.exists) return;
      final fileName = doc.data()?['fileName'] as String? ?? '';
      // Delete from Storage
      try {
        await _storage.ref().child('backups/$_userId/$fileName').delete();
      } catch (_) {}
      // Delete metadata
      await doc.reference.delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}