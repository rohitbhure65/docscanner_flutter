import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../data/models/document_model.dart';
import '../../../services/storage_service.dart';

/// Document detail screen showing PDF details
class DocumentDetailScreen extends StatefulWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  final StorageService _storageService = GetIt.instance<StorageService>();
  DocumentModel? _document;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doc = _storageService.getDocument(widget.documentId);
      setState(() {
        _document = doc;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _renameDocument() async {
    if (_document == null) return;

    final controller = TextEditingController(text: _document!.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.renamePdf),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Document Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final updated = _document!.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await _storageService.updateDocument(updated);
      _loadDocument();
    }
  }

  Future<void> _shareDocument() async {
    if (_document?.pdfPath == null) return;

    try {
      await Share.shareXFiles([
        XFile(_document!.pdfPath!),
      ], text: _document!.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorShare}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_document?.name ?? AppStrings.documentDetails),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _renameDocument),
          IconButton(icon: const Icon(Icons.share), onPressed: _shareDocument),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            )
          : _document == null
          ? const Center(child: Text('Document not found'))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview
          Card(
            child: InkWell(
              onTap: () {
                context.push(
                  '/documents/viewer',
                  extra: {
                    'pdfPath': _document!.pdfPath,
                    'documentName': _document!.name,
                  },
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  size: 64,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Details
          _buildDetailRow(
            icon: Icons.insert_drive_file,
            label: AppStrings.pages,
            value: '${_document!.pageCount}',
          ),
          _buildDetailRow(
            icon: Icons.storage,
            label: AppStrings.fileSize,
            value: _storageService.formatFileSize(_document!.fileSize),
          ),
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: AppStrings.createdOn,
            value: _formatDateTime(_document!.createdAt),
          ),

          const SizedBox(height: 24),

          // Pages List
          Text('Pages', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _document!.pages.length,
            itemBuilder: (context, index) {
              final page = _document!.pages[index];
              return _PageThumbnail(
                pageNumber: index + 1,
                imagePath: page.imagePath,
              );
            },
          ),

          const SizedBox(height: 32),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/documents/viewer',
                  extra: {
                    'pdfPath': _document!.pdfPath,
                    'documentName': _document!.name,
                  },
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text(AppStrings.openPdf),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondaryLight),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _PageThumbnail extends StatelessWidget {
  final int pageNumber;
  final String imagePath;

  const _PageThumbnail({required this.pageNumber, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.image, color: AppColors.gray400),
                );
              },
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$pageNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
