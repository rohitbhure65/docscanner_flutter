import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/documents/document_detail_screen.dart';
import '../../presentation/screens/documents/documents_screen.dart';
import '../../presentation/screens/documents/pdf_viewer_screen.dart';
import '../../presentation/screens/home/main_screen.dart';
import '../../presentation/screens/image_to_pdf/image_to_pdf_screen.dart';
import '../../presentation/screens/ocr/ocr_result_screen.dart';
import '../../presentation/screens/scan/scan_preview_screen.dart';
import '../../presentation/screens/scan/scan_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';

/// App router configuration using GoRouter
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/scan',
    debugLogDiagnostics: true,
    routes: [
      // Shell route for bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScreen(child: child);
        },
        routes: [
          // Scan Tab
          GoRoute(
            path: '/scan',
            name: 'scan',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: ScanScreen());
            },
            routes: [
              GoRoute(
                path: 'preview',
                name: 'scanPreview',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return ScanPreviewScreen(
                    imagePaths: extra?['imagePaths'] ?? [],
                  );
                },
              ),
            ],
          ),

          // Documents Tab
          GoRoute(
            path: '/documents',
            name: 'documents',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: DocumentsScreen());
            },
            routes: [
              GoRoute(
                path: 'detail',
                name: 'documentDetail',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return DocumentDetailScreen(
                    documentId: extra?['documentId'] ?? '',
                  );
                },
              ),
              GoRoute(
                path: 'viewer',
                name: 'pdfViewer',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return PdfViewerScreen(
                    pdfPath: extra?['pdfPath'] ?? '',
                    documentName: extra?['documentName'] ?? 'Document',
                  );
                },
              ),
            ],
          ),

          // Image to PDF Tab
          GoRoute(
            path: '/image-to-pdf',
            name: 'imageToPdf',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: ImageToPdfScreen());
            },
          ),

          // Settings Tab
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) {
              return const NoTransitionPage(child: SettingsScreen());
            },
          ),
        ],
      ),

      // OCR Result Screen (outside shell)
      GoRoute(
        path: '/ocr-result',
        name: 'ocrResult',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OcrResultScreen(
            imagePath: extra?['imagePath'] ?? '',
            recognizedText: extra?['recognizedText'] ?? '',
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      );
    },
  );
}

/// Route names for type-safe navigation
class Routes {
  Routes._();

  static const String scan = '/scan';
  static const String scanPreview = '/scan/preview';
  static const String documents = '/documents';
  static const String documentDetail = '/documents/detail';
  static const String pdfViewer = '/documents/viewer';
  static const String imageToPdf = '/image-to-pdf';
  static const String settings = '/settings';
  static const String ocrResult = '/ocr-result';
}
