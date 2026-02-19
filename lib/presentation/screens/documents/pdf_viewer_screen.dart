import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../../core/constants/color_constants.dart';

/// PDF viewer screen for displaying PDF documents
class PdfViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String documentName;

  const PdfViewerScreen({
    super.key,
    required this.pdfPath,
    required this.documentName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isReady = false;
  PDFViewController? _pdfController;

  @override
  Widget build(BuildContext context) {
    final file = File(widget.pdfPath);

    if (!file.existsSync()) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.documentName)),
        body: const Center(child: Text('PDF file not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentName),
        actions: [
          if (_isReady)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
                _isReady = true;
              });
            },
            onError: (error) {
              print(error.toString());
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController controller) {
              _pdfController = controller;
            },
            onPageChanged: (int? page, int? total) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? 0;
              });
            },
          ),
          if (!_isReady)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
        ],
      ),
      floatingActionButton: _isReady
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'prev',
                  mini: true,
                  onPressed: _currentPage > 0
                      ? () {
                          _pdfController?.setPage(_currentPage - 1);
                        }
                      : null,
                  child: const Icon(Icons.chevron_left),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'next',
                  mini: true,
                  onPressed: _currentPage < _totalPages - 1
                      ? () {
                          _pdfController?.setPage(_currentPage + 1);
                        }
                      : null,
                  child: const Icon(Icons.chevron_right),
                ),
              ],
            )
          : null,
    );
  }
}
