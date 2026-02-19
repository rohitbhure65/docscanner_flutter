import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models/document_model.dart';
import '../data/models/pdf_config_model.dart';

/// Service for PDF generation and manipulation
class PdfService {
  /// Generate PDF from list of image paths
  Future<Uint8List> generatePdf({
    required List<String> imagePaths,
    required PdfConfigModel config,
  }) async {
    final pdf = pw.Document();

    final pageDimensions = config.getPageDimensions();

    // Calculate page size in points (72 points = 1 inch)
    double pageWidth;
    double pageHeight;

    final orientation = config.orientation;
    final width = pageDimensions['width']!;
    final height = pageDimensions['height']!;

    if (orientation == 'Landscape') {
      pageWidth = width * 72;
      pageHeight = height * 72;
    } else if (orientation == 'Portrait') {
      pageWidth = height * 72;
      pageHeight = width * 72;
    } else {
      // Auto - determine based on image aspect ratio
      pageWidth = width * 72;
      pageHeight = height * 72;
    }

    final pageFormat = PdfPageFormat(pageWidth, pageHeight);

    for (final imagePath in imagePaths) {
      final imageFile = File(imagePath);
      if (await imageFile.exists()) {
        final bytes = await imageFile.readAsBytes();

        // Decode and compress image based on quality
        final processedBytes = _processImage(bytes, config.compressionQuality);

        final image = pw.MemoryImage(processedBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: pw.EdgeInsets.zero,
            build: (context) {
              return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
            },
          ),
        );
      }
    }

    return pdf.save();
  }

  /// Generate PDF from document model
  Future<Uint8List> generatePdfFromDocument({
    required DocumentModel document,
    required PdfConfigModel config,
  }) async {
    final imagePaths = document.pages.map((page) => page.imagePath).toList();
    return generatePdf(imagePaths: imagePaths, config: config);
  }

  /// Process image with compression and resizing
  Uint8List _processImage(Uint8List bytes, int quality) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      // Resize if too large (max 2480px width)
      img.Image resized = image;
      if (image.width > 2480) {
        resized = img.copyResize(image, width: 2480);
      }

      // Encode with compression
      return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
    } catch (e) {
      return bytes;
    }
  }

  /// Generate thumbnail for PDF first page
  Future<Uint8List?> generateThumbnail(
    String imagePath, {
    int width = 200,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      final thumbnail = img.copyResize(image, width: width);
      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 70));
    } catch (e) {
      return null;
    }
  }

  /// Get PDF page count (from stored file)
  Future<int> getPdfPageCount(String pdfPath) async {
    // Note: flutter_pdfview can be used to get actual page count
    // For now, return 0 as placeholder
    return 0;
  }

  /// Calculate estimated PDF size
  Future<int> estimatePdfSize({
    required int imageCount,
    required int averageImageSize,
    required String quality,
  }) async {
    // Rough estimation based on quality
    double compressionFactor;
    switch (quality) {
      case 'High':
        compressionFactor = 0.8;
        break;
      case 'Medium':
        compressionFactor = 0.5;
        break;
      case 'Low':
        compressionFactor = 0.3;
        break;
      default:
        compressionFactor = 0.8;
    }

    return (imageCount * averageImageSize * compressionFactor).round();
  }

  /// Convert images to PDF and save
  Future<String> convertImagesToPdf({
    required List<String> imagePaths,
    required String outputPath,
    required PdfConfigModel config,
  }) async {
    final pdfBytes = await generatePdf(imagePaths: imagePaths, config: config);

    final file = File(outputPath);
    await file.writeAsBytes(pdfBytes);

    return outputPath;
  }
}
