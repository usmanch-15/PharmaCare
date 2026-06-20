import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/backup_entity.dart';
import '../repositories/backup_repository.dart';

class CreateBackupUseCase implements UseCase<BackupEntity, CreateBackupParams> {
  const CreateBackupUseCase(this._repo);
  final BackupRepository _repo;
  @override
  Future<Either<Failure, BackupEntity>> call(CreateBackupParams p) =>
      _repo.createBackup(createdBy: p.createdBy, branchId: p.branchId);
}

class RestoreBackupUseCase implements UseCase<void, RestoreBackupParams> {
  const RestoreBackupUseCase(this._repo);
  final BackupRepository _repo;
  @override
  Future<Either<Failure, void>> call(RestoreBackupParams p) =>
      _repo.restoreBackup(p.backupId);
}

class GetBackupHistoryUseCase implements UseCase<List<BackupEntity>, NoParams> {
  const GetBackupHistoryUseCase(this._repo);
  final BackupRepository _repo;
  @override
  Future<Either<Failure, List<BackupEntity>>> call(NoParams _) =>
      _repo.getBackupHistory();
}

class DeleteBackupUseCase implements UseCase<void, DeleteBackupParams> {
  const DeleteBackupUseCase(this._repo);
  final BackupRepository _repo;
  @override
  Future<Either<Failure, void>> call(DeleteBackupParams p) =>
      _repo.deleteBackup(p.backupId);
}

class CreateBackupParams extends Equatable {
  const CreateBackupParams({required this.createdBy, this.branchId});
  final String createdBy;
  final String? branchId;
  @override List<Object?> get props => [createdBy, branchId];
}

class RestoreBackupParams extends Equatable {
  const RestoreBackupParams(this.backupId);
  final String backupId;
  @override List<Object> get props => [backupId];
}

class DeleteBackupParams extends Equatable {
  const DeleteBackupParams(this.backupId);
  final String backupId;
  @override List<Object> get props => [backupId];
}