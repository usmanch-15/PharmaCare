import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/backup_entity.dart';
import '../viewmodels/backup_viewmodel.dart';

class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupViewModelProvider);
    final vm    = ref.read(backupViewModelProvider.notifier);

    ref.listen(backupViewModelProvider, (_, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMessage!),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        vm.clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        vm.clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Backup & Restore',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: vm.loadHistory),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Create backup card ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.cloud_upload_rounded,
                    color: Colors.white, size: 32),
                const SizedBox(height: 10),
                const Text('Create backup',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                const Text(
                  'Exports all data to Firebase Storage as JSON.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                if (state.status == BackupActionStatus.creating) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.progress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(state.progress * 100).toStringAsFixed(0)}% complete',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70),
                  ),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: state.isLoading ? null : vm.createBackup,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.backup_rounded, size: 16),
                      label: const Text('Backup now',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Backup history ──────────────────────────────────────────
          if (state.backups.isNotEmpty) ...[
            const Text('Backup history',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
            ...state.backups.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BackupTile(
                    backup: b,
                    onDelete: () => _confirmDelete(context, vm, b),
                  ),
                )),
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 44, color: Color(0xFFCCCCCC)),
                    SizedBox(height: 12),
                    Text('No backups yet',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF888888))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, BackupViewModel vm, BackupEntity backup) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete backup?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Delete ${backup.fileName}? This cannot be undone.',
            style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            onPressed: () { Navigator.pop(context); vm.deleteBackup(backup.id); },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BackupTile extends StatelessWidget {
  const _BackupTile({required this.backup, required this.onDelete});
  final BackupEntity backup;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (backup.status) {
      BackupStatus.completed  => const Color(0xFF2E7D32),
      BackupStatus.failed     => const Color(0xFFE53935),
      BackupStatus.inProgress => const Color(0xFF1565C0),
      _                       => const Color(0xFF888888),
    };
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.8),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.folder_zip_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(backup.fileName,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  DateFormat('d MMM yyyy · h:mm a').format(backup.createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888)),
                ),
                Text(backup.formattedSize,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFFBBBBBB))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(backup.status.label,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: Color(0xFFE53935)),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}