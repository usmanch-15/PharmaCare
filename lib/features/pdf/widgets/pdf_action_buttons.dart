import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pharmacy_info.dart';
import '../providers/pdf_providers.dart';
import '../viewmodels/pdf_viewmodel.dart';

/// Drop-in widget showing Download · Share · Print buttons.
///
/// Usage in InvoiceDetailScreen:
/// ```dart
/// PdfActionButtons(invoice: invoice)
/// ```
class PdfActionButtons extends ConsumerWidget {
  const PdfActionButtons({
    super.key,
    required this.invoice,
    this.layout = PdfButtonLayout.row,
  });

  /// Pass your InvoiceEntity from Step 8.
  final dynamic invoice;
  final PdfButtonLayout layout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(pdfViewModelProvider);
    final vm       = ref.read(pdfViewModelProvider.notifier);
    final pharmacy = ref.read(pharmacyInfoProvider);

    // Show snackbar on success/error
    ref.listen(pdfViewModelProvider, (_, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(next.successMessage!),
          ]),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          action: next.savedFile != null
              ? SnackBarAction(
                  label: 'Open',
                  textColor: Colors.white,
                  onPressed: vm.openSavedFile,
                )
              : null,
        ));
        vm.clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
        vm.clearMessages();
      }
    });

    final buttons = [
      _PdfButton(
        icon:    Icons.download_rounded,
        label:   'Download',
        color:   const Color(0xFF1565C0),
        loading: state.status == PdfActionStatus.saving,
        onTap:   state.isLoading
            ? null
            : () => vm.downloadPdf(invoice, pharmacy),
      ),
      _PdfButton(
        icon:    Icons.share_rounded,
        label:   'Share',
        color:   const Color(0xFF7B1FA2),
        loading: state.status == PdfActionStatus.sharing,
        onTap:   state.isLoading
            ? null
            : () => vm.sharePdf(invoice, pharmacy),
      ),
      _PdfButton(
        icon:    Icons.print_rounded,
        label:   'Print',
        color:   const Color(0xFF2E7D32),
        loading: state.status == PdfActionStatus.printing,
        onTap:   state.isLoading
            ? null
            : () => vm.printPdf(invoice, pharmacy),
      ),
    ];

    if (layout == PdfButtonLayout.row) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons
            .expand((b) => [b, const SizedBox(width: 12)])
            .toList()
          ..removeLast(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons
          .expand((b) => [b, const SizedBox(height: 10)])
          .toList()
        ..removeLast(),
    );
  }
}

enum PdfButtonLayout { row, column }

class _PdfButton extends StatelessWidget {
  const _PdfButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  final IconData     icon;
  final String       label;
  final Color        color;
  final bool         loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: onTap == null
                ? Colors.grey.withOpacity(0.1)
                : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: onTap == null
                  ? Colors.grey.withOpacity(0.2)
                  : color.withOpacity(0.3),
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              loading
                  ? SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Icon(icon, color: color, size: 22),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                  color: onTap == null ? Colors.grey : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}