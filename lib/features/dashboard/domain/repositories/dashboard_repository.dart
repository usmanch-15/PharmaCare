import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_stats.dart';

/// Abstract contract for all dashboard data operations.
///
/// The domain layer depends ONLY on this interface.
/// [DashboardRepositoryImpl] in the data layer provides the implementation.
abstract class DashboardRepository {
  /// Fetches a complete snapshot of all dashboard KPIs.
  ///
  /// Runs multiple Firestore queries in parallel (Future.wait) for speed.
  /// Returns a fully populated [DashboardStats] entity on success.
  Future<Either<Failure, DashboardStats>> getDashboardStats();

  /// Returns a stream that re-emits updated stats whenever
  /// any underlying Firestore collection changes.
  ///
  /// Used for real-time dashboard updates without manual refresh.
  Stream<Either<Failure, DashboardStats>> watchDashboardStats();

  /// Fetches only the count of medicines below their reorder level.
  /// Used for the alert badge in the nav bar.
  Future<Either<Failure, int>> getLowStockCount();

  /// Fetches only the count of medicines expiring within [withinDays].
  Future<Either<Failure, int>> getExpiringCount({int withinDays = 30});
}
