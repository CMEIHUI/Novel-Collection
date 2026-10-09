import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/novel.dart';
import '../utils/cover_image_service.dart';

class NovelCard extends StatelessWidget {
  final Novel novel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onStartReading;
  final VoidCallback? onContinueReading;

  const NovelCard({
    super.key,
    required this.novel,
    required this.onEdit,
    required this.onDelete,
    this.onToggleFavorite,
    this.onStartReading,
    this.onContinueReading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      elevation: 5,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey.shade300,
              ),
              child: (novel.coverImage != null && novel.coverImage!.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CoverImageService.buildCoverPreview(
                        coverValue: novel.coverImage,
                        width: 80,
                        height: 120,
                      ),
                    )
                  : const Icon(Icons.menu_book, size: 45, color: Colors.brown),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    novel.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4E342E),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.brown),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          novel.author,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Chip(
                    avatar: const Icon(
                      Icons.book,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      novel.genre,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.brown,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),

                      const SizedBox(width: 5),

                      Text(
                        "${novel.rating.toStringAsFixed(1)} / 5",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (novel.totalPages > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_stories,
                              size: 18,
                              color: Colors.brown,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${novel.pagesRead} / ${novel.totalPages} pages',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: novel.totalPages > 0
                              ? novel.pagesRead / novel.totalPages
                              : 0,
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.brown,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${((novel.pagesRead / (novel.totalPages == 0 ? 1 : novel.totalPages)) * 100).toStringAsFixed(0)}% complete',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),

                  Text(
                    novel.review,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),

                  const SizedBox(height: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: onToggleFavorite,
                            icon: Icon(
                              novel.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: novel.isFavorite
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            tooltip: novel.isFavorite
                                ? 'Remove from favorites'
                                : 'Add to favorites',
                          ),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("Edit"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: onDelete,
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text("Delete"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onStartReading != null)
                            ElevatedButton.icon(
                              onPressed: onStartReading,
                              icon: const Icon(Icons.book, size: 18),
                              label: const Text('Start'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6D4C41),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          if (onContinueReading != null) ...[
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: onContinueReading,
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('Continue'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
