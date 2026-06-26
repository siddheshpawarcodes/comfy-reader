/// A bookmark on a specific page of a book. Persisted to Hive keyed by
/// `'{bookId}:{pageIndex}'`.
class BookmarkModel {
  const BookmarkModel({
    required this.bookId,
    required this.pageIndex,
    required this.createdAt,
    this.note,
  });

  final String bookId;

  /// 0-based page index.
  final int pageIndex;

  final DateTime createdAt;

  final String? note;

  /// Hive key for this bookmark.
  String get key => storageKey(bookId, pageIndex);

  static String storageKey(String bookId, int pageIndex) =>
      '$bookId:$pageIndex';

  BookmarkModel copyWith({String? note}) {
    return BookmarkModel(
      bookId: bookId,
      pageIndex: pageIndex,
      createdAt: createdAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'bookId': bookId,
      'pageIndex': pageIndex,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory BookmarkModel.fromMap(Map<dynamic, dynamic> map) {
    return BookmarkModel(
      bookId: map['bookId'] as String,
      pageIndex: (map['pageIndex'] as num).toInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['createdAt'] as num?)?.toInt() ?? 0,
      ),
      note: map['note'] as String?,
    );
  }
}
