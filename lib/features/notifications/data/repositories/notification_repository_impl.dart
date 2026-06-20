import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._ds, this._fs);
  final NotificationDataSourceImpl _ds;
  final FirebaseFirestore _fs;

  Either<Failure, T> _h<T>(Object e) {
    if (e is ServerException) return Left(ServerFailure(e.message));
    return Left(UnexpectedFailure(e.toString()));
  }

  @override Future<Either<Failure, void>> initialize() async {
    try { await _ds.initialize(); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, void>> scheduleExpiryAlerts() async {
    try { await _ds.scheduleExpiryAlerts(_fs); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, void>> scheduleLowStockAlerts() async {
    try { await _ds.scheduleLowStockAlerts(_fs); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try { return Right(await _ds.getNotifications()); } catch (e) { return _h(e); }
  }
  @override Stream<Either<Failure, List<NotificationEntity>>> watchNotifications() =>
      _ds.watchNotifications()
         .map<Either<Failure, List<NotificationEntity>>>(Right.new)
         .handleError((e) => _h<List<NotificationEntity>>(e));
  @override Future<Either<Failure, void>> markAsRead(String id) async {
    try { await _ds.markAsRead(id); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, void>> markAllAsRead() async {
    try { await _ds.markAllAsRead(); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, void>> clearAll() async {
    try { await _ds.clearAll(); return const Right(null); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, bool>> hasPermission() async {
    try { return Right(await _ds.hasPermission()); } catch (e) { return _h(e); }
  }
  @override Future<Either<Failure, bool>> requestPermission() async =>
      const Right(true); // handled by OS prompt on first show
}