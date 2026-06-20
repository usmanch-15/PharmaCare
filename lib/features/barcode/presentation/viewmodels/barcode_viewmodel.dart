import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/scan_result.dart';
import '../providers/barcode_providers.dart';

enum ScanStatus { idle, requesting, scanning, success, error, noPermission }

class BarcodeState {
  const BarcodeState({
    this.status = ScanStatus.idle,
    this.lastScan, this.errorMessage,
  });
  final ScanStatus  status;
  final ScanResult? lastScan;
  final String?     errorMessage;
  bool get isScanning => status == ScanStatus.scanning;
  BarcodeState copyWith({
    ScanStatus? status, ScanResult? lastScan,
    String? errorMessage, bool clearError = false,
  }) => BarcodeState(
    status: status ?? this.status,
    lastScan: lastScan ?? this.lastScan,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class BarcodeViewModel extends Notifier<BarcodeState> {
  @override BarcodeState build() => const BarcodeState();

  Future<bool> checkAndRequestPermission() async {
    state = state.copyWith(status: ScanStatus.requesting);
    final hasPerm = await ref
        .read(checkCameraPermProvider)(const NoParams());
    final granted = hasPerm.fold((_) => false, (v) => v);
    if (granted) {
      state = state.copyWith(status: ScanStatus.idle);
      return true;
    }
    final req = await ref
        .read(requestCameraPermProvider)(const NoParams());
    final ok = req.fold((_) => false, (v) => v);
    state = state.copyWith(
        status: ok ? ScanStatus.idle : ScanStatus.noPermission);
    return ok;
  }

  void onBarcodeDetected(ScanResult result) {
    state = state.copyWith(
        status: ScanStatus.success, lastScan: result);
  }

  void reset() => state = const BarcodeState();
}

final barcodeViewModelProvider =
    NotifierProvider<BarcodeViewModel, BarcodeState>(BarcodeViewModel.new);