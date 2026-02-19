import 'package:equatable/equatable.dart';

/// Model representing PDF configuration settings
class PdfConfigModel extends Equatable {
  final String pageSize;
  final String orientation;
  final String quality;
  final double? customWidth;
  final double? customHeight;
  final int compressionQuality;

  const PdfConfigModel({
    this.pageSize = 'Letter',
    this.orientation = 'Auto',
    this.quality = 'High',
    this.customWidth,
    this.customHeight,
    this.compressionQuality = 85,
  });

  PdfConfigModel copyWith({
    String? pageSize,
    String? orientation,
    String? quality,
    double? customWidth,
    double? customHeight,
    int? compressionQuality,
  }) {
    return PdfConfigModel(
      pageSize: pageSize ?? this.pageSize,
      orientation: orientation ?? this.orientation,
      quality: quality ?? this.quality,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      compressionQuality: compressionQuality ?? this.compressionQuality,
    );
  }

  /// Get page dimensions in inches
  Map<String, double> getPageDimensions() {
    const pageSizes = {
      'Letter': {'width': 8.5, 'height': 11.0},
      'Legal': {'width': 8.5, 'height': 14.0},
      'A4': {'width': 8.27, 'height': 11.69},
      'A5': {'width': 5.83, 'height': 8.27},
      'B4': {'width': 9.84, 'height': 13.90},
      'B5': {'width': 6.93, 'height': 9.84},
    };

    if (pageSize == 'Custom' && customWidth != null && customHeight != null) {
      return {'width': customWidth!, 'height': customHeight!};
    }

    return pageSizes[pageSize] ?? pageSizes['Letter']!;
  }

  /// Get DPI based on quality setting
  double getDpi() {
    const qualityDpi = {'High': 300.0, 'Medium': 150.0, 'Low': 72.0};
    return qualityDpi[quality] ?? 300.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'pageSize': pageSize,
      'orientation': orientation,
      'quality': quality,
      'customWidth': customWidth,
      'customHeight': customHeight,
      'compressionQuality': compressionQuality,
    };
  }

  factory PdfConfigModel.fromJson(Map<String, dynamic> json) {
    return PdfConfigModel(
      pageSize: json['pageSize'] as String? ?? 'Letter',
      orientation: json['orientation'] as String? ?? 'Auto',
      quality: json['quality'] as String? ?? 'High',
      customWidth: json['customWidth'] as double?,
      customHeight: json['customHeight'] as double?,
      compressionQuality: json['compressionQuality'] as int? ?? 85,
    );
  }

  @override
  List<Object?> get props => [
    pageSize,
    orientation,
    quality,
    customWidth,
    customHeight,
    compressionQuality,
  ];
}
