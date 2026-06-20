import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/scan_result.dart';
import '../repositories/barcode_repository.dart';

class ScanBarcodeUseCase implements UseCase<ScanResult, NoParams> {
  const ScanBarcodeUseCase(this._repo);
  final BarcodeRepository _repo;
  @override
  Future<Either<Failure, ScanResult>> call(NoParams _) => _repo.scan();
}

class CheckCameraPermissionUseCase implements UseCase<bool, NoParams> {
  const CheckCameraPermissionUseCase(this._repo);
  final BarcodeRepository _repo;
  @override
  Future<Either<Failure, bool>> call(NoParams _) => _repo.hasPermission();
}

class RequestCameraPermissionUseCase implements UseCase<bool, NoParams> {
  const RequestCameraPermissionUseCase(this._repo);
  final BarcodeRepository _repo;
  @override
  Future<Either<Failure, bool>> call(NoParams _) => _repo.requestPermission();
}