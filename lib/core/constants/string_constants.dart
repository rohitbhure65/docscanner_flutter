/// App string constants
class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'DocScanner';
  static const String appTagline = 'Scan. Save. Share.';

  // Navigation
  static const String navScan = 'Scan';
  static const String navDocuments = 'Documents';
  static const String navImageToPdf = 'Image to PDF';
  static const String navSettings = 'Settings';

  // Scan Screen
  static const String scanTitle = 'Scan Document';
  static const String scanSinglePage = 'Single Page';
  static const String scanTwoPages = 'Two Pages';
  static const String scanAutoDetect = 'Auto Detect';
  static const String scanManual = 'Manual';
  static const String captureDocument = 'Capture Document';
  static const String retake = 'Retake';
  static const String usePhoto = 'Use Photo';
  static const String scanAgain = 'Scan Again';
  static const String doneScanning = 'Done';
  static const String selectImage = 'Select Image';
  static const String addMorePages = 'Add More Pages';
  static const String autoScan = 'Auto Scan';
  static const String autoScanDescription =
      'Automatically detect and crop document edges';

  // Documents Screen
  static const String documentsTitle = 'My Documents';
  static const String noDocuments = 'No documents yet';
  static const String noDocumentsSubtitle =
      'Scan your first document to get started';
  static const String searchDocuments = 'Search documents...';
  static const String sortBy = 'Sort by';
  static const String sortByName = 'Name';
  static const String sortByDate = 'Date';
  static const String sortBySize = 'Size';

  // Document Detail
  static const String documentDetails = 'Document Details';
  static const String pages = 'Pages';
  static const String createdOn = 'Created on';
  static const String fileSize = 'File Size';
  static const String openPdf = 'Open PDF';
  static const String sharePdf = 'Share PDF';
  static const String deletePdf = 'Delete PDF';
  static const String renamePdf = 'Rename PDF';

  // Image to PDF Screen
  static const String imageToPdfTitle = 'Image to PDF';
  static const String selectImages = 'Select Images';
  static const String noImagesSelected = 'No images selected';
  static const String noImagesSelectedSubtitle =
      'Tap the button below to select images';
  static const String convertToPdf = 'Convert to PDF';
  static const String reorderImages = 'Reorder Images';
  static const String removeImage = 'Remove Image';

  // PDF Settings
  static const String pdfSettings = 'PDF Settings';
  static const String pageSize = 'Page Size';
  static const String orientation = 'Orientation';
  static const String quality = 'Quality';
  static const String customSize = 'Custom Size';
  static const String width = 'Width';
  static const String height = 'Height';

  // Settings Screen
  static const String settingsTitle = 'Settings';
  static const String generalSettings = 'General';
  static const String defaultSettings = 'Default Settings';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String storage = 'Storage';
  static const String clearCache = 'Clear Cache';
  static const String about = 'About';
  static const String version = 'Version';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';

  // OCR
  static const String extractText = 'Extract Text';
  static const String textRecognition = 'Text Recognition';
  static const String copyText = 'Copy Text';
  static const String shareText = 'Share Text';
  static const String noTextFound = 'No text found';
  static const String recognizingText = 'Recognizing text...';

  // Page Management
  static const String editPage = 'Edit Page';
  static const String cropPage = 'Crop Page';
  static const String rotatePage = 'Rotate Page';
  static const String deletePage = 'Delete Page';
  static const String reorderPages = 'Reorder Pages';

  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String rename = 'Rename';
  static const String share = 'Share';
  static const String done = 'Done';
  static const String ok = 'OK';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String confirm = 'Confirm';
  static const String select = 'Select';
  static const String apply = 'Apply';

  // Messages
  static const String loading = 'Loading...';
  static const String processing = 'Processing...';
  static const String saving = 'Saving...';
  static const String deleting = 'Deleting...';
  static const String converting = 'Converting...';
  static const String scanning = 'Scanning...';

  // Success Messages
  static const String documentSaved = 'Document saved successfully';
  static const String pdfCreated = 'PDF created successfully';
  static const String textCopied = 'Text copied to clipboard';
  static const String documentDeleted = 'Document deleted';
  static const String documentRenamed = 'Document renamed';

  // Error Messages
  static const String errorGeneric = 'Something went wrong';
  static const String errorCamera = 'Camera error occurred';
  static const String errorScan = 'Failed to scan document';
  static const String errorOcr = 'Failed to recognize text';
  static const String errorPdf = 'Failed to create PDF';
  static const String errorSave = 'Failed to save document';
  static const String errorLoad = 'Failed to load document';
  static const String errorDelete = 'Failed to delete document';
  static const String errorShare = 'Failed to share document';
  static const String errorPermission = 'Permission denied';
  static const String errorNoCamera = 'No camera available';

  // Confirmations
  static const String confirmDelete = 'Are you sure you want to delete this?';
  static const String confirmDeleteDocument =
      'This will permanently delete the document. This action cannot be undone.';
  static const String confirmDeletePage =
      'Are you sure you want to delete this page?';

  // Empty States
  static const String emptyTitle = 'Nothing here yet';
  static const String emptySubtitle = 'Get started by scanning a document';

  // Permissions
  static const String cameraPermission =
      'Camera permission is required to scan documents';
  static const String storagePermission =
      'Storage permission is required to save documents';
  static const String grantPermission = 'Grant Permission';

  // Document Types
  static const String scannedDocument = 'Scanned Document';
  static const String imagePdf = 'Image to PDF';
}
