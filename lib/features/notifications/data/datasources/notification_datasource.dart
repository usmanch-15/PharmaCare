import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

class NotificationDataSourceImpl {
  NotificationDataSourceImpl(this._fs, this._localNotif, this._userId);
  final FirebaseFirestore _fs;
  final FlutterLocalNotificationsPlugin _localNotif;
  final String _userId;

  CollectionReference<Map<String, dynamic>> get _col =>
      _fs.collection('users').doc(_userId).collection('notifications');

  // ── Init local notifications ──────────────────────────────────────────────
  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<bool> hasPermission() async {
    final result = await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return result ?? true;
  }

  // ── Show local notification + store in Firestore ──────────────────────────
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required NotificationType type,
    Map<String, String>? payload,
  }) async {
    try {
      // Local push
      await _localNotif.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pharma_alerts', 'Pharmacy Alerts',
            channelDescription: 'Expiry and low-stock alerts',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(badgeNumber: 1),
        ),
        payload: payload?.entries.map((e) => '${e.key}=${e.value}').join(','),
      );
      // Store in Firestore notification feed
      final model = NotificationModel(
        id:        '',
        type:      type,
        title:     title,
        body:      body,
        createdAt: DateTime.now(),
        payload:   payload,
      );
      await _col.add(model.toFirestore());
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Schedule daily expiry check ───────────────────────────────────────────
  Future<void> scheduleExpiryAlerts(FirebaseFirestore fs) async {
    try {
      final threshold = DateTime.now().add(const Duration(days: 30));
      final snap = await fs
          .collection('batches')
          .where('status', isEqualTo: 'active')
          .where('qtyAvailable', isGreaterThan: 0)
          .where('expiryDate',
              isLessThanOrEqualTo: Timestamp.fromDate(threshold))
          .orderBy('expiryDate')
          .limit(20)
          .get();

      for (final doc in snap.docs) {
        final d        = doc.data();
        final tradeName = d['tradeName'] as String? ?? 'Medicine';
        final expDate   = (d['expiryDate'] as Timestamp?)?.toDate();
        final daysLeft  = expDate?.difference(DateTime.now()).inDays ?? 0;
        if (daysLeft < 0) continue;

        await showNotification(
          id:      doc.id.hashCode,
          title:   'Expiry Alert 🔴',
          body:    '$tradeName expires in $daysLeft day${daysLeft == 1 ? '' : 's'}!',
          type:    NotificationType.expiry,
          payload: {'medicineId': d['medicineId'] as String? ?? ''},
        );
      }
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── Schedule low stock check ──────────────────────────────────────────────
  Future<void> scheduleLowStockAlerts(FirebaseFirestore fs) async {
    try {
      final snap = await fs
          .collection('medicines')
          .where('isActive', isEqualTo: true)
          .where('isLowStock', isEqualTo: true)
          .limit(20)
          .get();

      for (final doc in snap.docs) {
        final d         = doc.data();
        final tradeName = d['tradeName'] as String? ?? 'Medicine';
        final reorder   = (d['reorderLevel'] as num?)?.toInt() ?? 10;
        await showNotification(
          id:      (doc.id + 'low').hashCode,
          title:   'Low Stock ⚠️',
          body:    '$tradeName is below reorder level ($reorder units).',
          type:    NotificationType.lowStock,
          payload: {'medicineId': doc.id},
        );
      }
    } on Exception catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ── In-app feed ───────────────────────────────────────────────────────────
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final snap = await _col
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      return snap.docs.map(NotificationModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Stream<List<NotificationModel>> watchNotifications() =>
      _col.orderBy('createdAt', descending: true).limit(50).snapshots().map(
          (s) => s.docs.map(NotificationModel.fromFirestore).toList());

  Future<void> markAsRead(String id) async {
    try {
      await _col.doc(id).update({'isRead': true});
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final snap = await _col.where('isRead', isEqualTo: false).get();
      final batch = _fs.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }

  Future<void> clearAll() async {
    try {
      final snap = await _col.get();
      final batch = _fs.batch();
      for (final doc in snap.docs) batch.delete(doc.reference);
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message);
    }
  }
}