import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../data/models/pdf_config_model.dart';
import '../../../services/storage_service.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = GetIt.instance<StorageService>();
  late AppSettingsModel _settings;
  bool _isDarkMode = false;
  bool _autoScanEnabled = true;
  String _defaultPageSize = 'A4';
  String _defaultOrientation = 'Auto';
  String _defaultQuality = 'High';
  String _storageUsed = '0 MB';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _settings = _storageService.getSettings();
    setState(() {
      _isDarkMode = _settings.darkMode;
      _autoScanEnabled = _settings.autoScanEnabled;
      _defaultPageSize = _settings.defaultPdfConfig.pageSize;
      _defaultOrientation = _settings.defaultPdfConfig.orientation;
      _defaultQuality = _settings.defaultPdfConfig.quality;
    });
    _updateStorageUsed();
  }

  Future<void> _updateStorageUsed() async {
    final bytes = await _storageService.getTotalStorageUsed();
    setState(() {
      _storageUsed = _storageService.formatFileSize(bytes);
    });
  }

  Future<void> _saveSettings() async {
    final settings = AppSettingsModel(
      defaultPdfConfig: PdfConfigModel(
        pageSize: _defaultPageSize,
        orientation: _defaultOrientation,
        quality: _defaultQuality,
      ),
      darkMode: _isDarkMode,
      autoScanEnabled: _autoScanEnabled,
      autoSave: _settings.autoSave,
      showTutorial: _settings.showTutorial,
      defaultSaveLocation: _settings.defaultSaveLocation,
    );
    await _storageService.saveSettings(settings);
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    _saveSettings();
  }

  void _toggleAutoScan(bool value) {
    setState(() {
      _autoScanEnabled = value;
    });
    _saveSettings();
  }

  void _showPageSizePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _OptionPicker(
        title: AppStrings.pageSize,
        options: AppConstants.pageSizeOptions
            .where((o) => o != 'Custom')
            .toList(),
        selectedOption: _defaultPageSize,
        onSelected: (value) {
          setState(() {
            _defaultPageSize = value;
          });
          _saveSettings();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showOrientationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _OptionPicker(
        title: AppStrings.orientation,
        options: AppConstants.orientationOptions,
        selectedOption: _defaultOrientation,
        onSelected: (value) {
          setState(() {
            _defaultOrientation = value;
          });
          _saveSettings();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showQualityPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _OptionPicker(
        title: AppStrings.quality,
        options: AppConstants.qualityOptions,
        selectedOption: _defaultQuality,
        onSelected: (value) {
          setState(() {
            _defaultQuality = value;
          });
          _saveSettings();
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearCache),
        content: const Text(
          'This will delete all cached images. Your documents will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.clearCache();
      _updateStorageUsed();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        children: [
          // Default PDF Settings
          _buildSectionHeader(AppStrings.defaultSettings),
          _buildOptionTile(
            icon: Icons.aspect_ratio,
            title: AppStrings.pageSize,
            subtitle: _defaultPageSize,
            onTap: _showPageSizePicker,
          ),
          _buildOptionTile(
            icon: Icons.screen_rotation,
            title: AppStrings.orientation,
            subtitle: _defaultOrientation,
            onTap: _showOrientationPicker,
          ),
          _buildOptionTile(
            icon: Icons.high_quality,
            title: AppStrings.quality,
            subtitle: _defaultQuality,
            onTap: _showQualityPicker,
          ),

          const Divider(),

          // Appearance
          _buildSectionHeader(AppStrings.appearance),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text(AppStrings.darkMode),
            value: _isDarkMode,
            onChanged: _toggleDarkMode,
            activeThumbColor: AppColors.primaryGreen,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome),
            title: const Text(AppStrings.autoScan),
            subtitle: Text(
              AppStrings.autoScanDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: _autoScanEnabled,
            onChanged: _toggleAutoScan,
            activeThumbColor: AppColors.primaryGreen,
          ),

          const Divider(),

          // Storage
          _buildSectionHeader(AppStrings.storage),
          _buildOptionTile(
            icon: Icons.storage,
            title: 'Storage Used',
            subtitle: _storageUsed,
          ),
          _buildOptionTile(
            icon: Icons.delete_sweep,
            title: AppStrings.clearCache,
            subtitle: 'Free up storage space',
            onTap: _clearCache,
          ),

          const Divider(),

          // About
          _buildSectionHeader(AppStrings.about),
          _buildOptionTile(
            icon: Icons.info,
            title: AppStrings.version,
            subtitle:
                '${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
          ),
          _buildOptionTile(
            icon: Icons.description,
            title: AppStrings.privacyPolicy,
            onTap: () {},
          ),
          _buildOptionTile(
            icon: Icons.gavel,
            title: AppStrings.termsOfService,
            onTap: () {},
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}

class _OptionPicker extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedOption;
  final Function(String) onSelected;

  const _OptionPicker({
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = option == selectedOption;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                labelStyle: TextStyle(color: isSelected ? Colors.white : null),
                onSelected: (_) => onSelected(option),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
