import 'dart:io';
import 'dart:typed_data';

/// Abstract PDF service — injectable and testable.
abstract class PdfService {
  /// Saves [pdfBytes] to the device's documents directory.
  /// Returns the saved [File].
  Future<File> saveToFile({
    required Uint8List pdfBytes,
    required String fileName,
  });

  /// Opens the system share sheet for [pdfBytes].
  Future<void> sharePdf({
    required Uint8List pdfBytes,
    required String fileName,
    String? subject,
  });

  /// Opens [file] in the device's default PDF viewer.
  Future<void> openFile(File file);

  /// Triggers the system print dialog for [pdfBytes].
  Future<void> printPdf({
    required Uint8List pdfBytes,
    required String documentName,
  });
}