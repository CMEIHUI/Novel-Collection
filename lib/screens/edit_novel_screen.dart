import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/novel.dart';
import '../utils/cover_image_service.dart';

class EditNovelScreen extends StatefulWidget {
  final Novel novel;

  const EditNovelScreen({super.key, required this.novel});

  @override
  State<EditNovelScreen> createState() => _EditNovelScreenState();
}

class _EditNovelScreenState extends State<EditNovelScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController reviewController;

  String? selectedCoverValue;

  late String selectedGenre;
  late double rating;
  late bool isFavorite;
  late int totalPages;
  late int pagesRead;
  String? lastOpenedChapter;

  final List<String> genres = [
    "Fantasy",
    "Mystery",
    "Romance",
    "Science Fiction",
    "Adventure",
    "Horror",
    "Thriller",
    "Historical",
  ];

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.novel.title);
    authorController = TextEditingController(text: widget.novel.author);
    reviewController = TextEditingController(text: widget.novel.review);

    selectedGenre = widget.novel.genre;
    rating = widget.novel.rating;
    isFavorite = widget.novel.isFavorite;
    totalPages = widget.novel.totalPages;
    pagesRead = widget.novel.pagesRead;
    lastOpenedChapter = widget.novel.lastOpenedChapter;

    selectedCoverValue = widget.novel.coverImage;

    if (widget.novel.coverImage == null || widget.novel.coverImage!.isEmpty) {
      selectedCoverValue = null;
    }
  }

  Future<void> pickImage() async {
    final result = await CoverImageService.pickCoverImage(context: context);
    if (result == null) {
      setState(() {
        selectedCoverValue = null;
      });
      return;
    }

    setState(() {
      selectedCoverValue = result;
    });
  }

  Future<void> updateNovel() async {
    if (_formKey.currentState!.validate()) {
      final coverValue = kIsWeb
          ? (selectedCoverValue != null && selectedCoverValue!.isNotEmpty
                ? selectedCoverValue
                : null)
          : selectedCoverValue;

      if (coverValue != null && coverValue.length > 180000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image is too large. Please choose a smaller file.'),
          ),
        );
        return;
      }

      final updatedNovel = Novel(
        id: widget.novel.id,
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        genre: selectedGenre,
        rating: rating,
        review: reviewController.text.trim(),
        coverImage: coverValue,
        isFavorite: isFavorite,
        totalPages: totalPages,
        pagesRead: pagesRead,
        lastOpenedChapter: lastOpenedChapter,
      );

      await DatabaseHelper.instance.updateNovel(updatedNovel);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Novel updated successfully!")),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    reviewController.dispose();
    super.dispose();
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),

      appBar: AppBar(
        title: const Text("Edit Novel"),
        centerTitle: true,
        backgroundColor: const Color(0xFF6D4C41),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Stack(
                  children: [
                    CoverImageService.buildCoverPreview(
                      coverValue: selectedCoverValue,
                      width: 120,
                      height: 170,
                    ),
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              sectionTitle("Novel Title"),

              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),

              sectionTitle("Author"),

              TextFormField(
                controller: authorController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Author is required';
                  }
                  return null;
                },
              ),

              sectionTitle("Genre"),

              DropdownButtonFormField<String>(
                initialValue: selectedGenre,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                items: genres.map((genre) {
                  return DropdownMenuItem(value: genre, child: Text(genre));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedGenre = value!;
                  });
                },
              ),

              sectionTitle("Rating"),

              Text(
                "${rating.toStringAsFixed(1)} / 5",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Slider(
                value: rating,
                min: 1,
                max: 5,
                divisions: 8,
                activeColor: Colors.brown,
                onChanged: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
              TextFormField(
                initialValue: rating.toStringAsFixed(1),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Rating (1-5)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null) {
                    return 'Rating is required';
                  }
                  if (parsed < 1 || parsed > 5) {
                    return 'Rating must be between 1 and 5';
                  }
                  return null;
                },
                onChanged: (value) {
                  final parsed = double.tryParse(value);
                  if (parsed != null) {
                    setState(() => rating = parsed.clamp(1.0, 5.0));
                  }
                },
              ),

              sectionTitle("Reading Progress"),

              TextFormField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: totalPages.toString()),
                decoration: const InputDecoration(
                  labelText: 'Total Pages',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() => totalPages = int.tryParse(value) ?? 0);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: pagesRead.toString()),
                decoration: const InputDecoration(
                  labelText: 'Pages Read',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() => pagesRead = int.tryParse(value) ?? 0);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: TextEditingController(
                  text: lastOpenedChapter ?? '',
                ),
                decoration: const InputDecoration(
                  labelText: 'Last Opened Chapter',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() => lastOpenedChapter = value),
              ),

              sectionTitle("Favorite"),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Favorite novel'),
                value: isFavorite,
                onChanged: (value) => setState(() => isFavorite = value),
              ),

              sectionTitle("Review"),

              TextFormField(
                controller: reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Review is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton.icon(
                  onPressed: updateNovel,
                  icon: const Icon(Icons.edit),

                  label: const Text(
                    "Update Novel",
                    style: TextStyle(fontSize: 18),
                  ),

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D4C41),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
