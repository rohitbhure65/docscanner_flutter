import 'package:get_it/get_it.dart';

import '../../services/pdf_service.dart';
import '../../services/scanner_service.dart';
import '../../services/storage_service.dart';

/// Service locator instance
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<StorageService>(() => StorageService());
  getIt.registerLazySingleton<PdfService>(() => PdfService());
  getIt.registerLazySingleton<ScannerService>(() => ScannerService());

  // Initialize storage
  await getIt<StorageService>().init();
}
