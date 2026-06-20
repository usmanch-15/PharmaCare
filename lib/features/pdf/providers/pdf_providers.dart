import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/services/pdf_service_impl.dart';
import '../generators/invoice_pdf_generator.dart';
import '../models/pharmacy_info.dart';

// ── Core service ──────────────────────────────────────────────────────────────

final pdfServiceProvider = Provider<PdfService>(
  (_) => const PdfServiceImpl(),
);

// ── Generator ─────────────────────────────────────────────────────────────────

final invoicePdfGeneratorProvider = Provider<InvoicePdfGenerator>(
  (_) => const InvoicePdfGenerator(),
);

// ── Pharmacy info ─────────────────────────────────────────────────────────────
// Replace PharmacyInfo.defaultInfo() with a FutureProvider that reads
// from Firestore /settings/pharmacy_config in production.

final pharmacyInfoProvider = Provider<PharmacyInfo>(
  (_) => PharmacyInfo.defaultInfo(),
);

// ── Future provider: load pharmacy from Firestore ─────────────────────────────
// Uncomment and wire to your Firestore settings collection when ready:
//
// final pharmacyInfoProvider = FutureProvider<PharmacyInfo>((ref) async {
//   final fs  = ref.read(firestoreProvider);
//   final doc = await fs.collection('settings').doc('pharmacy_config').get();
//   final d   = doc.data() as Map<String, dynamic>;
//   return PharmacyInfo(
//     name:           d['pharmacyName'] ?? '',
//     address:        d['address']      ?? '',
//     phone:          d['phone']        ?? '',
//     email:          d['email']        ?? '',
//     drugLicenseNo:  d['drugLicenseNo'] ?? '',
//     ntn:            d['ntn']           ?? '',
//     website:        d['website'],
//     tagline:        d['tagline'],
//   );
// });