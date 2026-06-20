import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.payload,
  });
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, String>? payload; // e.g. {'medicineId': 'xxx'}

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id, type: type, title: title, body: body,
        createdAt: createdAt, isRead: isRead ?? this.isRead, payload: payload);

  @override List<Object?> get props => [id, type, isRead, createdAt];
}

enum NotificationType {
  expiry('Expiry Alert'),
  lowStock('Low Stock Alert'),
  general('General');
  const NotificationType(this.label);
  final String label;
  static NotificationType fromString(String? v) =>
      NotificationType.values.firstWhere((e) => e.name == v,
          orElse: () => NotificationType.general);
}