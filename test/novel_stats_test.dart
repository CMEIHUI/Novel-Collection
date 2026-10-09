import 'package:flutter_test/flutter_test.dart';
import 'package:novel_collection/models/novel.dart';
import 'package:novel_collection/utils/novel_stats.dart';

void main() {
  group('calculateNovelDashboardStats', () {
    test('computes totals, averages, favorite genre, and author count', () {
      final novels = [
        Novel(
          id: 1,
          title: 'The Hobbit',
          author: 'Tolkien',
          genre: 'Fantasy',
          rating: 4.8,
          review: 'Great',
        ),
        Novel(
          id: 2,
          title: 'Dune',
          author: 'Herbert',
          genre: 'Science Fiction',
          rating: 4.2,
          review: 'Classic',
        ),
        Novel(
          id: 3,
          title: 'The Shining',
          author: 'Tolkien',
          genre: 'Fantasy',
          rating: 3.9,
          review: 'Scary',
        ),
      ];

      final stats = calculateNovelDashboardStats(novels);

      expect(stats.totalNovels, 3);
      expect(stats.averageRating, 4.3);
      expect(stats.favoriteGenre, 'Fantasy');
      expect(stats.authorCount, 2);
    });
  });
}
