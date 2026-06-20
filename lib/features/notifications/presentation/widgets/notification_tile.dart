import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notif, this.onTap});
  final NotificationEntity notif;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = notif.type == NotificationType.expiry
        ? const Color(0xFFF44336)
        : notif.type == NotificationType.lowStock
            ? const Color(0xFFFF9800)
            : const Color(0xFF1565C0);
    final icon = notif.type == NotificationType.expiry
        ? Icons.hourglass_bottom_rounded
        : notif.type == NotificationType.lowStock
            ? Icons.warning_amber_rounded
            : Icons.notifications_rounded;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: notif.isRead ? null : color.withOpacity(0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(notif.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: notif.isRead
                                ? FontWeight.w500 : FontWeight.w700,
                          )),
                    ),
                    if (!notif.isRead)
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                  ]),
                  const SizedBox(height: 2),
                  Text(notif.body,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF888888))),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM · h:mm a').format(notif.createdAt),
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFFBBBBBB)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key, required this.count, required this.child});
  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4, right: -4,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
                color: Color(0xFFF44336), shape: BoxShape.circle),
            child: Text(
              count > 9 ? '9+' : '$count',
              style: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}