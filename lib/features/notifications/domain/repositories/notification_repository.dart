import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> initialize();
  Future<Either<Failure, void>> scheduleExpiryAlerts();
  Future<Either<Failure, void>> scheduleLowStockAlerts();
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();
  Stream<Either<Failure, List<NotificationEntity>>> watchNotifications();
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> clearAll();
  Future<Either<Failure, bool>> hasPermission();
  Future<Either<Failure, bool>> requestPermission();
}