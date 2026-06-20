import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entities/scan_result.dart';
import '../viewmodels/barcode_viewmodel.dart';

/// Full-screen barcode scanner overlay.
/// Returns the scanned barcode via [onScan] callback.
///
/// Usage in POSScreen:
/// ```dart
/// await showDialog(
///   context: context,
///   builder: (_) => BarcodeScannerWidget(
///     onScan: (result) => vm.searchByBarcode(result.rawValue),
///   ),
/// );
/// ```
class BarcodeScannerWidget extends ConsumerStatefulWidget {
  const BarcodeScannerWidget({super.key, required this.onScan});
  final ValueChanged<ScanResult> onScan;

  @override
  ConsumerState<BarcodeScannerWidget> createState() =>
      _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState
    extends ConsumerState<BarcodeScannerWidget> {
  late MobileScannerController _ctrl;
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _ctrl = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('Scan barcode'),
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
              onPressed: _ctrl.toggleTorch,
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: _ctrl,
              onDetect: (capture) {
                if (_scanned) return;
                final barcode = capture.barcodes.firstOrNull;
                if (barcode == null || barcode.rawValue == null) return;
                _scanned = true;
                final result = ScanResult(
                  rawValue:  barcode.rawValue!,
                  format:    BarcodeFormat.unknown,
                  scannedAt: DateTime.now(),
                );
                widget.onScan(result);
                ref.read(barcodeViewModelProvider.notifier)
                    .onBarcodeDetected(result);
                Navigator.pop(context);
              },
            ),
            // Scan overlay
            Center(
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1565C0), width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Align barcode here',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}