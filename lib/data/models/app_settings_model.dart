import 'package:equatable/equatable.dart';

import 'pdf_config_model.dart';

/// Model representing app settings
class AppSettingsModel extends Equatable {
  final PdfConfigModel defaultPdfConfig;
  final bool darkMode;
  final bool autoScanEnabled;
  final bool autoSave;
  final bool showTutorial;
  final String defaultSaveLocation;

  const AppSettingsModel({
    this.defaultPdfConfig = const PdfConfigModel(),
    this.darkMode = false,
    this.autoScanEnabled = true,
    this.autoSave = true,
    this.showTutorial = true,
    this.defaultSaveLocation = '',
  });

  AppSettingsModel copyWith({
    PdfConfigModel? defaultPdfConfig,
    bool? darkMode,
    bool? autoScanEnabled,
    bool? autoSave,
    bool? showTutorial,
    String? defaultSaveLocation,
  }) {
    return AppSettingsModel(
      defaultPdfConfig: defaultPdfConfig ?? this.defaultPdfConfig,
      darkMode: darkMode ?? this.darkMode,
      autoScanEnabled: autoScanEnabled ?? this.autoScanEnabled,
      autoSave: autoSave ?? this.autoSave,
      showTutorial: showTutorial ?? this.showTutorial,
      defaultSaveLocation: defaultSaveLocation ?? this.defaultSaveLocation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultPdfConfig': defaultPdfConfig.toJson(),
      'darkMode': darkMode,
      'autoScanEnabled': autoScanEnabled,
      'autoSave': autoSave,
      'showTutorial': showTutorial,
      'defaultSaveLocation': defaultSaveLocation,
    };
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      defaultPdfConfig: json['defaultPdfConfig'] != null
          ? PdfConfigModel.fromJson(
              json['defaultPdfConfig'] as Map<String, dynamic>,
            )
          : const PdfConfigModel(),
      darkMode: json['darkMode'] as bool? ?? false,
      autoScanEnabled: json['autoScanEnabled'] as bool? ?? true,
      autoSave: json['autoSave'] as bool? ?? true,
      showTutorial: json['showTutorial'] as bool? ?? true,
      defaultSaveLocation: json['defaultSaveLocation'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
    defaultPdfConfig,
    darkMode,
    autoScanEnabled,
    autoSave,
    showTutorial,
    defaultSaveLocation,
  ];
}
