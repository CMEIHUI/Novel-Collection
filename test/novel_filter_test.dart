import 'package:flutter_test/flutter_test.dart';
import 'package:novel_collection/models/novel.dart';
import 'package:novel_collection/utils/novel_filter.dart';

void main() {
  group('applyNovelFilters', () {
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
        author: 'King',
        genre: 'Horror',
        rating: 3.9,
        review: 'Scary',
      ),
    ];

    test('filters by genre and minimum rating and sorts alphabetically', () {
      final result = applyNovelFilters(
        novels: novels,
        keyword: '',
        genre: 'Fantasy',
        author: 'All',
        minimumRating: 4.0,
        recentlyAdded: false,
      );

      expect(result.length, 1);
      expect(result.first.title, 'The Hobbit');
    });

    test('sorts by recency when requested', () {
      final result = applyNovelFilters(
        novels: novels,
        keyword: '',
        genre: 'All',
        author: 'All',
        minimumRating: 0,
        recentlyAdded: true,
      );

      expect(result.first.id, 3);
      expect(result.last.id, 1);
    });
  });
}
