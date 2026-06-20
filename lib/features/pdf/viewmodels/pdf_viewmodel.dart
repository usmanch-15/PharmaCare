import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/pdf_service.dart';
import '../generators/invoice_pdf_generator.dart';
import '../models/pharmacy_info.dart';
import '../providers/pdf_providers.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum PdfActionStatus { idle, generating, saving, sharing, printing, success, error }

class PdfState {
  const PdfState({
    this.status      = PdfActionStatus.idle,
    this.pdfBytes,
    this.savedFile,
    this.errorMessage,
    this.successMessage,
    this.currentInvoiceNo,
  });

  final PdfActionStatus status;
  final Uint8List?       pdfBytes;
  final File?            savedFile;
  final String?          errorMessage;
  final String?          successMessage;
  final String?          currentInvoiceNo;

  bool get isLoading =>
      status == PdfActionStatus.generating ||
      status == PdfActionStatus.saving    ||
      status == PdfActionStatus.sharing   ||
      status == PdfActionStatus.printing;

  bool get hasPdf => pdfBytes != null;

  PdfState copyWith({
    PdfActionStatus? status,
    Uint8List?       pdfBytes,
    File?            savedFile,
    String?          errorMessage,
    String?          successMessage,
    String?          currentInvoiceNo,
    bool             clearMessages = false,
  }) {
    return PdfState(
      status:           status            ?? this.status,
      pdfBytes:         pdfBytes          ?? this.pdfBytes,
      savedFile:        savedFile         ?? this.savedFile,
      errorMessage:     clearMessages ? null : errorMessage    ?? this.errorMessage,
      successMessage:   clearMessages ? null : successMessage  ?? this.successMessage,
      currentInvoiceNo: currentInvoiceNo  ?? this.currentInvoiceNo,
    );
  }
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class PdfViewModel extends Notifier<PdfState> {
  late InvoicePdfGenerator _generator;
  late PdfService          _service;

  @override
  PdfState build() {
    _generator = ref.read(invoicePdfGeneratorProvider);
    _service   = ref.read(pdfServiceProvider);
    return const PdfState();
  }

  // ── Generate PDF bytes ────────────────────────────────────────────────────

  Future<Uint8List?> generatePdf(
    dynamic invoice,       // InvoiceEntity from Step 8
    PharmacyInfo pharmacy,
  ) async {
    state = state.copyWith(
      status:           PdfActionStatus.generating,
      currentInvoiceNo: invoice.invoiceNo,
      clearMessages:    true,
    );

    try {
      final bytes = await _generator.generate(invoice, pharmacy);
      state = state.copyWith(
        status:   PdfActionStatus.success,
        pdfBytes: bytes,
      );
      return bytes;
    } catch (e) {
      state = state.copyWith(
        status:       PdfActionStatus.error,
        errorMessage: 'Failed to generate PDF: ${e.toString()}',
      );
      return null;
    }
  }

  // ── Download / save to device ─────────────────────────────────────────────

  Future<File?> downloadPdf(
    dynamic invoice,
    PharmacyInfo pharmacy,
  ) async {
    final bytes = state.hasPdf
        ? state.pdfBytes!
        : await generatePdf(invoice, pharmacy);

    if (bytes == null) return null;

    state = state.copyWith(status: PdfActionStatus.saving);
    try {
      final fileName = _fileName(invoice.invoiceNo);
      final file     = await _service.saveToFile(
          pdfBytes: bytes, fileName: fileName);
      state = state.copyWith(
        status:         PdfActionStatus.success,
        savedFile:      file,
        successMessage: 'Invoice saved to Downloads.',
      );
      return file;
    } catch (e) {
      state = state.copyWith(
        status:       PdfActionStatus.error,
        errorMessage: 'Failed to save PDF: ${e.toString()}',
      );
      return null;
    }
  }

  // ── Share via system sheet ────────────────────────────────────────────────

  Future<void> sharePdf(
    dynamic invoice,
    PharmacyInfo pharmacy,
  ) async {
    final bytes = state.hasPdf
        ? state.pdfBytes!
        : await generatePdf(invoice, pharmacy);

    if (bytes == null) return;

    state = state.copyWith(status: PdfActionStatus.sharing);
    try {
      await _service.sharePdf(
        pdfBytes: bytes,
        fileName: _fileName(invoice.invoiceNo),
        subject:  'Invoice ${invoice.invoiceNo} — ${pharmacy.name}',
      );
      state = state.copyWith(status: PdfActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status:       PdfActionStatus.error,
        errorMessage: 'Failed to share: ${e.toString()}',
      );
    }
  }

  // ── Print ─────────────────────────────────────────────────────────────────

  Future<void> printPdf(
    dynamic invoice,
    PharmacyInfo pharmacy,
  ) async {
    final bytes = state.hasPdf
        ? state.pdfBytes!
        : await generatePdf(invoice, pharmacy);

    if (bytes == null) return;

    state = state.copyWith(status: PdfActionStatus.printing);
    try {
      await _service.printPdf(
        pdfBytes:     bytes,
        documentName: invoice.invoiceNo,
      );
      state = state.copyWith(status: PdfActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status:       PdfActionStatus.error,
        errorMessage: 'Failed to print: ${e.toString()}',
      );
    }
  }

  // ── Open saved file ───────────────────────────────────────────────────────

  Future<void> openSavedFile() async {
    if (state.savedFile == null) return;
    try {
      await _service.openFile(state.savedFile!);
    } catch (e) {
      state = state.copyWith(
        status:       PdfActionStatus.error,
        errorMessage: 'Could not open file: ${e.toString()}',
      );
    }
  }

  void clearMessages() => state = state.copyWith(
      clearMessages: true, status: PdfActionStatus.idle);

  void resetPdf() => state = const PdfState();

  String _fileName(String invoiceNo) =>
      '${invoiceNo.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.pdf';
}

final pdfViewModelProvider =
    NotifierProvider<PdfViewModel, PdfState>(PdfViewModel.new);