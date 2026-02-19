import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../data/models/document_model.dart';
import '../../../data/models/pdf_config_model.dart';
import '../../../services/pdf_service.dart';
import '../../../services/scanner_service.dart';
import '../../../services/storage_service.dart';

/// Image to PDF screen for converting images to PDF
class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final ScannerService _scannerService = ScannerService();
  final StorageService _storageService = GetIt.instance<StorageService>();
  final PdfService _pdfService = PdfService();

  final List<String> _selectedImages = [];
  bool _isLoading = false;
  bool _isConverting = false;
  PdfConfigModel _pdfConfig = const PdfConfigModel();

  Future<void> _pickImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final images = await _scannerService.pickMultipleImages();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
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
        _isLoading = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedImages.removeAt(oldIndex);
      _selectedImages.insert(newIndex, item);
    });
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

  Future<void> _convertToPdf() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isConverting = true;
    });

    try {
      // Generate unique ID
      final documentId = const Uuid().v4();
      final timestamp = DateTime.now();

      // Create pages
      final pageModels = <PageModel>[];
      for (int i = 0; i < _selectedImages.length; i++) {
        final pageId = const Uuid().v4();
        final fileName = '${documentId}_page_$i.jpg';

        // Copy image to app storage
        final savedPath = await _storageService.saveImageFile(
          _selectedImages[i],
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
      final pdfPath = _storageService.generatePdfPath('ImagePDF_$documentId');
      await _pdfService.convertImagesToPdf(
        imagePaths: _selectedImages,
        outputPath: pdfPath,
        config: _pdfConfig,
      );

      // Get file size
      final fileSize = await _storageService.getFileSize(pdfPath);

      // Create document
      final document = DocumentModel(
        id: documentId,
        name: 'ImagePDF_${timestamp.millisecondsSinceEpoch}',
        pages: pageModels,
        createdAt: timestamp,
        updatedAt: timestamp,
        pdfPath: pdfPath,
        fileSize: fileSize,
        documentType: 'image_pdf',
      );

      // Save document
      await _storageService.saveDocument(document);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.pdfCreated),
            backgroundColor: AppColors.success,
          ),
        );

        // Clear selected images
        setState(() {
          _selectedImages.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorPdf}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.imageToPdfTitle),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showPdfSettings,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : _selectedImages.isEmpty
          ? _buildEmptyState()
          : _buildImagesList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedImages.isNotEmpty) ...[
            FloatingActionButton(
              heroTag: 'add',
              onPressed: _pickImages,
              child: const Icon(Icons.add_photo_alternate),
            ),
            const SizedBox(height: 16),
            FloatingActionButton.extended(
              heroTag: 'convert',
              onPressed: _isConverting ? null : _convertToPdf,
              icon: _isConverting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(
                _isConverting ? AppStrings.converting : AppStrings.convertToPdf,
              ),
            ),
          ] else
            FloatingActionButton.extended(
              heroTag: 'select',
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text(AppStrings.selectImages),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image,
                size: 60,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.noImagesSelected,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noImagesSelectedSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesList() {
    return Column(
      children: [
        // Info bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primaryGreen50,
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Text(
                '${_selectedImages.length} images selected',
                style: const TextStyle(color: AppColors.primaryGreenDark),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedImages.clear();
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
        ),

        // Images grid
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _selectedImages.length,
            onReorder: _reorderImages,
            itemBuilder: (context, index) {
              return _ImageCard(
                key: ValueKey(_selectedImages[index]),
                imagePath: _selectedImages[index],
                index: index,
                onDelete: () => _removeImage(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imagePath;
  final int index;
  final VoidCallback onDelete;

  const _ImageCard({
    super.key,
    required this.imagePath,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.drag_handle, color: AppColors.gray500),
            ),
          ),

          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePath),
              width: 60,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Text(
              'Image ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Delete
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: onDelete,
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
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.pdfSettings,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          // Page Size
          Text(
            AppStrings.pageSize,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Letter', 'Legal', 'A4', 'A5', 'B4', 'B5'].map((size) {
              return ChoiceChip(
                label: Text(size),
                selected: _pageSize == size,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _pageSize = size);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Orientation
          Text(
            AppStrings.orientation,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Auto', 'Portrait', 'Landscape'].map((orient) {
              return ChoiceChip(
                label: Text(orient),
                selected: _orientation == orient,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _orientation = orient);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Quality
          Text(
            AppStrings.quality,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['High', 'Medium', 'Low'].map((qual) {
              return ChoiceChip(
                label: Text(qual),
                selected: _quality == qual,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _quality = qual);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
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
              child: const Text(AppStrings.apply),
            ),
          ),
        ],
      ),
    );
  }
}
