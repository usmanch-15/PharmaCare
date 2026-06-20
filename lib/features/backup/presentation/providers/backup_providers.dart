import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/backup_datasource.dart';
import '../../data/repositories/backup_repository_impl.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/usecases/backup_usecases.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
final firebaseStorageProvider =
    Provider<FirebaseStorage>((_) => FirebaseStorage.instance);
final currentUserIdProvider = Provider<String>((_) => 'current_user_id');

final backupDataSourceProvider = Provider((ref) => BackupDataSource(
      ref.read(firestoreProvider),
      ref.read(firebaseStorageProvider),
      ref.read(currentUserIdProvider),
    ));

final backupRepositoryProvider = Provider<BackupRepository>(
    (ref) => BackupRepositoryImpl(ref.read(backupDataSourceProvider)));

final createBackupUseCaseProvider =
    Provider((ref) => CreateBackupUseCase(ref.read(backupRepositoryProvider)));
final restoreBackupUseCaseProvider =
    Provider((ref) => RestoreBackupUseCase(ref.read(backupRepositoryProvider)));
final getBackupHistoryUseCaseProvider =
    Provider((ref) => GetBackupHistoryUseCase(ref.read(backupRepositoryProvider)));
final deleteBackupUseCaseProvider =
    Provider((ref) => DeleteBackupUseCase(ref.read(backupRepositoryProvider)));