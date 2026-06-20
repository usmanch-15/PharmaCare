import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id, required super.type, required super.title,
    required super.body, required super.createdAt,
    super.isRead, super.payload,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id:        doc.id,
      type:      NotificationType.fromString(d['type'] as String?),
      title:     d['title']   as String? ?? '',
      body:      d['body']    as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead:    d['isRead']  as bool? ?? false,
      payload:   (d['payload'] as Map<String, dynamic>?)
                   ?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type':      type.name,
    'title':     title,
    'body':      body,
    'isRead':    isRead,
    if (payload != null) 'payload': payload,
    'createdAt': FieldValue.serverTimestamp(),
  };
}