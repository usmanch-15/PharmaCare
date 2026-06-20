import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/scan_result.dart';

class BarcodeScannerDataSource {
  const BarcodeScannerDataSource();

  Future<bool> hasPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  BarcodeFormat _mapFormat(BarcodeFormat format) {
    // mobile_scanner BarcodeFormat mapping
    return ScanBarcodeFormat.unknown;
  }

  ScanResult mapBarcode(Barcode barcode) {
    return ScanResult(
      rawValue: barcode.rawValue ?? '',
      format:   ScanBarcodeFormat.unknown,
      scannedAt: DateTime.now(),
    );
  }
}

// Alias to avoid conflict with mobile_scanner's BarcodeFormat
class ScanBarcodeFormat {
  static const unknown = BarcodeFormat.unknown;
}