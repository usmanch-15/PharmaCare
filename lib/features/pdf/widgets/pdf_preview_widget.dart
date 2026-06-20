import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Inline PDF preview using the `printing` package PdfPreview widget.
/// Drop into any screen to show a scrollable rendered preview.
class PdfPreviewWidget extends StatelessWidget {
  const PdfPreviewWidget({
    super.key,
    required this.pdfBytes,
    this.maxPageWidth = 600,
  });

  final Uint8List pdfBytes;
  final double maxPageWidth;

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      maxPageWidth: maxPageWidth,
      build: (_) async => pdfBytes,
      allowPrinting:  false,   // handled by PdfActionButtons
      allowSharing:   false,
      canChangePageFormat: false,
      canChangeOrientation: false,
      pdfPreviewPageDecoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}