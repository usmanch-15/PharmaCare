import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../widgets/notification_tile.dart';

class NotificationListScreen extends ConsumerWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationViewModelProvider);
    final vm    = ref.read(notificationViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: vm.markAllAsRead,
              child: const Text('Mark all read',
                  style: TextStyle(fontSize: 12)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.checkAlerts,
          ),
        ],
      ),
      body: state.notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 44, color: Color(0xFFCCCCCC)),
                  SizedBox(height: 10),
                  Text('No notifications yet',
                      style: TextStyle(
                          fontSize: 14, color: Color(0xFF888888))),
                ],
              ),
            )
          : ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.black.withOpacity(0.05)),
              itemBuilder: (_, i) => NotificationTile(
                notif: state.notifications[i],
                onTap: () => vm.markAsRead(state.notifications[i].id),
              ),
            ),
    );
  }
}