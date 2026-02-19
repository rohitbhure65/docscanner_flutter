import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../data/models/app_settings_model.dart';
import '../data/models/document_model.dart';

/// Service for handling local storage operations
class StorageService {
  static const String _documentsBoxName = AppConstants.documentsBox;
  static const String _settingsBoxName = AppConstants.settingsBox;

  late Box<Map> _documentsBox;
  late Box<Map> _settingsBox;

  String? _documentsPath;
  String? _appDocumentsPath;

  /// Initialize storage service
  Future<void> init() async {
    await Hive.initFlutter();
    _documentsBox = await Hive.openBox<Map>(_documentsBoxName);
    _settingsBox = await Hive.openBox<Map>(_settingsBoxName);

    final directory = await getApplicationDocumentsDirectory();
    _documentsPath = '${directory.path}/documents';
    _appDocumentsPath = '${directory.path}/pdfs';

    // Create directories if they don't exist
    await Directory(_documentsPath!).create(recursive: true);
    await Directory(_appDocumentsPath!).create(recursive: true);
  }

  /// Get documents directory path
  String get documentsPath => _documentsPath ?? '';

  /// Get PDFs directory path
  String get pdfsPath => _appDocumentsPath ?? '';

  // ==================== Document Operations ====================

  /// Save a document to storage
  Future<void> saveDocument(DocumentModel document) async {
    await _documentsBox.put(document.id, document.toJson());
  }

  /// Get all documents
  List<DocumentModel> getAllDocuments() {
    final documents = <DocumentModel>[];
    for (var key in _documentsBox.keys) {
      final json = _documentsBox.get(key);
      if (json != null) {
        documents.add(DocumentModel.fromJson(Map<String, dynamic>.from(json)));
      }
    }
    // Sort by updated date, newest first
    documents.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return documents;
  }

  /// Get a document by ID
  DocumentModel? getDocument(String id) {
    final json = _documentsBox.get(id);
    if (json != null) {
      return DocumentModel.fromJson(Map<String, dynamic>.from(json));
    }
    return null;
  }

  /// Delete a document
  Future<void> deleteDocument(String id) async {
    final document = getDocument(id);
    if (document != null) {
      // Delete associated files
      for (var page in document.pages) {
        await _deleteFile(page.imagePath);
        if (page.thumbnailPath != null) {
          await _deleteFile(page.thumbnailPath!);
        }
      }
      if (document.pdfPath != null) {
        await _deleteFile(document.pdfPath!);
      }
    }
    await _documentsBox.delete(id);
  }

  /// Update a document
  Future<void> updateDocument(DocumentModel document) async {
    await _documentsBox.put(document.id, document.toJson());
  }

  // ==================== Settings Operations ====================

  /// Save app settings
  Future<void> saveSettings(AppSettingsModel settings) async {
    await _settingsBox.put('app_settings', settings.toJson());
  }

  /// Get app settings
  AppSettingsModel getSettings() {
    final json = _settingsBox.get('app_settings');
    if (json != null) {
      return AppSettingsModel.fromJson(Map<String, dynamic>.from(json));
    }
    return const AppSettingsModel();
  }

  // ==================== File Operations ====================

  /// Save image file to documents folder
  Future<String> saveImageFile(String sourcePath, String fileName) async {
    final sourceFile = File(sourcePath);
    final destinationPath = '$_documentsPath/$fileName';
    await sourceFile.copy(destinationPath);
    return destinationPath;
  }

  /// Generate PDF file path
  String generatePdfPath(String documentName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedName = documentName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
    return '$_appDocumentsPath/${sanitizedName}_$timestamp.pdf';
  }

  /// Delete a file
  Future<void> _deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Format file size to human readable string
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get total storage used by documents
  Future<int> getTotalStorageUsed() async {
    int totalSize = 0;
    final dir = Directory(_documentsPath!);
    if (await dir.exists()) {
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    }
    final pdfDir = Directory(_appDocumentsPath!);
    if (await pdfDir.exists()) {
      await for (var entity in pdfDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    }
    return totalSize;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    final dir = Directory(_documentsPath!);
    if (await dir.exists()) {
      await for (var entity in dir.list()) {
        await entity.delete(recursive: true);
      }
    }
  }

  /// Close storage boxes
  Future<void> close() async {
    await _documentsBox.close();
    await _settingsBox.close();
  }
}
