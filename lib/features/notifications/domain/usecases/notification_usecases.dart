import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class InitNotificationsUseCase implements UseCase<void, NoParams> {
  const InitNotificationsUseCase(this._repo);
  final NotificationRepository _repo;
  @override
  Future<Either<Failure, void>> call(NoParams _) => _repo.initialize();
}

class ScheduleExpiryAlertsUseCase implements UseCase<void, NoParams> {
  const ScheduleExpiryAlertsUseCase(this._repo);
  final NotificationRepository _repo;
  @override
  Future<Either<Failure, void>> call(NoParams _) => _repo.scheduleExpiryAlerts();
}

class ScheduleLowStockAlertsUseCase implements UseCase<void, NoParams> {
  const ScheduleLowStockAlertsUseCase(this._repo);
  final NotificationRepository _repo;
  @override
  Future<Either<Failure, void>> call(NoParams _) => _repo.scheduleLowStockAlerts();
}

class GetNotificationsUseCase implements UseCase<List<NotificationEntity>, NoParams> {
  const GetNotificationsUseCase(this._repo);
  final NotificationRepository _repo;
  @override
  Future<Either<Failure, List<NotificationEntity>>> call(NoParams _) =>
      _repo.getNotifications();
}

class WatchNotificationsUseCase implements StreamUseCase<List<NotificationEntity>, NoParams> {
  const WatchNotificationsUseCase(this._repo);
  final NotificationRepository _repo;
  @override
  Stream<Either<Failure, List<NotificationEntity>>> call(NoParams _) =>
      _repo.watchNotifications();
}

class MarkAsReadUseCase implements UseCase<void, MarkAsReadParams> {
  const MarkAsReadUseCase(this._repo);
  final NotificationRepository _repo;
  @override
  Future<Either<Failure, void>> call(MarkAsReadParams p) => _repo.markAsRead(p.id);
}

class MarkAllAsReadUseCase implements UseCase<void, NoParams> {
  const MarkAllAsReadUseCase(this._repo);
  final NotificationRepository _repo;
  @override
  Future<Either<Failure, void>> call(NoParams _) => _repo.markAllAsRead();
}

class MarkAsReadParams extends Equatable {
  const MarkAsReadParams(this.id);
  final String id;
  @override List<Object> get props => [id];
}