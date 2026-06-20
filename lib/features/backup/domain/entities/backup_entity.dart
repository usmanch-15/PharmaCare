import 'package:equatable/equatable.dart';

class BackupEntity extends Equatable {
  const BackupEntity({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.sizeBytes,
    required this.status,
    required this.createdBy,
    this.downloadUrl,
    this.branchId,
    this.collectionsIncluded = const [],
  });

  final String id;
  final String fileName;
  final DateTime createdAt;
  final int sizeBytes;
  final BackupStatus status;
  final String createdBy;
  final String? downloadUrl;
  final String? branchId;
  final List<String> collectionsIncluded;

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override List<Object?> get props => [id, fileName, createdAt, status];
}

enum BackupStatus {
  pending('Pending'),
  inProgress('In progress'),
  completed('Completed'),
  failed('Failed'),
  restoring('Restoring');

  const BackupStatus(this.label);
  final String label;
  static BackupStatus fromString(String? v) =>
      BackupStatus.values.firstWhere((e) => e.name == v,
          orElse: () => BackupStatus.pending);
}