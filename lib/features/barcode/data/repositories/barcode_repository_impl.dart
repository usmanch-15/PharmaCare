import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../datasources/barcode_datasource.dart';

class BarcodeRepositoryImpl implements BarcodeRepository {
  const BarcodeRepositoryImpl(this._ds);
  final BarcodeScannerDataSource _ds;

  Either<Failure, T> _h<T>(Object e) {
    if (e is PermissionException) {
      return Left(PermissionFailure(e.message ?? 'Permission denied'));
    }
    return Left(UnexpectedFailure(e.toString()));
  }

  @override
  Future<Either<Failure, bool>> hasPermission() async {
    try { return Right(await _ds.hasPermission()); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try { return Right(await _ds.requestPermission()); }
    catch (e) { return _h(e); }
  }

  @override
  Future<Either<Failure, ScanResult>> scan() async {
    return const Left(UnexpectedFailure(
        'Use BarcodeScannerWidget for scanning.'));
  }
}