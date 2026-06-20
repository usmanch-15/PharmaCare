// ══════════════════════════════════════════════════════════════════════════════
// HOW TO INTEGRATE PDF GENERATION INTO InvoiceDetailScreen (Step 8)
// ══════════════════════════════════════════════════════════════════════════════
//
// FILE: lib/features/sales/presentation/screens/invoice_detail_screen.dart
//
// STEP 1 — Add imports:
// ─────────────────────────────────────────────────────────────────────────────
//   import '../../../pdf/screens/pdf_viewer_screen.dart';
//   import '../../../pdf/widgets/pdf_action_buttons.dart';
//
// STEP 2 — Add PDF button to AppBar actions (replace existing print icon):
// ─────────────────────────────────────────────────────────────────────────────
//   actions: [
//     IconButton(
//       icon: const Icon(Icons.picture_as_pdf_rounded,
//           color: Color(0xFF1565C0)),
//       tooltip: 'View / Download PDF',
//       onPressed: _invoice == null
//           ? null
//           : () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>
//                       PdfViewerScreen(invoice: _invoice!),
//                 ),
//               ),
//     ),
//   ],
//
// STEP 3 — Add quick action bar at bottom of _InvoiceBody:
// ─────────────────────────────────────────────────────────────────────────────
//   // Inside _InvoiceBody.build(), add after _buildThankYouBanner:
//
//   const SizedBox(height: 16),
//   Container(
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       border: Border.all(
//           color: Colors.black.withOpacity(0.06), width: 0.8),
//     ),
//     padding: const EdgeInsets.all(16),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Invoice actions',
//             style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF1A1A2E))),
//         const SizedBox(height: 12),
//         PdfActionButtons(invoice: invoice),
//       ],
//     ),
//   ),
//
// STEP 4 — Add PDF section to CartScreen after successful checkout:
// ─────────────────────────────────────────────────────────────────────────────
//   // In CartViewModel.checkout() success handler, the completedInvoice is
//   // already set. InvoiceDetailScreen auto-navigates there, and the PDF
//   // buttons are shown in the detail view — no extra work needed.
//
// STEP 5 — Optional: auto-generate PDF on checkout completion:
// ─────────────────────────────────────────────────────────────────────────────
//   // In _CartScreenState, inside ref.listen() success block:
//   if (next.completedInvoice != null) {
//     final pharmacy = ref.read(pharmacyInfoProvider);
//     ref.read(pdfViewModelProvider.notifier)
//         .generatePdf(next.completedInvoice!, pharmacy);
//     // PDF is now pre-generated before user taps 'View PDF'
//   }