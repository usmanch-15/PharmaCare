import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scan_result.dart';

abstract class BarcodeRepository {
  /// Starts camera and returns a single scan result.
  Future<Either<Failure, ScanResult>> scan();
  Future<Either<Failure, bool>> hasPermission();
  Future<Either<Failure, bool>> requestPermission();
}