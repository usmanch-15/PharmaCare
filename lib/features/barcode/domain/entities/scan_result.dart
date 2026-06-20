import 'package:equatable/equatable.dart';

class ScanResult extends Equatable {
  const ScanResult({
    required this.rawValue,
    required this.format,
    required this.scannedAt,
  });
  final String rawValue;
  final BarcodeFormat format;
  final DateTime scannedAt;
  bool get isEmpty => rawValue.trim().isEmpty;
  @override List<Object?> get props => [rawValue, format];
}

enum BarcodeFormat { qrCode, ean13, ean8, code128, code39, unknown }