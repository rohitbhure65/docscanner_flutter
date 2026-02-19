import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Service for document scanning and OCR
class ScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  // Document scanner for edge detection and auto-crop
  DocumentScanner? _documentScanner;

  /// Initialize document scanner with options
  void _initDocumentScanner({bool enableAutoScan = true}) {
    final options = DocumentScannerOptions(documentFormat: DocumentFormat.jpeg);
    _documentScanner = DocumentScanner(options: options);
  }

  /// Scan document with edge detection (auto-crop if enabled)
  /// Returns list of scanned image paths
  Future<List<String>> scanDocument({bool enableAutoScan = true}) async {
    final scannedImages = <String>[];

    try {
      // Initialize scanner with auto-scan setting
      _initDocumentScanner(enableAutoScan: enableAutoScan);

      if (_documentScanner == null) {
        throw ScannerException('Document scanner not initialized');
      }

      // Use ML Kit document scanner for edge detection
      final scanResult = await _documentScanner!.scanDocument();

      if (scanResult.images.isNotEmpty) {
        // scanResult.images contains file paths directly as Strings
        scannedImages.addAll(scanResult.images);
      }
    } catch (e) {
      throw ScannerException('Failed to scan document: $e');
    }

    return scannedImages;
  }

  /// Scan single document with automatic edge detection
  Future<String?> scanDocumentWithAutoScan() async {
    try {
      _initDocumentScanner(enableAutoScan: true);

      final scanResult = await _documentScanner!.scanDocument();

      if (scanResult.images.isNotEmpty) {
        return scanResult.images.first;
      }
      return null;
    } catch (e) {
      throw ScannerException('Failed to scan document: $e');
    }
  }

  /// Scan single document without automatic processing (manual crop)
  Future<String?> scanDocumentWithoutAutoScan() async {
    try {
      _initDocumentScanner(enableAutoScan: false);

      final scanResult = await _documentScanner!.scanDocument();

      if (scanResult.images.isNotEmpty) {
        return scanResult.images.first;
      }
      return null;
    } catch (e) {
      throw ScannerException('Failed to scan document: $e');
    }
  }

  /// Take photo with camera (legacy method - without edge detection)
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      return image?.path;
    } catch (e) {
      throw ScannerException('Failed to take photo: $e');
    }
  }

  /// Pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      return image?.path;
    } catch (e) {
      throw ScannerException('Failed to pick image: $e');
    }
  }

  /// Pick multiple images from gallery
  Future<List<String>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 100,
      );
      return images.map((e) => e.path).toList();
    } catch (e) {
      throw ScannerException('Failed to pick images: $e');
    }
  }

  /// Pick single image from gallery (for adding to existing document)
  Future<String?> pickSingleImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      return image?.path;
    } catch (e) {
      throw ScannerException('Failed to pick image: $e');
    }
  }

  /// Recognize text from image
  Future<String> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw ScannerException('Failed to recognize text: $e');
    }
  }

  /// Recognize text from multiple images
  Future<List<String>> recognizeTextFromImages(List<String> imagePaths) async {
    final results = <String>[];
    for (final path in imagePaths) {
      final text = await recognizeText(path);
      results.add(text);
    }
    return results;
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
    _documentScanner?.close();
  }
}

/// Custom exception for scanner errors
class ScannerException implements Exception {
  final String message;

  ScannerException(this.message);

  @override
  String toString() => message;
}
