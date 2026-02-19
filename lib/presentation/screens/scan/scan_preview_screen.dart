import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../data/models/document_model.dart';
import '../../../data/models/pdf_config_model.dart';
import '../../../services/pdf_service.dart';
import '../../../services/scanner_service.dart';
import '../../../services/storage_service.dart';

/// Scan preview screen for managing scanned pages
class ScanPreviewScreen extends StatefulWidget {
  final List<String> imagePaths;

  const ScanPreviewScreen({super.key, required this.imagePaths});

  @override
  State<ScanPreviewScreen> createState() => _ScanPreviewScreenState();
}

class _ScanPreviewScreenState extends State<ScanPreviewScreen> {
  late List<String> _pages;
  bool _isSaving = false;
  bool _isAddingImage = false;
  PdfConfigModel _pdfConfig = const PdfConfigModel();

  final PdfService _pdfService = PdfService();
  final StorageService _storageService = GetIt.instance<StorageService>();
  final ScannerService _scannerService = ScannerService();

  @override
  void initState() {
    super.initState();
    _pages = List.from(widget.imagePaths);
  }

  Future<void> _saveDocument() async {
    if (_pages.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Generate unique ID
      final documentId = const Uuid().v4();
      final timestamp = DateTime.now();

      // Create pages
      final pageModels = <PageModel>[];
      for (int i = 0; i < _pages.length; i++) {
        final pageId = const Uuid().v4();
        final fileName = '${documentId}_page_$i.jpg';

        // Copy image to app storage
        final savedPath = await _storageService.saveImageFile(
          _pages[i],
          fileName,
        );

        pageModels.add(
          PageModel(
            id: pageId,
            imagePath: savedPath,
            pageNumber: i + 1,
            createdAt: timestamp,
          ),
        );
      }

      // Generate PDF
      final pdfPath = _storageService.generatePdfPath('Document_$documentId');
      await _pdfService.convertImagesToPdf(
        imagePaths: _pages,
        outputPath: pdfPath,
        config: _pdfConfig,
      );

      // Get file size
      final fileSize = await _storageService.getFileSize(pdfPath);

      // Create document
      final document = DocumentModel(
        id: documentId,
        name: 'Document_${timestamp.millisecondsSinceEpoch}',
        pages: pageModels,
        createdAt: timestamp,
        updatedAt: timestamp,
        pdfPath: pdfPath,
        fileSize: fileSize,
        documentType: 'scanned',
      );

      // Save document
      await _storageService.saveDocument(document);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.documentSaved),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/documents');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _removePage(int index) {
    setState(() {
      _pages.removeAt(index);
    });
  }

  void _reorderPages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _pages.removeAt(oldIndex);
      _pages.insert(newIndex, item);
    });
  }

  Future<void> _addMoreImages() async {
    setState(() {
      _isAddingImage = true;
    });

    try {
      final images = await _scannerService.pickMultipleImages();
      if (images.isNotEmpty) {
        setState(() {
          _pages.addAll(images);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isAddingImage = false;
      });
    }
  }

  Future<void> _scanAgain() async {
    setState(() {
      _isAddingImage = true;
    });

    try {
      // Use the same scanner as scan screen
      final settings = _storageService.getSettings();
      final images = await _scannerService.scanDocument(
        enableAutoScan: settings.autoScanEnabled,
      );

      if (images.isNotEmpty) {
        setState(() {
          _pages.addAll(images);
        });
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
        _isAddingImage = false;
      });
    }
  }

  void _showPdfSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PdfSettingsSheet(
        config: _pdfConfig,
        onConfigChanged: (config) {
          setState(() {
            _pdfConfig = config;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_pages.length} ${AppStrings.pages}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showPdfSettings,
            tooltip: AppStrings.pdfSettings,
          ),
          TextButton(
            onPressed: _isSaving ? null : _saveDocument,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(AppStrings.save),
          ),
        ],
      ),
      body: _pages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: AppColors.gray400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noImagesSelected,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Pages List
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pages.length,
                    onReorder: _reorderPages,
                    itemBuilder: (context, index) {
                      return _PageCard(
                        key: ValueKey(_pages[index]),
                        imagePath: _pages[index],
                        pageNumber: index + 1,
                        onDelete: () => _removePage(index),
                        isDark: isDark,
                      );
                    },
                  ),
                ),

                // Bottom Action Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // Add More Images Button
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _isAddingImage ? null : _addMoreImages,
                              icon: _isAddingImage
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add_photo_alternate),
                              label: const Text(AppStrings.selectImage),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryGreen,
                                side: const BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Scan Again Button
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isAddingImage ? null : _scanAgain,
                              icon: const Icon(Icons.document_scanner),
                              label: const Text(AppStrings.scanAgain),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PageCard extends StatelessWidget {
  final String imagePath;
  final int pageNumber;
  final VoidCallback onDelete;
  final bool isDark;

  const _PageCard({
    super.key,
    required this.imagePath,
    required this.pageNumber,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header with page number and delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$pageNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Page $pageNumber',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  onPressed: onDelete,
                  tooltip: AppStrings.deletePage,
                ),
              ],
            ),
          ),
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Image.file(
              File(imagePath),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: AppColors.gray200,
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 48,
                      color: AppColors.gray400,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfSettingsSheet extends StatefulWidget {
  final PdfConfigModel config;
  final Function(PdfConfigModel) onConfigChanged;

  const _PdfSettingsSheet({
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<_PdfSettingsSheet> createState() => _PdfSettingsSheetState();
}

class _PdfSettingsSheetState extends State<_PdfSettingsSheet> {
  late String _pageSize;
  late String _orientation;
  late String _quality;

  @override
  void initState() {
    super.initState();
    _pageSize = widget.config.pageSize;
    _orientation = widget.config.orientation;
    _quality = widget.config.quality;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            AppStrings.pdfSettings,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 24),

          // Page Size
          Text(
            AppStrings.pageSize,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Letter', 'Legal', 'A4', 'A5', 'B4', 'B5'].map((size) {
              final isSelected = _pageSize == size;
              return ChoiceChip(
                label: Text(size),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _pageSize = size);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Orientation
          Text(
            AppStrings.orientation,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Auto', 'Portrait', 'Landscape'].map((orient) {
              final isSelected = _orientation == orient;
              return ChoiceChip(
                label: Text(orient),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _orientation = orient);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Quality
          Text(
            AppStrings.quality,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['High', 'Medium', 'Low'].map((qual) {
              final isSelected = _quality == qual;
              return ChoiceChip(
                label: Text(qual),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _quality = qual);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                widget.onConfigChanged(
                  PdfConfigModel(
                    pageSize: _pageSize,
                    orientation: _orientation,
                    quality: _quality,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStrings.apply,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
