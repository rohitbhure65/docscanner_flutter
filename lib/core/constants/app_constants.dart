/// App-wide constants for configuration
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'DocScanner';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // PDF Page Sizes
  static const Map<String, PageSize> pdfPageSizes = {
    'Letter': PageSize(8.5, 11.0, 'Letter'),
    'Legal': PageSize(8.5, 14.0, 'Legal'),
    'A4': PageSize(8.27, 11.69, 'A4'),
    'A5': PageSize(5.83, 8.27, 'A5'),
    'B4': PageSize(9.84, 13.90, 'B4'),
    'B5': PageSize(6.93, 9.84, 'B5'),
  };

  // Default PDF Settings
  static const String defaultPageSize = 'Letter';
  static const String defaultOrientation = 'Auto';
  static const String defaultQuality = 'High';

  // Quality Settings
  static const Map<String, double> qualityDpi = {
    'High': 300.0,
    'Medium': 150.0,
    'Low': 72.0,
  };

  static const Map<String, int> qualityCompression = {
    'High': 85,
    'Medium': 70,
    'Low': 50,
  };

  // Orientation Options
  static const List<String> orientationOptions = [
    'Auto',
    'Portrait',
    'Landscape',
  ];

  // Quality Options
  static const List<String> qualityOptions = ['High', 'Medium', 'Low'];

  // Page Size Options
  static const List<String> pageSizeOptions = [
    'Letter',
    'Legal',
    'A4',
    'A5',
    'B4',
    'B5',
    'Custom',
  ];

  // File Extensions
  static const String pdfExtension = '.pdf';
  static const String imageExtension = '.jpg';

  // Storage Keys
  static const String documentsBox = 'documents_box';
  static const String settingsBox = 'settings_box';
  static const String scannedPagesBox = 'scanned_pages_box';

  // Settings Keys
  static const String defaultPageSizeKey = 'default_page_size';
  static const String defaultOrientationKey = 'default_orientation';
  static const String defaultQualityKey = 'default_quality';
  static const String darkModeKey = 'dark_mode';
  static const String autoSaveKey = 'auto_save';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Image Processing
  static const int maxImageWidth = 2480;
  static const int maxImageHeight = 3508;
  static const double maxFileSizeMB = 10.0;

  // Cache Settings
  static const int maxCachedImages = 50;
  static const Duration cacheExpiration = Duration(days: 30);

  // API Settings (if needed)
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int maxRetries = 3;
}

/// Page size model class
class PageSize {
  final double width;
  final double height;
  final String name;

  const PageSize(this.width, this.height, this.name);

  double get aspectRatio => width / height;
}
