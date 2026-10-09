import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/novel.dart';
import '../widgets/novel_card.dart';
import 'edit_novel_screen.dart';
import 'novel_reader_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Novel> favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final allNovels = await DatabaseHelper.instance.getNovels();
    if (!mounted) return;
    setState(() {
      favorites = allNovels.where((novel) => novel.isFavorite).toList();
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(Novel novel) async {
    final updated = Novel(
      id: novel.id,
      title: novel.title,
      author: novel.author,
      genre: novel.genre,
      rating: novel.rating,
      review: novel.review,
      coverImage: novel.coverImage,
      isFavorite: !novel.isFavorite,
    );

    await DatabaseHelper.instance.updateNovel(updated);
    await _loadFavorites();
  }

  Future<void> _deleteNovel(int id) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Novel'),
        content: const Text('Are you sure you want to delete this novel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await DatabaseHelper.instance.deleteNovel(id);
      await _loadFavorites();
    }
  }

  Future<void> _editNovel(Novel novel) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditNovelScreen(novel: novel)),
    );
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFF6D4C41),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No favorite novels yet. Add one from the library to see it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final novel = favorites[index];
                return NovelCard(
                  novel: novel,
                  onEdit: () => _editNovel(novel),
                  onDelete: () => _deleteNovel(novel.id!),
                  onToggleFavorite: () => _toggleFavorite(novel),
                  onStartReading: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NovelReaderScreen(novel: novel),
                      ),
                    );
                  },
                  onContinueReading: novel.totalPages > novel.pagesRead
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NovelReaderScreen(novel: novel),
                            ),
                          );
                        }
                      : null,
                );
              },
            ),
    );
  }
}
