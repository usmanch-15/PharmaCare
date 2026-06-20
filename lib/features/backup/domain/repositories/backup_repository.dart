import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/backup_entity.dart';

abstract class BackupRepository {
  /// Creates a JSON export of all Firestore collections and uploads to Storage.
  Future<Either<Failure, BackupEntity>> createBackup({
    required String createdBy,
    String? branchId,
  });

  /// Restores Firestore from a backup file.
  Future<Either<Failure, void>> restoreBackup(String backupId);

  /// Lists all backup records for the current user.
  Future<Either<Failure, List<BackupEntity>>> getBackupHistory();

  /// Deletes a backup from Storage + Firestore metadata.
  Future<Either<Failure, void>> deleteBackup(String backupId);

  /// Progress stream during backup/restore (0.0 – 1.0).
  Stream<double> get progressStream;
}