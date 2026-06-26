import 'dart:convert';

import 'package:crypto/crypto.dart';

/// A PDF book in the library. Persisted to Hive as a [Map] (see toMap/fromMap).
class BookModel {
  const BookModel({
    required this.id,
    required this.title,
    required this.filePath,
    required this.totalPages,
    required this.fileSize,
    required this.addedAt,
    this.coverImagePath,
    this.lastReadPage = 0,
    this.lastOpened,
    this.isImported = true,
  });

  /// Stable id derived from file path + size (see [computeId]).
  final String id;

  /// Display name (file name without extension).
  final String title;

  /// Absolute path to the PDF on disk.
  final String filePath;

  /// Optional path to the generated cover image (rendered first page).
  final String? coverImagePath;

  final int totalPages;

  /// Last page the user was on (0-based).
  final int lastReadPage;

  /// File size in bytes.
  final int fileSize;

  final DateTime addedAt;

  /// When the book was last opened (null if never).
  final DateTime? lastOpened;

  /// True if imported via the picker; false if discovered on device.
  final bool isImported;

  /// Reading progress in [0, 1]. Derived, not stored.
  double get progress {
    if (totalPages <= 0) return 0;
    return ((lastReadPage + 1) / totalPages).clamp(0.0, 1.0);
  }

  /// True once the reader has moved past the first page.
  bool get hasStarted => lastReadPage > 0;

  /// Stable id = sha1(filePath + fileSize). Same file → same id across launches.
  static String computeId(String filePath, int fileSize) {
    return sha1.convert(utf8.encode('$filePath::$fileSize')).toString();
  }

  /// Builds a fresh book from a file path + size, computing the id and title.
  factory BookModel.create({
    required String filePath,
    required int fileSize,
    required int totalPages,
    required DateTime addedAt,
    String? coverImagePath,
    bool isImported = true,
  }) {
    final name = filePath.split('/').last;
    final title = name.toLowerCase().endsWith('.pdf')
        ? name.substring(0, name.length - 4)
        : name;
    return BookModel(
      id: computeId(filePath, fileSize),
      title: title,
      filePath: filePath,
      totalPages: totalPages,
      fileSize: fileSize,
      addedAt: addedAt,
      coverImagePath: coverImagePath,
      isImported: isImported,
    );
  }

  BookModel copyWith({
    String? title,
    String? filePath,
    String? coverImagePath,
    int? totalPages,
    int? lastReadPage,
    int? fileSize,
    DateTime? lastOpened,
    bool? isImported,
  }) {
    return BookModel(
      id: id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      totalPages: totalPages ?? this.totalPages,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      fileSize: fileSize ?? this.fileSize,
      addedAt: addedAt,
      lastOpened: lastOpened ?? this.lastOpened,
      isImported: isImported ?? this.isImported,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'filePath': filePath,
      'coverImagePath': coverImagePath,
      'totalPages': totalPages,
      'lastReadPage': lastReadPage,
      'fileSize': fileSize,
      'addedAt': addedAt.millisecondsSinceEpoch,
      'lastOpened': lastOpened?.millisecondsSinceEpoch,
      'isImported': isImported,
    };
  }

  factory BookModel.fromMap(Map<dynamic, dynamic> map) {
    final lastOpenedMs = map['lastOpened'] as int?;
    return BookModel(
      id: map['id'] as String,
      title: map['title'] as String,
      filePath: map['filePath'] as String,
      coverImagePath: map['coverImagePath'] as String?,
      totalPages: (map['totalPages'] as num?)?.toInt() ?? 0,
      lastReadPage: (map['lastReadPage'] as num?)?.toInt() ?? 0,
      fileSize: (map['fileSize'] as num?)?.toInt() ?? 0,
      addedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['addedAt'] as num?)?.toInt() ?? 0,
      ),
      lastOpened: lastOpenedMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastOpenedMs),
      isImported: map['isImported'] as bool? ?? true,
    );
  }
}
