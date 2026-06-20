import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/backup_entity.dart';
import '../../domain/usecases/backup_usecases.dart';
import '../providers/backup_providers.dart';

enum BackupActionStatus { idle, creating, restoring, deleting, success, error }

class BackupState {
  const BackupState({
    this.backups = const [],
    this.status = BackupActionStatus.idle,
    this.progress = 0.0,
    this.errorMessage,
    this.successMessage,
  });
  final List<BackupEntity> backups;
  final BackupActionStatus status;
  final double progress;
  final String? errorMessage;
  final String? successMessage;
  bool get isLoading =>
      status == BackupActionStatus.creating ||
      status == BackupActionStatus.restoring ||
      status == BackupActionStatus.deleting;
  BackupState copyWith({
    List<BackupEntity>? backups, BackupActionStatus? status,
    double? progress, String? errorMessage, String? successMessage,
    bool clearMessages = false,
  }) => BackupState(
    backups: backups ?? this.backups,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
    successMessage: clearMessages ? null : successMessage ?? this.successMessage,
  );
}

class BackupViewModel extends Notifier<BackupState> {
  @override
  BackupState build() {
    // Listen to progress stream
    final repo = ref.read(backupRepositoryProvider);
    final sub = repo.progressStream.listen(
        (p) => state = state.copyWith(progress: p));
    ref.onDispose(sub.cancel);
    Future.microtask(loadHistory);
    return const BackupState();
  }

  Future<void> loadHistory() async {
    final result = await ref
        .read(getBackupHistoryUseCaseProvider)(const NoParams());
    result.fold(
      (f) => state = state.copyWith(errorMessage: f.message),
      (list) => state = state.copyWith(backups: list),
    );
  }

  Future<void> createBackup({String? branchId}) async {
    state = state.copyWith(
        status: BackupActionStatus.creating,
        progress: 0.0, clearMessages: true);
    final result = await ref
        .read(createBackupUseCaseProvider)(CreateBackupParams(
            createdBy: 'current_user_id', branchId: branchId));
    result.fold(
      (f) => state = state.copyWith(
          status: BackupActionStatus.error, errorMessage: f.message),
      (backup) {
        state = state.copyWith(
          status: BackupActionStatus.success,
          backups: [backup, ...state.backups],
          successMessage: 'Backup created: ${backup.formattedSize}',
          progress: 1.0,
        );
      },
    );
  }

  Future<void> deleteBackup(String id) async {
    state = state.copyWith(
        status: BackupActionStatus.deleting, clearMessages: true);
    final result = await ref
        .read(deleteBackupUseCaseProvider)(DeleteBackupParams(id));
    result.fold(
      (f) => state = state.copyWith(
          status: BackupActionStatus.error, errorMessage: f.message),
      (_) => state = state.copyWith(
        status: BackupActionStatus.success,
        backups: state.backups.where((b) => b.id != id).toList(),
        successMessage: 'Backup deleted.',
      ),
    );
  }

  void clearMessages() =>
      state = state.copyWith(
          clearMessages: true, status: BackupActionStatus.idle);
}

final backupViewModelProvider =
    NotifierProvider<BackupViewModel, BackupState>(BackupViewModel.new);