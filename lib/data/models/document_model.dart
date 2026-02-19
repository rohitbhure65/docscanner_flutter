import 'package:equatable/equatable.dart';

/// Model representing a scanned document
class DocumentModel extends Equatable {
  final String id;
  final String name;
  final List<PageModel> pages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pdfPath;
  final int fileSize;
  final String documentType;

  const DocumentModel({
    required this.id,
    required this.name,
    required this.pages,
    required this.createdAt,
    required this.updatedAt,
    this.pdfPath,
    this.fileSize = 0,
    this.documentType = 'scanned',
  });

  int get pageCount => pages.length;

  DocumentModel copyWith({
    String? id,
    String? name,
    List<PageModel>? pages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? pdfPath,
    int? fileSize,
    String? documentType,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pdfPath: pdfPath ?? this.pdfPath,
      fileSize: fileSize ?? this.fileSize,
      documentType: documentType ?? this.documentType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pages': pages.map((page) => page.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pdfPath': pdfPath,
      'fileSize': fileSize,
      'documentType': documentType,
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      pages: (json['pages'] as List<dynamic>)
          .map((page) => PageModel.fromJson(page as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      pdfPath: json['pdfPath'] as String?,
      fileSize: json['fileSize'] as int? ?? 0,
      documentType: json['documentType'] as String? ?? 'scanned',
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    pages,
    createdAt,
    updatedAt,
    pdfPath,
    fileSize,
    documentType,
  ];
}

/// Model representing a single scanned page
class PageModel extends Equatable {
  final String id;
  final String imagePath;
  final String? thumbnailPath;
  final int pageNumber;
  final int rotation; // 0, 90, 180, 270
  final String? ocrText;
  final DateTime createdAt;

  const PageModel({
    required this.id,
    required this.imagePath,
    this.thumbnailPath,
    required this.pageNumber,
    this.rotation = 0,
    this.ocrText,
    required this.createdAt,
  });

  PageModel copyWith({
    String? id,
    String? imagePath,
    String? thumbnailPath,
    int? pageNumber,
    int? rotation,
    String? ocrText,
    DateTime? createdAt,
  }) {
    return PageModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      pageNumber: pageNumber ?? this.pageNumber,
      rotation: rotation ?? this.rotation,
      ocrText: ocrText ?? this.ocrText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'thumbnailPath': thumbnailPath,
      'pageNumber': pageNumber,
      'rotation': rotation,
      'ocrText': ocrText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      pageNumber: json['pageNumber'] as int,
      rotation: json['rotation'] as int? ?? 0,
      ocrText: json['ocrText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    imagePath,
    thumbnailPath,
    pageNumber,
    rotation,
    ocrText,
    createdAt,
  ];
}
