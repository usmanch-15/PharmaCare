import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/notification_usecases.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

final localNotifPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>(
        (_) => FlutterLocalNotificationsPlugin());

final currentUserIdProvider = Provider<String>((_) => 'current_user_id');

final notificationDataSourceProvider =
    Provider<NotificationDataSourceImpl>((ref) => NotificationDataSourceImpl(
          ref.read(firestoreProvider),
          ref.read(localNotifPluginProvider),
          ref.read(currentUserIdProvider),
        ));

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) => NotificationRepositoryImpl(
          ref.read(notificationDataSourceProvider),
          ref.read(firestoreProvider),
        ));

final initNotificationsUseCaseProvider =
    Provider((ref) => InitNotificationsUseCase(ref.read(notificationRepositoryProvider)));
final scheduleExpiryUseCaseProvider =
    Provider((ref) => ScheduleExpiryAlertsUseCase(ref.read(notificationRepositoryProvider)));
final scheduleLowStockUseCaseProvider =
    Provider((ref) => ScheduleLowStockAlertsUseCase(ref.read(notificationRepositoryProvider)));
final getNotificationsUseCaseProvider =
    Provider((ref) => GetNotificationsUseCase(ref.read(notificationRepositoryProvider)));
final watchNotificationsUseCaseProvider =
    Provider((ref) => WatchNotificationsUseCase(ref.read(notificationRepositoryProvider)));
final markAsReadUseCaseProvider =
    Provider((ref) => MarkAsReadUseCase(ref.read(notificationRepositoryProvider)));
final markAllAsReadUseCaseProvider =
    Provider((ref) => MarkAllAsReadUseCase(ref.read(notificationRepositoryProvider)));