import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/color_constants.dart';
import '../../../core/constants/string_constants.dart';

/// OCR result screen for displaying recognized text
class OcrResultScreen extends StatefulWidget {
  final String imagePath;
  final String recognizedText;

  const OcrResultScreen({
    super.key,
    required this.imagePath,
    required this.recognizedText,
  });

  @override
  State<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends State<OcrResultScreen> {
  late String _text;

  @override
  void initState() {
    super.initState();
    _text = widget.recognizedText;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.textCopied),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _shareText() {
    Share.share(_text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.extractText),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyToClipboard,
            tooltip: AppStrings.copyText,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareText,
            tooltip: AppStrings.shareText,
          ),
        ],
      ),
      body: _text.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.text_fields, size: 64, color: AppColors.gray400),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noTextFound,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _text,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _text.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text(AppStrings.copyText),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareText,
                        icon: const Icon(Icons.share),
                        label: const Text(AppStrings.shareText),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
