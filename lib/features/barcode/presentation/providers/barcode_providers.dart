import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/barcode_datasource.dart';
import '../../data/repositories/barcode_repository_impl.dart';
import '../../domain/repositories/barcode_repository.dart';
import '../../domain/usecases/barcode_usecases.dart';

final barcodeDatasourceProvider =
    Provider((_) => const BarcodeScannerDataSource());
final barcodeRepositoryProvider = Provider<BarcodeRepository>(
    (ref) => BarcodeRepositoryImpl(ref.read(barcodeDatasourceProvider)));
final scanBarcodeUseCaseProvider =
    Provider((ref) => ScanBarcodeUseCase(ref.read(barcodeRepositoryProvider)));
final checkCameraPermProvider =
    Provider((ref) => CheckCameraPermissionUseCase(ref.read(barcodeRepositoryProvider)));
final requestCameraPermProvider =
    Provider((ref) => RequestCameraPermissionUseCase(ref.read(barcodeRepositoryProvider)));