import '../models/novel.dart';

class NovelDashboardStats {
  final int totalNovels;
  final double averageRating;
  final String favoriteGenre;
  final int authorCount;

  const NovelDashboardStats({
    required this.totalNovels,
    required this.averageRating,
    required this.favoriteGenre,
    required this.authorCount,
  });
}

NovelDashboardStats calculateNovelDashboardStats(List<Novel> novels) {
  if (novels.isEmpty) {
    return const NovelDashboardStats(
      totalNovels: 0,
      averageRating: 0.0,
      favoriteGenre: 'N/A',
      authorCount: 0,
    );
  }

  final totalRating = novels.fold<double>(
    0.0,
    (sum, novel) => sum + novel.rating,
  );
  final avgRating = totalRating / novels.length;

  final genreCounts = <String, int>{};
  for (final novel in novels) {
    genreCounts[novel.genre] = (genreCounts[novel.genre] ?? 0) + 1;
  }

  final favoriteGenre = genreCounts.entries.isEmpty
      ? 'N/A'
      : genreCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

  final authorCount = novels.map((novel) => novel.author).toSet().length;

  return NovelDashboardStats(
    totalNovels: novels.length,
    averageRating: double.parse(avgRating.toStringAsFixed(1)),
    favoriteGenre: favoriteGenre,
    authorCount: authorCount,
  );
}
