import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../database/app_repository.dart';
import '../models/novel.dart';
import '../utils/novel_charts.dart';
import '../utils/novel_stats.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _loading = true;
  List<Novel> _novels = [];
  NovelDashboardStats _stats = const NovelDashboardStats(
    totalNovels: 0,
    averageRating: 0.0,
    favoriteGenre: 'N/A',
    authorCount: 0,
  );
  NovelChartData? _chartData;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final novels = await AppRepository.instance.getNovels();
    if (!mounted) return;
    setState(() {
      _novels = novels;
      _stats = calculateNovelDashboardStats(novels);
      _chartData = buildNovelChartData(novels);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: const Color(0xFF6D4C41),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _novels.isEmpty
          ? const Center(child: Text('No novels available yet.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCards(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Genre Distribution'),
                  const SizedBox(height: 12),
                  _buildGenrePieChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Ratings Breakdown'),
                  const SizedBox(height: 12),
                  _buildRatingBarChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Reading Progress'),
                  const SizedBox(height: 12),
                  _buildProgressBarChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildStatCard('Total Novels', _stats.totalNovels.toString()),
        _buildStatCard('Average Rating', _stats.averageRating.toString()),
        _buildStatCard('Favorite Genre', _stats.favoriteGenre),
        _buildStatCard('Authors', _stats.authorCount.toString()),
      ],
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildGenrePieChart() {
    if (_chartData == null || _chartData!.genreSections.isEmpty) {
      return const Center(child: Text('No genre data to render.'));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 260,
          child: PieChart(
            PieChartData(
              sections: _chartData!.genreSections,
              sectionsSpace: 6,
              centerSpaceRadius: 36,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBarChart() {
    if (_chartData == null || _chartData!.ratingBars.isEmpty) {
      return const Center(child: Text('No rating data to render.'));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              barGroups: _chartData!.ratingBars,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(value.toInt().toString()),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBarChart() {
    if (_chartData == null || _chartData!.progressBars.isEmpty) {
      return const Center(child: Text('No progress data to render.'));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              barGroups: _chartData!.progressBars,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final entry = _chartData!.progressBars.firstWhere(
                        (element) => element.x == value,
                        orElse: () => BarChartGroupData(x: 0, barRods: []),
                      );
                      final label = _progressLabelForEntry(entry);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ),
    );
  }

  String _progressLabelForEntry(BarChartGroupData entry) {
    if (_chartData == null) return '';
    final index = _chartData!.progressBars.indexOf(entry);
    final labels = ['0-24%', '25-49%', '50-74%', '75%+'];
    return index >= 0 && index < labels.length ? labels[index] : '';
  }
}
