import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pharmacy_info.dart';
import '../providers/pdf_providers.dart';
import '../viewmodels/pdf_viewmodel.dart';
import '../widgets/pdf_action_buttons.dart';
import '../widgets/pdf_preview_widget.dart';

/// Full-screen PDF preview with download · share · print toolbar.
///
/// Navigate to this screen after generating an invoice:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => PdfViewerScreen(invoice: invoice),
/// ));
/// ```
class PdfViewerScreen extends ConsumerStatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.invoice,    // InvoiceEntity from Step 8
  });

  final dynamic invoice;

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-generate on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pharmacy = ref.read(pharmacyInfoProvider);
      ref.read(pdfViewModelProvider.notifier)
          .generatePdf(widget.invoice, pharmacy);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(pdfViewModelProvider);
    final pharmacy = ref.read(pharmacyInfoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation:       0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(pdfViewModelProvider.notifier).resetPdf();
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Invoice Preview',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              widget.invoice.invoiceNo,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF888888)),
            ),
          ],
        ),
        actions: [
          // Quick share button in appbar
          if (state.hasPdf)
            IconButton(
              icon: const Icon(Icons.share_rounded,
                  color: Color(0xFF7B1FA2)),
              tooltip: 'Share',
              onPressed: state.isLoading
                  ? null
                  : () => ref
                      .read(pdfViewModelProvider.notifier)
                      .sharePdf(widget.invoice, pharmacy),
            ),
          if (state.hasPdf)
            IconButton(
              icon: const Icon(Icons.print_rounded,
                  color: Color(0xFF2E7D32)),
              tooltip: 'Print',
              onPressed: state.isLoading
                  ? null
                  : () => ref
                      .read(pdfViewModelProvider.notifier)
                      .printPdf(widget.invoice, pharmacy),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── PDF preview area ─────────────────────────────────────────
          Expanded(
            child: _buildPreview(state),
          ),

          // ── Bottom action bar ────────────────────────────────────────
          if (state.hasPdf)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Invoice actions',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF888888))),
                          Text(
                            widget.invoice.invoiceNo,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888)),
                          ),
                        ],
                      ),
                    ),
                    PdfActionButtons(invoice: widget.invoice),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview(PdfState state) {
    if (state.status == PdfActionStatus.generating) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF1565C0)),
            SizedBox(height: 16),
            Text('Generating invoice…',
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF888888))),
          ],
        ),
      );
    }

    if (state.status == PdfActionStatus.error &&
        state.pdfBytes == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 44, color: Color(0xFFE53935)),
              const SizedBox(height: 12),
              const Text('Failed to generate invoice',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  final pharmacy =
                      ref.read(pharmacyInfoProvider);
                  ref
                      .read(pdfViewModelProvider.notifier)
                      .generatePdf(widget.invoice, pharmacy);
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0)),
              ),
            ],
          ),
        ),
      );
    }

    if (state.pdfBytes == null) {
      return const SizedBox.shrink();
    }

    return PdfPreviewWidget(pdfBytes: state.pdfBytes!);
  }
}