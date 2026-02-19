import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../services/scanner_service.dart';
import '../../../services/storage_service.dart';

/// Scan screen for document scanning
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ScannerService _scannerService = ScannerService();
  final StorageService _storageService = GetIt.instance<StorageService>();

  bool _isScanning = false;
  bool _autoScanEnabled = true;
  final List<String> _scannedImages = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = _storageService.getSettings();
    setState(() {
      _autoScanEnabled = settings.autoScanEnabled;
    });
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _scanDocument() async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Use ML Kit document scanner with auto-scan setting
      final images = await _scannerService.scanDocument(
        enableAutoScan: _autoScanEnabled,
      );

      if (images.isNotEmpty) {
        setState(() {
          _scannedImages.addAll(images);
        });

        // Navigate to preview
        if (mounted) {
          context.push('/scan/preview', extra: {'imagePaths': _scannedImages});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to scan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final images = await _scannerService.pickMultipleImages();
      if (images.isNotEmpty) {
        setState(() {
          _scannedImages.addAll(images);
        });

        if (mounted) {
          context.push('/scan/preview', extra: {'imagePaths': _scannedImages});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _toggleAutoScan(bool value) {
    setState(() {
      _autoScanEnabled = value;
    });
    // Save to settings
    final currentSettings = _storageService.getSettings();
    _storageService.saveSettings(
      currentSettings.copyWith(autoScanEnabled: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scanTitle),
        actions: [
          if (_scannedImages.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _scannedImages.clear();
                });
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: _isScanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryGreen),
                  const SizedBox(height: 16),
                  Text(
                    _autoScanEnabled
                        ? AppStrings.scanning
                        : AppStrings.processing,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.document_scanner,
                        size: 64,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Text(
                      AppStrings.appName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      AppStrings.appTagline,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Auto-scan Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _autoScanEnabled
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _autoScanEnabled
                                ? AppColors.primaryGreen50
                                : AppColors.gray100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _autoScanEnabled
                                ? Icons.auto_awesome
                                : Icons.edit_off,
                            color: _autoScanEnabled
                                ? AppColors.primaryGreen
                                : AppColors.gray500,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.autoScan,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppStrings.autoScanDescription,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoScanEnabled,
                          onChanged: _toggleAutoScan,
                          activeThumbColor: AppColors.primaryGreen,
                          activeTrackColor: AppColors.primaryGreen200,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Scan Button - Primary
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _scanDocument,
                      icon: const Icon(Icons.camera_alt, size: 24),
                      label: const Text(
                        AppStrings.captureDocument,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select Image Button - Secondary
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library, size: 24),
                      label: const Text(
                        AppStrings.selectImage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Text
                  if (_autoScanEnabled)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen50.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primaryGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'With Auto Scan enabled, document edges will be automatically detected and cropped.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
