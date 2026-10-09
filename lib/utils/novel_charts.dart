import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/novel.dart';

class NovelChartData {
  final List<PieChartSectionData> genreSections;
  final List<BarChartGroupData> ratingBars;
  final List<BarChartGroupData> progressBars;

  const NovelChartData({
    required this.genreSections,
    required this.ratingBars,
    required this.progressBars,
  });
}

NovelChartData buildNovelChartData(List<Novel> novels) {
  final genreCounts = <String, int>{};
  final ratingBuckets = <int, int>{};
  final progressBuckets = <String, int>{};

  for (final novel in novels) {
    genreCounts[novel.genre] = (genreCounts[novel.genre] ?? 0) + 1;

    final roundedRating = (novel.rating.round()).clamp(1, 5);
    ratingBuckets[roundedRating] = (ratingBuckets[roundedRating] ?? 0) + 1;

    final progress = novel.totalPages > 0
        ? ((novel.pagesRead / novel.totalPages) * 100).round()
        : 0;
    final bucket = progress < 25
        ? '0-24%'
        : progress < 50
        ? '25-49%'
        : progress < 75
        ? '50-74%'
        : '75%+';
    progressBuckets[bucket] = (progressBuckets[bucket] ?? 0) + 1;
  }

  final genreSections = genreCounts.entries.map((entry) {
    final color = _genreColor(entry.key);
    return PieChartSectionData(
      title: entry.key,
      value: entry.value.toDouble(),
      color: color,
      radius: 70,
      titleStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }).toList();

  final ratingBars = ratingBuckets.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final progressBars = progressBuckets.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return NovelChartData(
    genreSections: genreSections,
    ratingBars: ratingBars.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.brown,
            width: 16,
          ),
        ],
      );
    }).toList(),
    progressBars: progressBars.map((entry) {
      return BarChartGroupData(
        x: entry.key.hashCode,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            color: Colors.deepPurple,
            width: 16,
          ),
        ],
      );
    }).toList(),
  );
}

Color _genreColor(String genre) {
  switch (genre.toLowerCase()) {
    case 'fantasy':
      return Colors.deepPurple;
    case 'mystery':
      return Colors.blue;
    case 'romance':
      return Colors.pink;
    case 'science fiction':
      return Colors.teal;
    case 'adventure':
      return Colors.orange;
    case 'horror':
      return Colors.red;
    case 'thriller':
      return Colors.indigo;
    case 'historical':
      return Colors.green;
    default:
      return Colors.brown;
  }
}
