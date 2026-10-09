import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/novel.dart';
import '../utils/cover_image_service.dart';
import '../utils/novel_file_picker.dart';

class AddNovelScreen extends StatefulWidget {
  const AddNovelScreen({super.key});

  @override
  State<AddNovelScreen> createState() => _AddNovelScreenState();
}

class _AddNovelScreenState extends State<AddNovelScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final reviewController = TextEditingController();

  String? selectedCoverValue;

  String selectedGenre = "Fantasy";
  double rating = 4.0;
  bool isFavorite = false;
  int totalPages = 0;
  int pagesRead = 0;
  String? contentText;

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

  Future<void> saveNovel() async {
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

      final novel = Novel(
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        genre: selectedGenre,
        rating: rating,
        review: reviewController.text.trim(),
        coverImage: coverValue,
        content: contentText,
        isFavorite: isFavorite,
        totalPages: totalPages,
        pagesRead: pagesRead,
      );

      await DatabaseHelper.instance.insertNovel(novel);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Novel added successfully!")),
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
      padding: const EdgeInsets.only(bottom: 8, top: 16),
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
        title: const Text("Add Novel"),
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

              const SizedBox(height: 25),

              sectionTitle("Novel Title"),

              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Enter novel title",
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
                  hintText: "Enter author's name",
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
                items: genres
                    .map(
                      (genre) =>
                          DropdownMenuItem(value: genre, child: Text(genre)),
                    )
                    .toList(),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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

              sectionTitle("Favorite"),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Add to favorites'),
                value: isFavorite,
                onChanged: (value) => setState(() => isFavorite = value),
              ),

              sectionTitle("Upload Content"),

              ElevatedButton.icon(
                onPressed: () async {
                  final bytes = await NovelFilePicker.pickNovelFile();
                  if (bytes == null) return;

                  setState(() {
                    contentText = String.fromCharCodes(bytes);
                  });
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Novel Text'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D6E63),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              if (contentText != null && contentText!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Uploaded content available.',
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ],

              sectionTitle("Review"),

              TextFormField(
                controller: reviewController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Write your review...",
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
                  onPressed: saveNovel,
                  icon: const Icon(Icons.save),

                  label: const Text(
                    "Save Novel",
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
