import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/pharmacy_info.dart';
import '../templates/invoice_template.dart';

class InvoicePdfGenerator {
  const InvoicePdfGenerator();

  static final _currFmt  = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);
  static final _currFmt0 = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);

  Future<Uint8List> generate(dynamic invoice, PharmacyInfo pharmacy) async {
    final pdf = pw.Document(
      title:   invoice.invoiceNo,
      author:  pharmacy.name,
      creator: 'PharmaCare App',
    );

    final baseFont   = await _loadFont(pw.Font.helvetica());
    final boldFont   = await _loadFont(pw.Font.helveticaBold());
    final italicFont = await _loadFont(pw.Font.helveticaOblique());

    final theme = pw.ThemeData.withFont(
      base:   baseFont,
      bold:   boldFont,
      italic: italicFont,
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: _pageTheme(theme),
        header:    (ctx) => _buildHeader(ctx, pharmacy, invoice),
        footer:    (ctx) => _buildFooter(ctx, pharmacy, invoice),
        build:     (ctx) => [
          _buildCustomerSection(invoice),
          pw.SizedBox(height: InvoiceTemplate.sectionSpacing),
          _buildItemsTable(invoice),
          pw.SizedBox(height: InvoiceTemplate.sectionSpacing),
          _buildTotalsSection(invoice),
          pw.SizedBox(height: InvoiceTemplate.sectionSpacing),
          _buildPaymentSection(invoice),
          if (invoice.notes != null && invoice.notes!.isNotEmpty)
            _buildNotesSection(invoice.notes!),
          pw.SizedBox(height: 24),
          _buildThankYouBanner(pharmacy),
        ],
      ),
    );

    return pdf.save();
  }

  pw.PageTheme _pageTheme(pw.ThemeData theme) {
    return pw.PageTheme(
      theme:      theme,
      pageFormat: PdfPageFormat.a4,
      margin:     InvoiceTemplate.pageMargin,
      buildBackground: (ctx) => pw.Container(
        decoration: pw.BoxDecoration(color: InvoiceTemplate.pageBackground),
      ),
    );
  }

  pw.Widget _buildHeader(pw.Context ctx, PharmacyInfo pharmacy, dynamic invoice) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(
            color:        InvoiceTemplate.primary,
            borderRadius: InvoiceTemplate.radius,
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(pharmacy.name,
                      style: pw.TextStyle(
                        color:      InvoiceTemplate.white,
                        fontSize:   InvoiceTemplate.fontSizeTitle,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  if (pharmacy.tagline != null)
                    pw.Text(pharmacy.tagline!,
                        style: pw.TextStyle(
                          color:     InvoiceTemplate.white.shade(0.7),
                          fontSize:  InvoiceTemplate.fontSizeSmall,
                          fontStyle: pw.FontStyle.italic,
                        )),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('INVOICE',
                      style: pw.TextStyle(
                        color:         InvoiceTemplate.white,
                        fontSize:      InvoiceTemplate.fontSizeTitle,
                        fontWeight:    pw.FontWeight.bold,
                        letterSpacing: 2,
                      )),
                  pw.Text(invoice.invoiceNo,
                      style: pw.TextStyle(
                        color:    InvoiceTemplate.white.shade(0.85),
                        fontSize: InvoiceTemplate.fontSizeSubtitle,
                      )),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoText(pharmacy.address),
                _infoText('📞 ${pharmacy.phone}'),
                _infoText('✉ ${pharmacy.email}'),
                if (pharmacy.website != null)
                  _infoText('🌐 ${pharmacy.website!}'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _infoText('Drug License: ${pharmacy.drugLicenseNo}'),
                _infoText('NTN: ${pharmacy.ntn}'),
                pw.SizedBox(height: 4),
                _buildStatusBadge(invoice.status),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: InvoiceTemplate.borderColor, thickness: 0.5),
        pw.SizedBox(height: 6),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context ctx, PharmacyInfo pharmacy, dynamic invoice) {
    return pw.Column(
      children: [
        pw.Divider(color: InvoiceTemplate.borderColor, thickness: 0.5),
        pw.SizedBox(height: 6),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Generated by PharmaCare App · ${pharmacy.name}',
                style: pw.TextStyle(
                    fontSize: InvoiceTemplate.fontSizeTiny,
                    color:    InvoiceTemplate.textLight)),
            pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                style: pw.TextStyle(
                    fontSize: InvoiceTemplate.fontSizeTiny,
                    color:    InvoiceTemplate.textLight)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCustomerSection(dynamic invoice) {
    final dateFmt = DateFormat('dd MMMM yyyy  ·  hh:mm a');
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _PwExpanded(
          flex: 3,
          child: _infoBox(
            title: 'BILL TO',
            children: [
              _boldText(invoice.customerName ?? 'Walk-in Customer'),
              if (invoice.customerPhone != null)
                _infoText('📞 ${invoice.customerPhone}'),
              if (invoice.prescriptionId != null)
                _infoText('Rx: ${invoice.prescriptionId}'),
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        _PwExpanded(
          flex: 2,
          child: _infoBox(
            title: 'INVOICE DETAILS',
            children: [
              _metaRow('Date',    dateFmt.format(invoice.createdAt)),
              _metaRow('Sold by', invoice.soldBy),
              if (invoice.branchId != null)
                _metaRow('Branch', invoice.branchId!),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(dynamic invoice) {
    final headers = [
      '#', 'Medicine / Generic', 'Batch', 'Expiry',
      'Qty', 'Unit Price', 'Disc%', 'Amount',
    ];

    final colWidths = {
      0: pw.FlexColumnWidth(InvoiceTemplate.colFlexNo.toDouble()),
      1: pw.FlexColumnWidth(InvoiceTemplate.colFlexName.toDouble()),
      2: pw.FlexColumnWidth(InvoiceTemplate.colFlexBatch.toDouble()),
      3: pw.FlexColumnWidth(InvoiceTemplate.colFlexExpiry.toDouble()),
      4:  pw.FlexColumnWidth(InvoiceTemplate.colFlexQty.toDouble()),
      5:  pw.FlexColumnWidth(InvoiceTemplate.colFlexUnit.toDouble()),
      6:pw.FlexColumnWidth(InvoiceTemplate.colFlexDisc.toDouble()),
      7: pw.FlexColumnWidth(InvoiceTemplate.colFlexTotal.toDouble()),
    };

    return pw.Table(
      columnWidths: colWidths,
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(
            color: InvoiceTemplate.borderColor, width: 0.5),
      ),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: InvoiceTemplate.tableHeaderBg),
          children: headers.map((h) => _tableHeader(h)).toList(),
        ),
        ...invoice.items.asMap().entries.map((entry) {
          final i    = entry.key;
          final item = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i % 2 == 1
                  ? InvoiceTemplate.tableAltRow
                  : InvoiceTemplate.white,
            ),
            children: [
              _tableCell('${i + 1}', align: pw.TextAlign.center),
              _tableCellDouble(top: item.tradeName, bottom: item.genericName),
              _tableCell(item.batchNo, align: pw.TextAlign.center),
              _tableCell(DateFormat('MMM yy').format(item.expiryDate),
                  align: pw.TextAlign.center),
              _tableCell('${item.qty}', align: pw.TextAlign.center),
              _tableCell(_currFmt0.format(item.unitPrice),
                  align: pw.TextAlign.right),
              _tableCell(
                item.discountPct > 0
                    ? '${item.discountPct.toStringAsFixed(0)}%' : '-',
                align: pw.TextAlign.center,
                color: item.discountPct > 0
                    ? InvoiceTemplate.accent : InvoiceTemplate.textLight,
              ),
              _tableCell(_currFmt0.format(item.lineTotal),
                  align: pw.TextAlign.right,
                  bold:  true,
                  color: InvoiceTemplate.textDark),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTotalsSection(dynamic invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 220,
          decoration: pw.BoxDecoration(
            border:       pw.Border.all(
                color: InvoiceTemplate.borderColor, width: 0.5),
            borderRadius: InvoiceTemplate.radius,
          ),
          child: pw.Column(
            children: [
              _totalRow('Subtotal', _currFmt.format(invoice.subtotal)),
              if (invoice.totalDiscount > 0)
                _totalRow('Discount',
                    '- ${_currFmt.format(invoice.totalDiscount)}',
                    valueColor: InvoiceTemplate.accent),
              if (invoice.totalTax > 0)
                _totalRow('Tax (GST)',
                    '+ ${_currFmt.format(invoice.totalTax)}'),
              if (invoice.loyaltyDiscount > 0)
                _totalRow('Loyalty discount',
                    '- ${_currFmt.format(invoice.loyaltyDiscount)}',
                    valueColor: InvoiceTemplate.accent),
              pw.Divider(
                  color: InvoiceTemplate.borderColor, thickness: 0.5),
              _totalRow('GRAND TOTAL', _currFmt.format(invoice.grandTotal),
                  bold:       true,
                  labelColor: InvoiceTemplate.primary,
                  valueColor: InvoiceTemplate.primary,
                  bgColor:    InvoiceTemplate.primaryLight,
                  fontSize:   11),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentSection(dynamic invoice) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _PwExpanded(
          child: _infoBox(
            title: 'PAYMENT RECEIVED',
            children: [
              ...invoice.payments.map((p) => _metaRow(
                p.method.label,
                _currFmt.format(p.amount),
                valueColor: InvoiceTemplate.accent,
              )),
              if (invoice.changeAmount > 0) ...[
                pw.Divider(
                    color: InvoiceTemplate.borderColor,
                    thickness: 0.3,
                    height: 10),
                _metaRow('Change returned',
                    _currFmt.format(invoice.changeAmount)),
              ],
            ],
          ),
        ),
        pw.SizedBox(width: 12),
        if (invoice.loyaltyPointsEarned > 0)
          _PwExpanded(
            child: _infoBox(
              title: 'LOYALTY POINTS',
              children: [
                _metaRow('Points earned',
                    '${invoice.loyaltyPointsEarned} pts'),
                if (invoice.loyaltyPointsRedeemed > 0)
                  _metaRow('Points redeemed',
                      '${invoice.loyaltyPointsRedeemed} pts'),
              ],
            ),
          ),
      ],
    );
  }

  pw.Widget _buildNotesSection(String notes) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color:        PdfColor.fromInt(0xFFFFFDE7),
        borderRadius: InvoiceTemplate.radius,
        border: pw.Border.all(
            color: PdfColor.fromInt(0xFFFFE082), width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('📝 ',
              style: pw.TextStyle(
                  fontSize: InvoiceTemplate.fontSizeBody)),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Notes',
                    style: pw.TextStyle(
                      fontSize:   InvoiceTemplate.fontSizeSmall,
                      fontWeight: pw.FontWeight.bold,
                      color:      InvoiceTemplate.textMid,
                    )),
                pw.SizedBox(height: 2),
                pw.Text(notes,
                    style: pw.TextStyle(
                      fontSize: InvoiceTemplate.fontSizeBody,
                      color:    InvoiceTemplate.textMid,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildThankYouBanner(PharmacyInfo pharmacy) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color:        InvoiceTemplate.primaryLight,
        borderRadius: InvoiceTemplate.radius,
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for choosing ${pharmacy.name}!',
            style: pw.TextStyle(
              fontSize:   11,
              fontWeight: pw.FontWeight.bold,
              color:      InvoiceTemplate.primary,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'For queries: ${pharmacy.phone}  |  ${pharmacy.email}',
            style: pw.TextStyle(
              fontSize: InvoiceTemplate.fontSizeSmall,
              color:    InvoiceTemplate.textMid,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'This is a computer-generated invoice and does not require a signature.',
            style: pw.TextStyle(
              fontSize:  InvoiceTemplate.fontSizeTiny,
              color:     InvoiceTemplate.textLight,
              fontStyle: pw.FontStyle.italic,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<pw.Font> _loadFont(pw.Font font) async => font;

  pw.Widget _infoText(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Text(text,
        style: pw.TextStyle(
          fontSize: InvoiceTemplate.fontSizeSmall,
          color:    InvoiceTemplate.textMid,
        )),
  );

  pw.Widget _boldText(String text) => pw.Text(text,
      style: pw.TextStyle(
        fontSize:   InvoiceTemplate.fontSizeBody,
        fontWeight: pw.FontWeight.bold,
        color:      InvoiceTemplate.textDark,
      ));

  pw.Widget _infoBox({
    required String title,
    required List<pw.Widget> children,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border:       pw.Border.all(
            color: InvoiceTemplate.borderColor, width: 0.5),
        borderRadius: InvoiceTemplate.radius,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            decoration: pw.BoxDecoration(
              color: InvoiceTemplate.primary,
              borderRadius: const pw.BorderRadius.only(
                topLeft:  pw.Radius.circular(6),
                topRight: pw.Radius.circular(6),
              ),
            ),
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            width: double.infinity,
            child: pw.Text(title,
                style: pw.TextStyle(
                  color:         InvoiceTemplate.white,
                  fontSize:      InvoiceTemplate.fontSizeTiny,
                  fontWeight:    pw.FontWeight.bold,
                  letterSpacing: 0.5,
                )),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _metaRow(String label, String value, {PdfColor? valueColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: InvoiceTemplate.fontSizeSmall,
                  color:    InvoiceTemplate.textLight)),
          pw.Text(value,
              style: pw.TextStyle(
                fontSize:   InvoiceTemplate.fontSizeSmall,
                fontWeight: pw.FontWeight.bold,
                color:      valueColor ?? InvoiceTemplate.textDark,
              )),
        ],
      ),
    );
  }

  pw.Widget _tableHeader(String text) => pw.Padding(
    padding: InvoiceTemplate.cellPadding,
    child: pw.Text(text,
        style: pw.TextStyle(
          color:      InvoiceTemplate.white,
          fontSize:   InvoiceTemplate.fontSizeTiny,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center),
  );

  pw.Widget _tableCell(String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: InvoiceTemplate.cellPadding,
      child: pw.Text(text,
          textAlign: align,
          style: pw.TextStyle(
            fontSize:   InvoiceTemplate.fontSizeSmall,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color:      color ?? InvoiceTemplate.textDark,
          )),
    );
  }

  pw.Widget _tableCellDouble({
    required String top,
    required String bottom,
  }) {
    return pw.Padding(
      padding: InvoiceTemplate.cellPadding,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(top,
              style: pw.TextStyle(
                fontSize:   InvoiceTemplate.fontSizeSmall,
                fontWeight: pw.FontWeight.bold,
                color:      InvoiceTemplate.textDark,
              )),
          pw.Text(bottom,
              style: pw.TextStyle(
                fontSize:  InvoiceTemplate.fontSizeTiny,
                color:     InvoiceTemplate.textLight,
                fontStyle: pw.FontStyle.italic,
              )),
        ],
      ),
    );
  }

  pw.Widget _totalRow(String label, String value, {
    bool bold = false,
    PdfColor? labelColor,
    PdfColor? valueColor,
    PdfColor? bgColor,
    double fontSize = 9.0,
  }) {
    return pw.Container(
      color: bgColor,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                fontSize:   fontSize,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color:      labelColor ?? InvoiceTemplate.textMid,
              )),
          pw.Text(value,
              style: pw.TextStyle(
                fontSize:   fontSize,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color:      valueColor ?? InvoiceTemplate.textDark,
              )),
        ],
      ),
    );
  }

  pw.Widget _buildStatusBadge(dynamic status) {
    String label;
    PdfColor color;
    switch (status.name) {
      case 'paid':     label = 'PAID';     color = InvoiceTemplate.accent;    break;
      case 'credit':   label = 'CREDIT';   color = InvoiceTemplate.warning;   break;
      case 'returned': label = 'RETURNED'; color = InvoiceTemplate.danger;    break;
      default:         label = 'VOID';     color = InvoiceTemplate.textLight;
    }
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: pw.BoxDecoration(
        color:        color,
        borderRadius: InvoiceTemplate.radius,
      ),
      child: pw.Text(label,
          style: pw.TextStyle(
            color:         InvoiceTemplate.white,
            fontSize:      InvoiceTemplate.fontSizeTiny,
            fontWeight:    pw.FontWeight.bold,
            letterSpacing: 1,
          )),
    );
  }
}

class _PwExpanded extends pw.StatelessWidget {
  _PwExpanded({required this.child, this.flex = 1});
  final pw.Widget child;
  final int flex;

  @override
  pw.Widget build(pw.Context context) =>
      pw.Expanded(flex: flex, child: child);
}