import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

/// Fetches a one-time snapshot of all dashboard KPIs.
///
/// Called on screen load and on manual refresh (pull-to-refresh / button).
/// Uses [NoParams] — no input required.
class GetDashboardStatsUseCase implements UseCase<DashboardStats, NoParams> {
  const GetDashboardStatsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams _) {
    return _repository.getDashboardStats();
  }
}

/// Streams real-time dashboard stat updates.
///
/// Emits a new [DashboardStats] whenever any watched Firestore
/// collection (invoices, medicines, customers) changes.
class WatchDashboardStatsUseCase
    implements StreamUseCase<DashboardStats, NoParams> {
  const WatchDashboardStatsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Stream<Either<Failure, DashboardStats>> call(NoParams _) {
    return _repository.watchDashboardStats();
  }
}

/// Fetches only the low-stock alert count for badge display.
class GetLowStockCountUseCase implements UseCase<int, NoParams> {
  const GetLowStockCountUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams _) {
    return _repository.getLowStockCount();
  }
}

/// Fetches the expiring medicines count with a configurable day window.
class GetExpiringCountUseCase implements UseCase<int, ExpiringCountParams> {
  const GetExpiringCountUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, int>> call(ExpiringCountParams params) {
    return _repository.getExpiringCount(withinDays: params.withinDays);
  }
}

class ExpiringCountParams extends Equatable {
  const ExpiringCountParams({this.withinDays = 30});
  final int withinDays;

  @override
  List<Object> get props => [withinDays];
}
