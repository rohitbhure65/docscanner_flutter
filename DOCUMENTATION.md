# 📄 DocScanner - Flutter Document Scanner App

## Documentation Index
1. [Project Overview](#1-project-overview)
2. [Project Structure](#2-project-structure)
3. [Architecture](#3-architecture)
4. [Navigation Flow](#4-navigation-flow)
5. [State Management](#5-state-management)
6. [API Services & Data Flow](#6-api-services--data-flow)
7. [Dependency Injection](#7-dependency-injection)
8. [Environment Setup](#8-environment-setup)
9. [Build & Run Instructions](#9-build--run-instructions)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Project Overview

**DocScanner** is a Flutter mobile application for document scanning, OCR text recognition, and PDF management.

### Features
- 📷 Document scanning with edge detection
- 🔤 OCR text recognition
- 📄 PDF generation with customization
- 📁 Document management
- 🖼️ Image to PDF conversion
- ⚙️ App settings

### Color Theme
- **Primary**: Green (#00C853, #00E676)
- **Secondary**: Black (#1A1A1A)
- **Background**: White (#FFFFFF)
- **Accent**: Light Green (#B9F6CA)

---

## 2. Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/                              # Core utilities
│   ├── constants/                    # App constants
│   │   ├── animation_constants.dart  # Animation durations, curves
│   │   ├── app_constants.dart         # PDF sizes, quality options
│   │   ├── color_constants.dart       # Color definitions
│   │   └── string_constants.dart      # UI strings
│   ├── di/                            # Dependency injection
│   │   └── injection.dart             # GetIt setup
│   ├── routing/                       # Navigation
│   │   ├── app_router.dart            # GoRouter configuration
│   │   ├── app_routes.dart            # Route constants
│   │   └── route_generator.dart       # Route generation logic
│   ├── theme/                         # Theming
│   │   ├── app_colors.dart            # Color definitions
│   │   ├── app_theme.dart            # Light/Dark themes
│   │   └── text_styles.dart          # Typography
│   └── utils/                         # Utilities
│       ├── extensions/                # Dart extensions
│       │   ├── context_extensions.dart  # BuildContext helpers
│       │   ├── number_extensions.dart    # Number formatting
│       │   └── widget_extensions.dart    # Widget helpers
│       ├── helpers/                   # Helper classes
│       │   ├── animation_helper.dart    # Animation utilities
│       │   ├── math_helper.dart          # Math calculations
│       │   └── particle_helper.dart      # Particle physics
│       └── validators/                # Input validators
│           └── input_validators.dart    # Form validation
├── data/                              # Data layer
│   ├── models/                        # Data models
│   │   ├── app_settings_model.dart   # App settings
│   │   ├── card_model.dart            # Home card model
│   │   ├── document_model.dart       # Document entity
│   │   ├── particle_model.dart       # Particle effect model
│   │   ├── pdf_config_model.dart     # PDF configuration
│   │   └── stat_model.dart            # Statistics model
│   ├── providers/                     # State providers
│   │   ├── animation_provider.dart   # Animation state
│   │   └── theme_provider.dart        # Theme state
│   └── repositories/                  # Data repositories
│       ├── animation_repository.dart  # Animation data
│       └── particle_repository.dart  # Particle data
├── presentation/                      # UI layer
│   ├── screens/                       # App screens
│   │   ├── documents/                # Documents tab
│   │   │   ├── documents_screen.dart
│   │   │   ├── document_detail_screen.dart
│   │   │   └── pdf_viewer_screen.dart
│   │   ├── home/                     # Home screen with cards
│   │   │   ├── home_screen.dart
│   │   │   ├── main_screen.dart
│   │   │   ├── viewmodels/
│   │   │   │   └── home_viewmodel.dart
│   │   │   └── widgets/
│   │   │       ├── animated_particles.dart
│   │   │       ├── bottom_decoration.dart
│   │   │       ├── floating_shapes.dart
│   │   │       ├── home_background.dart
│   │   │       └── home_card.dart
│   │   ├── image_to_pdf/             # Image to PDF tab
│   │   │   └── image_to_pdf_screen.dart
│   │   ├── ocr/                      # OCR
│   │   │   └── ocr_result_screen.dart
│   │   ├── scan/                     # Scan tab
│   │   │   ├── scan_screen.dart
│   │   │   └── scan_preview_screen.dart
│   │   ├── settings/                 # Settings tab
│   │   │   └── settings_screen.dart
│   │   └── splash/                   # Splash screen
│   │       ├── splash_screen.dart
│   │       └── widgets/
│   │           └── splash_animation.dart
│   ├── viewmodels/                   # ViewModels
│   │   ├── base_viewmodel.dart       # Base ViewModel
│   │   └── mixins/
│   │       ├── animation_mixin.dart  # Animation mixin
│   │       └── particle_mixin.dart    # Particle mixin
│   └── widgets/                       # Reusable widgets
│       ├── animations/               # Animation widgets
│       │   ├── custom_curves.dart
│       │   ├── fade_animation.dart
│       │   ├── pulse_animation.dart
│       │   ├── rotation_animation.dart
│       │   ├── scale_animation.dart
│       │   └── slide_animation.dart
│       ├── common/                   # Common widgets
│       │   ├── animated_button.dart
│       │   ├── glass_card.dart
│       │   ├── gradient_text.dart
│       │   ├── particle_widget.dart
│       │   ├── progress_indicator.dart
│       │   └── shimmer_effect.dart
│       └── layout/                   # Layout widgets
│           ├── adaptive_layout.dart
│           ├── responsive_builder.dart
│           └── screen_utils.dart
├── generated/                        # Generated code
│   ├── assets.dart                   # Asset definitions
│   └── fonts.dart                    # Font definitions
└── services/                          # Business logic
    ├── animation_service.dart        # Animation management
    ├── navigation_service.dart       # Navigation helpers
    ├── particle_service.dart         # Particle effects
    ├── pdf_service.dart               # PDF generation
    ├── scanner_service.dart           # Document scanning
    ├── storage_service.dart           # Local storage
    └── theme_service.dart             # Theme management
```

### Feature Breakdown

| Feature | Path | Description |
|---------|------|-------------|
| Scanning | `lib/presentation/screens/scan/` | Camera-based document scanning |
| OCR | `lib/presentation/screens/ocr/` | Text recognition from images |
| Documents | `lib/presentation/screens/documents/` | PDF list and management |
| Image to PDF | `lib/presentation/screens/image_to_pdf/` | Convert images to PDF |
| Settings | `lib/presentation/screens/settings/` | App configuration |
| Home | `lib/presentation/screens/home/` | Home screen with animated cards |
| Splash | `lib/presentation/screens/splash/` | App launch animation |

---

## 3. Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│     Presentation (UI)               │
│  - Screens                          │
│  - Widgets                          │
├─────────────────────────────────────┤
│     Domain (Business Logic)         │
│  - Use Cases                        │
│  - Entities                         │
├─────────────────────────────────────┤
│     Data                            │
│  - Models                           │
│  - Repositories                     │
│  - Services                         │
└─────────────────────────────────────┘
```

### Key Principles

1. **Separation of Concerns**: Each layer has specific responsibilities
2. **Feature-First Organization**: Screens grouped by feature
3. **Service-Based Business Logic**: Services handle core operations
4. **Repository Pattern**: Data access abstraction

---

## 4. Navigation Flow

### GoRouter Configuration

Routes are defined in `lib/core/routing/app_router.dart`:

```dart
// Route paths
static const String home = '/';
static const String scan = '/scan';
static const String scanPreview = '/scan/preview';
static const String documents = '/documents';
static const String documentDetail = '/documents/detail';
static const String pdfViewer = '/documents/viewer';
static const String imageToPdf = '/image-to-pdf';
static const String settings = '/settings';
static const String ocrResult = '/ocr-result';
```

### Navigation Structure

```
App Launch
└── SplashScreen (initial route)
    └── MainScreen (Bottom Navigation)
        ├── Scan Tab
        │   ├── ScanScreen
        │   └── ScanPreviewScreen
        ├── Documents Tab
        │   ├── DocumentsScreen
        │   ├── DocumentDetailScreen
        │   └── PdfViewerScreen
        ├── Image to PDF Tab
        │   └── ImageToPdfScreen
        └── Settings Tab
            └── SettingsScreen

Global Routes (accessible from anywhere)
├── OcrResultScreen (/ocr-result)
└── HomeScreen
```

### Deep Linking

The app supports deep linking with the following patterns:
- `/scan` - Scanner
- `/scan/preview` - Scan preview
- `/documents` - Documents list
- `/documents/detail` - Document details
- `/documents/viewer` - PDF viewer
- `/image-to-pdf` - Image to PDF converter
- `/settings` - Settings
- `/ocr-result` - OCR result

---

## 5. State Management

### Provider + BLoC Pattern

The app uses **Provider** for dependency injection and **BLoC pattern** for state management.

### Providers

```dart
// In lib/core/di/injection.dart
getIt.registerLazySingleton<StorageService>(() => StorageService());
getIt.registerLazySingleton<PdfService>(() => PdfService());
getIt.registerLazySingleton<ScannerService>(() => ScannerService());
```

### Service Access

```dart
// Using GetIt
import 'package:get_it/get_it.dart';

final storageService = GetIt.instance<StorageService>();
final pdfService = GetIt.instance<PdfService>();
final scannerService = GetIt.instance<ScannerService>();
```

### State Management Example

```dart
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<DocumentModel> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final storageService = GetIt.instance<StorageService>();
    final docs = await storageService.getAllDocuments();
    setState(() {
      _documents = docs;
      _isLoading = false;
    });
  }

  // UI build...
}
```

---

## 6. API Services & Data Flow

### 6.1 Storage Service

Handles local file storage and document management.

```dart
// lib/services/storage_service.dart

class StorageService {
  /// Initialize storage
  Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();
    await Hive.openBox('documents');
    await Hive.openBox('settings');
  }

  /// Get all documents
  Future<List<DocumentModel>> getAllDocuments() async {
    final box = Hive.box('documents');
    return box.values.toList();
  }

  /// Save document
  Future<void> saveDocument(DocumentModel document) async {
    final box = Hive.box('documents');
    await box.put(document.id, document);
  }

  /// Delete document
  Future<void> deleteDocument(String id) async {
    final box = Hive.box('documents');
    await box.delete(id);
  }

  /// Get app settings
  AppSettingsModel getSettings() {
    final box = Hive.box('settings');
    return box.get('settings') ?? const AppSettingsModel();
  }

  /// Save app settings
  Future<void> saveSettings(AppSettingsModel settings) async {
    final box = Hive.box('settings');
    await box.put('settings', settings);
  }
}
```

### 6.2 Scanner Service

Handles document scanning and image picking.

```dart
// lib/services/scanner_service.dart

class ScannerService {
  /// Scan document using ML Kit
  Future<List<String>> scanDocument() async {
    final documentScanner = GoogleMlKit.documentScanner();
    final result = await documentScanner.scanDocument();
    return result.images;
  }

  /// Pick multiple images from gallery
  Future<List<String>> pickMultipleImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    return images.map((e) => e.path).toList();
  }

  /// Pick single image
  Future<String?> pickSingleImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  /// Crop image
  Future<String?> cropImage(String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColors.primaryGreen,
        ),
      ],
    );
    return croppedFile?.path;
  }
}
```

### 6.3 PDF Service

Handles PDF generation and customization.

```dart
// lib/services/pdf_service.dart

class PdfService {
  /// Convert images to PDF
  Future<void> convertImagesToPdf({
    required List<String> imagePaths,
    required String outputPath,
    PdfConfigModel config = const PdfConfigModel(),
  }) async {
    final pdf = PdfDocument();
    
    for (final imagePath in imagePaths) {
      final imageBytes = await File(imagePath).readAsBytes();
      final image = PdfImage(pdf, image: imageBytes);
      
      // Get page size
      final pageSize = _getPageSize(config.pageSize);
      
      final page = pdf.addPage(
        Page(
          pageFormat: pageSize,
          orientation: _getOrientation(config.orientation),
          margin: const EdgeInsets.all(0),
        ),
      );
      
      page.graphics.drawImage(
        image,
        Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
      );
    }
    
    final file = File(outputPath);
    await file.writeAsBytes(await pdf.save());
  }

  PdfPageFormat _getPageSize(String size) {
    switch (size) {
      case 'Letter':
        return PdfPageFormat.letter;
      case 'Legal':
        return PdfPageFormat.legal;
      case 'A4':
        return PdfPageFormat.a4;
      case 'A5':
        return PdfPageFormat.a5;
      case 'B4':
        return PdfPageFormat.b4;
      case 'B5':
        return PdfPageFormat.b5;
      default:
        return PdfPageFormat.letter;
    }
  }

  PdfPageOrientation _getOrientation(String orientation) {
    switch (orientation) {
      case 'Portrait':
        return PdfPageOrientation.portrait;
      case 'Landscape':
        return PdfPageOrientation.landscape;
      default:
        return PdfPageOrientation.portrait;
    }
  }
}
```

### 6.4 Data Models

The app uses several data models for managing documents and settings.

#### DocumentModel

```dart
// lib/data/models/document_model.dart

class DocumentModel {
  final String id;
  final String name;
  final String filePath;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final int pageCount;
  final int fileSize;
  
  // Methods: toJson, fromJson, copyWith, etc.
}
```

#### AppSettingsModel

```dart
// lib/data/models/app_settings_model.dart

class AppSettingsModel {
  final bool darkMode;
  final String defaultPdfSize;
  final String defaultOrientation;
  final int defaultQuality;
  final bool autoSave;
  
  // Methods: copyWith, toJson, fromJson
}
```

#### PdfConfigModel

```dart
// lib/data/models/pdf_config_model.dart

class PdfConfigModel {
  final String pageSize;      // Letter, Legal, A4, A5, B4, B5
  final String orientation;   // Portrait, Landscape
  final int quality;         // 1-100
  final bool compress;
  
  // Default: A4, Portrait, 100 quality
}
```

#### CardModel

```dart
// lib/data/models/card_model.dart

class CardModel {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
```

#### ParticleModel

```dart
// lib/data/models/particle_model.dart

class ParticleModel {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final double size;
  final double opacity;
  
  void update();
}
```

#### StatModel

```dart
// lib/data/models/stat_model.dart

class StatModel {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}
```

### 6.5 Theme Service

Handles app theming and dark mode switching.

```dart
// lib/services/theme_service.dart

class ThemeService {
  /// Get current theme mode
  ThemeMode getThemeMode(bool isDarkMode) {
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final storageService = GetIt.instance<StorageService>();
    final settings = storageService.getSettings();
    await storageService.saveSettings(
      settings.copyWith(darkMode: !settings.darkMode),
    );
  }
}
```

### 6.6 Navigation Service

Provides navigation helpers and route management.

```dart
// lib/services/navigation_service.dart

class NavigationService {
  /// Navigate to a named route
  Future<void> navigateTo(String routeName, {dynamic arguments}) async {
    // Navigation implementation
  }

  /// Pop the current route
  Future<void> pop() async {
    // Pop implementation
  }
}
```

### 6.7 Animation Service

Manages animations and animation controllers.

```dart
// lib/services/animation_service.dart

class AnimationService {
  /// Create animation controller
  AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
  }

  /// Create tween animation
  Animation<double> createTween(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(controller);
  }
}
```

### 6.8 Particle Service

Handles particle effects for visual animations.

```dart
// lib/services/particle_service.dart

class ParticleService {
  /// Generate particles for background effect
  List<ParticleModel> generateParticles(int count) {
    return List.generate(count, (index) => ParticleModel());
  }

  /// Update particle positions
  void updateParticles(List<ParticleModel> particles) {
    for (var particle in particles) {
      particle.update();
    }
  }
}
```

### 6.9 Data Flow

```
User Action
    ↓
Screen (UI)
    ↓
Service (Business Logic)
    ↓
Repository (Data Access)
    ↓
Storage (Hive/File System)
```

---

## 7. Dependency Injection

### GetIt Setup

```dart
// lib/core/di/injection.dart

import 'package:get_it/get_it.dart';
import '../../services/storage_service.dart';
import '../../services/pdf_service.dart';
import '../../services/scanner_service.dart';
import '../../services/theme_service.dart';
import '../../services/navigation_service.dart';
import '../../services/animation_service.dart';
import '../../services/particle_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services - Lazy singletons
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<PdfService>(() => PdfService());
  getIt.registerLazySingleton<ScannerService>(() => ScannerService());
  getIt.registerLazySingleton<ThemeService>(() => ThemeService());
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<AnimationService>(() => AnimationService());
  getIt.registerLazySingleton<ParticleService>(() => ParticleService());

  // Initialize storage
  await getIt<StorageService>().init();
}
```

### Usage in Screens

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get service
    final storageService = GetIt.instance<StorageService>();
    
    // Use service
    final documents = await storageService.getAllDocuments();
    
    return Scaffold(
      body: // UI
    );
  }
}
```

---

## 8. Environment Setup

### 8.1 Required Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  cupertino_icons: ^1.0.8

  # State Management
  provider: ^6.1.1
  flutter_bloc: ^8.1.3
  
  # Navigation
  go_router: ^14.2.0
  
  # Camera & Scanning
  camera: ^0.11.0+2
  google_mlkit_document_scanner: ^0.2.0
  google_mlkit_text_recognition: ^0.11.0
  
  # Image Processing
  image_picker: ^1.1.2
  image_cropper: ^8.0.2
  image: ^4.2.0
  
  # PDF
  pdf: ^3.11.1
  printing: ^5.13.1
  flutter_pdfview: ^1.4.0
  
  # File Management
  path_provider: ^2.1.4
  file_picker: ^8.1.2
  share_plus: ^10.0.0
  
  # Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # UI Components
  flutter_staggered_grid_view: ^0.7.0
  shimmer: ^3.0.0
  
  # Utils
  uuid: ^4.4.2
  intl: ^0.19.0
  permission_handler: ^11.3.1
  equatable: ^2.0.5
  get_it: ^7.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.11
  mockito: ^5.4.4
  mocktail: ^1.0.3
  integration_test:
    sdk: flutter
  flutter_launcher_icons: ^0.14.1
  flutter_native_splash: ^2.4.1
```

### 8.2 Android Configuration

**AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    
    <application
        android:label="DocScanner"
        ...>
        <!-- File Provider -->
        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.fileprovider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/file_paths"/>
        </provider>
    </application>
</manifest>
```

**file_paths.xml** (`android/app/src/main/res/xml/file_paths.xml`):

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <external-path name="external_files" path="."/>
    <cache-path name="cache" path="."/>
    <files-path name="files" path="."/>
    <external-cache-path name="external_cache" path="."/>
</paths>
```

### 8.3 iOS Configuration

**Info.plist** (`ios/Runner/Info.plist`):

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>This app requires camera access to scan documents.</string>

<!-- Photo Library Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app requires photo library access to import images for PDF conversion.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app requires photo library access to save scanned documents.</string>
```

### 8.4 Minimum SDK Versions

**Android** (`android/app/build.gradle.kts`):
```kotlin
minSdk = 21
```

**iOS**:
- Minimum iOS 12.0

---

## 9. Build & Run Instructions

### 9.1 Install Dependencies

```bash
# Navigate to project
cd docscanner

# Get dependencies
flutter pub get
```

### 9.2 Android

#### Debug APK
```bash
# Build debug APK
flutter build apk --debug

# Install on connected device
flutter install
```

#### Release APK
```bash
# Build release APK
flutter build apk --release
```

#### App Bundle (for Play Store)
```bash
# Build App Bundle
flutter build appbundle --release
```

### 9.3 iOS

#### Simulator
```bash
# List available simulators
xcrun simctl list devices available

# Run on iOS Simulator
flutter run -d "iPhone 15"
```

#### Device
```bash
# Run on connected iOS device
flutter run -d <device-id>
```

#### Build for Release
```bash
# iOS release build
flutter build ios --release
```

### 9.4 Web (Optional)

```bash
# Build for web
flutter build web

# Serve locally
flutter serve
```

---

## 10. Troubleshooting

### Common Issues

#### 1. Camera Permission Denied

**Solution**: Check AndroidManifest.xml and Info.plist for proper permission declarations.

#### 2. ML Kit Not Working

**Solution**: Ensure `google_mlkit_document_scanner` and `google_mlkit_text_recognition` are properly configured.

#### 3. PDF Generation Fails

**Check**:
- Sufficient storage space
- Proper file path permissions
- Image format compatibility (JPEG, PNG)

#### 4. App Crashes on Launch

**Solutions**:
- Run `flutter clean`
- Re-run `flutter pub get`
- Check minimum SDK version in `android/app/build.gradle.kts`

#### 5. Hive Storage Errors

**Solution**: Ensure Hive is properly initialized in `main.dart`:
```dart
await Hive.initFlutter();
await Hive.openBox('documents');
await Hive.openBox('settings');
```

### Debug Mode

```bash
# Run with verbose logging
flutter run -v

# Run with debugger
flutter run --debug
```

### Get Help

For additional help:
- Flutter Documentation: https://docs.flutter.dev/
- Package Documentation: https://pub.dev/
- GitHub Issues: Report bugs at project repository

---

## 📱 Build Information

- **App Name**: DocScanner
- **Version**: 1.0.0
- **Min Android SDK**: 21 (Android 5.0)
- **Min iOS**: 12.0

---

## 📄 License

This project is licensed under the MIT License.

---

*Documentation generated for Flutter DocScanner App*

