import '../models/novel.dart';

List<Novel> applyNovelFilters({
  required List<Novel> novels,
  required String keyword,
  required String genre,
  required String author,
  required double minimumRating,
  required bool recentlyAdded,
  bool alphabetical = true,
}) {
  final query = keyword.trim().toLowerCase();

  var filtered = novels.where((novel) {
    final matchesText =
        query.isEmpty ||
        novel.title.toLowerCase().contains(query) ||
        novel.author.toLowerCase().contains(query);
    final matchesCategory =
        novel.genre.toLowerCase().contains(query) || query.isEmpty;
    final matchesGenre =
        genre == 'All' || novel.genre.toLowerCase() == genre.toLowerCase();
    final matchesAuthor =
        author == 'All' || novel.author.toLowerCase() == author.toLowerCase();
    final matchesRating = novel.rating >= minimumRating;

    return (matchesText || matchesCategory) &&
        matchesGenre &&
        matchesAuthor &&
        matchesRating;
  }).toList();

  if (recentlyAdded) {
    filtered.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
  } else if (alphabetical) {
    filtered.sort(
      (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    );
  }

  return filtered;
}
