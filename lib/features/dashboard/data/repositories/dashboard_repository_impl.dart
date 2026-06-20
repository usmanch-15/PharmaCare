import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

/// Concrete implementation of [DashboardRepository].
///
/// Catches all [ServerException] from the data source and maps them
/// to typed [Failure] objects before returning to the domain layer.
/// The domain layer never sees raw exceptions.
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final stats = await _remoteDataSource.getDashboardStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, DashboardStats>> watchDashboardStats() {
    return _remoteDataSource.watchDashboardStats().map<Either<Failure, DashboardStats>>(
      (stats) => Right(stats),
    ).handleError((error) {
      if (error is ServerException) {
        return Left(ServerFailure(error.message));
      }
      return Left(UnexpectedFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, int>> getLowStockCount() async {
    try {
      final count = await _remoteDataSource.getLowStockCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getExpiringCount({int withinDays = 30}) async {
    try {
      final count =
          await _remoteDataSource.getExpiringCount(withinDays: withinDays);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
