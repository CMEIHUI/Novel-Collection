import 'package:flutter/material.dart';

import '../models/novel.dart';
import '../utils/cover_image_service.dart';
import '../database/database_helper.dart';
import 'edit_novel_screen.dart';
import '../database/app_repository.dart';
import 'novel_reader_screen.dart';

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.novel});

  final Novel novel;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.novel.isFavorite;
  }

  void _toggleFavorite() async {
    final updated = Novel(
      id: widget.novel.id,
      title: widget.novel.title,
      author: widget.novel.author,
      genre: widget.novel.genre,
      rating: widget.novel.rating,
      review: widget.novel.review,
      coverImage: widget.novel.coverImage,
      isFavorite: !isFavorite,
      totalPages: widget.novel.totalPages,
      pagesRead: widget.novel.pagesRead,
      lastOpenedChapter: widget.novel.lastOpenedChapter,
    );

    await DatabaseHelper.instance.updateNovel(updated);
    setState(() => isFavorite = !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final novel = widget.novel;
    final tag = 'cover-${novel.id ?? novel.title}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: tag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: novel.coverImage != null && novel.coverImage!.isNotEmpty
                    ? CoverImageService.buildCoverPreview(
                        coverValue: novel.coverImage,
                        width: double.infinity,
                        height: 320,
                      )
                    : Container(
                        height: 320,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.menu_book,
                            size: 56,
                            color: Colors.brown,
                          ),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              novel.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(novel.author, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Chip(label: Text(novel.genre)),

            const SizedBox(height: 16),
            Text(
              novel.review.isNotEmpty
                  ? novel.review
                  : 'No description available.',
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: IconButton(
                    key: ValueKey<bool>(isFavorite),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.black,
                    ),
                    onPressed: _toggleFavorite,
                    iconSize: 30,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NovelReaderScreen(novel: widget.novel),
                      ),
                    );
                  },
                  icon: const Icon(Icons.book),
                  label: const Text('Start Reading'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) {
                        final chapterController = TextEditingController(
                          text: widget.novel.lastOpenedChapter ?? '',
                        );
                        final pagesController = TextEditingController(
                          text: widget.novel.pagesRead.toString(),
                        );
                        return AlertDialog(
                          title: const Text('Update Reading Progress'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: chapterController,
                                decoration: const InputDecoration(
                                  labelText: 'Last opened chapter',
                                ),
                              ),
                              TextField(
                                controller: pagesController,
                                decoration: const InputDecoration(
                                  labelText: 'Pages read',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop({
                                'chapter': chapterController.text,
                                'pages':
                                    int.tryParse(pagesController.text) ??
                                    widget.novel.pagesRead,
                              }),
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );

                    if (result != null && result.isNotEmpty) {
                      final updated = Novel(
                        id: widget.novel.id,
                        title: widget.novel.title,
                        author: widget.novel.author,
                        genre: widget.novel.genre,
                        rating: widget.novel.rating,
                        review: widget.novel.review,
                        coverImage: widget.novel.coverImage,
                        isFavorite: widget.novel.isFavorite,
                        totalPages: widget.novel.totalPages,
                        pagesRead: result['pages'] as int,
                        lastOpenedChapter: result['chapter'] as String,
                      );

                      await DatabaseHelper.instance.updateNovel(updated);
                      final all = await AppRepository.instance.getNovels();
                      final refreshed = all.firstWhere(
                        (n) => n.id == widget.novel.id,
                        orElse: () => widget.novel,
                      );
                      setState(() {
                        widget.novel.pagesRead = refreshed.pagesRead;
                        widget.novel.lastOpenedChapter =
                            refreshed.lastOpenedChapter;
                      });
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Continue Reading'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditNovelScreen(novel: novel),
                      ),
                    );

                    if (novel.id != null) {
                      final all = await AppRepository.instance.getNovels();
                      final updated = all.firstWhere(
                        (n) => n.id == novel.id,
                        orElse: () => novel,
                      );
                      setState(() {
                        widget.novel.title = updated.title;
                        widget.novel.author = updated.author;
                        widget.novel.genre = updated.genre;
                        widget.novel.review = updated.review;
                        widget.novel.coverImage = updated.coverImage;
                        widget.novel.isFavorite = updated.isFavorite;
                        widget.novel.rating = updated.rating;
                        widget.novel.totalPages = updated.totalPages;
                        widget.novel.pagesRead = updated.pagesRead;
                        isFavorite = updated.isFavorite;
                      });
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    // Return deletion request
                    Navigator.of(context).pop({'delete': true});
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
