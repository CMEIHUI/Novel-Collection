import 'dart:convert';
import 'dart:typed_data';

import '../models/novel.dart';
import 'file_saver.dart';

Future<void> exportNovelsToFile(
  List<Novel> novels, {
  required String format,
}) async {
  final rows = novels.map((novel) {
    return [
      novel.title,
      novel.author,
      novel.genre,
      novel.rating.toStringAsFixed(1),
      novel.review,
      novel.isFavorite ? 'Yes' : 'No',
      novel.totalPages.toString(),
      novel.pagesRead.toString(),
    ];
  }).toList();

  String content;
  if (format.toLowerCase() == 'csv') {
    final lines = <String>[];
    lines.add('Title,Author,Genre,Rating,Review,Favorite,TotalPages,PagesRead');
    for (final row in rows) {
      lines.add(row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(','));
    }
    content = lines.join('\n');
  } else if (format.toLowerCase() == 'pdf') {
    content = 'Novel Report\n\n${novels.map((novel) {
      return 'Title: ${novel.title}\nAuthor: ${novel.author}\nGenre: ${novel.genre}\nRating: ${novel.rating.toStringAsFixed(1)}\nProgress: ${novel.pagesRead}/${novel.totalPages}\n';
    }).join('\n')}';
  } else {
    final tsvRows = rows.map((row) => row.join('\t')).join('\n');
    content = 'Title\tAuthor\tGenre\tRating\tReview\tFavorite\tTotalPages\tPagesRead\n$tsvRows';
  }

  final bytes = Uint8List.fromList(utf8.encode(content));
  final extension = format.toLowerCase() == 'csv'
      ? 'csv'
      : format.toLowerCase() == 'pdf'
      ? 'txt'
      : 'xls';
  final fileName =
      'novel_list_${DateTime.now().toIso8601String().replaceAll(':', '-')}.$extension';

  await FileSaver.saveFile(
    fileName: fileName,
    bytes: bytes,
    allowedExtensions: [extension],
  );
}
