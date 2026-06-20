import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Design tokens for the pharmacy invoice PDF.
/// Change these to rebrand the entire invoice.
class InvoiceTemplate {

  // ── Colors ──────────────────────────────────────────────────────────────
  static const primary        = PdfColor.fromInt(0xFF1565C0);   // deep blue
  static const primaryLight   = PdfColor.fromInt(0xFFE3F2FD);
  static const accent         = PdfColor.fromInt(0xFF2E7D32);   // green (paid)
  static const danger         = PdfColor.fromInt(0xFFE53935);   // red (return)
  static const warning        = PdfColor.fromInt(0xFFFF9800);   // orange (credit)
  static const textDark       = PdfColor.fromInt(0xFF1A1A2E);
  static const textMid        = PdfColor.fromInt(0xFF555555);
  static const textLight      = PdfColor.fromInt(0xFF888888);
  static const borderColor    = PdfColor.fromInt(0xFFE0E0E0);
  static const tableHeaderBg  = PdfColor.fromInt(0xFF1565C0);
  static const tableAltRow    = PdfColor.fromInt(0xFFF5F9FF);
  static const white          = PdfColors.white;
  static const pageBackground = PdfColors.white;

  // ── Typography ───────────────────────────────────────────────────────────
  static const fontSizeTitle    = 20.0;
  static const fontSizeSubtitle = 12.0;
  static const fontSizeBody     = 9.5;
  static const fontSizeSmall    = 8.0;
  static const fontSizeTiny     = 7.5;

  // ── Spacing ──────────────────────────────────────────────────────────────
  static const pageMargin     = pw.EdgeInsets.all(32);
  static const sectionSpacing = 16.0;
  static const cellPadding    = pw.EdgeInsets.symmetric(
      horizontal: 8, vertical: 6);

  // ── Table column widths (flex units) ────────────────────────────────────
  static const colFlexNo       = 1;
  static const colFlexName     = 5;
  static const colFlexBatch    = 2;
  static const colFlexExpiry   = 2;
  static const colFlexQty      = 1;
  static const colFlexUnit     = 2;
  static const colFlexDisc     = 1;
  static const colFlexTotal    = 2;

  // ── Border radius ────────────────────────────────────────────────────────
  static const radius = pw.BorderRadius.all(pw.Radius.circular(6));
}