import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/backup_entity.dart';
import '../../domain/repositories/backup_repository.dart';
import '../datasources/backup_datasource.dart';

class BackupRepositoryImpl implements BackupRepository {
  const BackupRepositoryImpl(this._ds);
  final BackupDataSource _ds;

  Either<Failure, T> _h<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    return Left(UnexpectedFailure(e.toString()));
  }

  @override Stream<double> get progressStream => _ds.progressStream;

  @override
  Future<Either<Failure, BackupEntity>> createBackup({
    required String createdBy, String? branchId,
  }) async {
    try { return Right(await _ds.createBackup(
        createdBy: createdBy, branchId: branchId)); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, void>> restoreBackup(String backupId) async =>
      const Right(null); // Restore implementation in enterprise version

  @override
  Future<Either<Failure, List<BackupEntity>>> getBackupHistory() async {
    try { return Right(await _ds.getBackupHistory()); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, void>> deleteBackup(String backupId) async {
    try { await _ds.deleteBackup(backupId); return const Right(null); }
    catch (e) { return _h(e); }
  }
}