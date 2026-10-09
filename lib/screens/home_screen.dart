// cleaned unused imports
import 'package:flutter/material.dart';

import '../database/app_repository.dart';
import '../database/database_helper.dart';
import '../models/novel.dart';
import '../utils/cover_image_service.dart';
import '../utils/novel_filter.dart';
import '../utils/novel_stats.dart';
import '../widgets/search_bar.dart';
import 'add_novel_screen.dart';
import 'book_detail_screen.dart';
import 'novel_reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onThemeToggle,
    this.isDarkMode = false,
    this.initialTabIndex = 0,
  });

  final VoidCallback? onThemeToggle;
  final bool isDarkMode;
  final int initialTabIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Novel> novels = [];
  List<Novel> filteredNovels = [];
  int _selectedIndex = 0;

  final TextEditingController searchController = TextEditingController();
  String selectedGenre = 'All';
  String selectedAuthor = 'All';
  double minimumRating = 0;
  bool recentlyAdded = false;
  bool alphabetical = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    loadNovels();
  }

  Future<void> loadNovels() async {
    final data = await AppRepository.instance.getNovels();

    setState(() {
      novels = data;
      filteredNovels = data;
      selectedAuthor = 'All';
      selectedGenre = 'All';
      minimumRating = 0;
      recentlyAdded = false;
      alphabetical = true;
    });
  }

  void applyFilters() {
    setState(() {
      filteredNovels = applyNovelFilters(
        novels: novels,
        keyword: searchController.text,
        genre: selectedGenre,
        author: selectedAuthor,
        minimumRating: minimumRating,
        recentlyAdded: recentlyAdded,
        alphabetical: alphabetical,
      );
    });
  }

  List<Novel> buildRecommendations(List<Novel> novels) {
    if (novels.isEmpty) return [];

    final stats = calculateNovelDashboardStats(novels);
    final preferredGenre = stats.favoriteGenre;
    final genreMatches = novels
        .where((novel) => novel.genre == preferredGenre)
        .toList();

    final candidates = genreMatches.isNotEmpty ? genreMatches : novels.toList();
    candidates.sort((a, b) => b.rating.compareTo(a.rating));
    return candidates.take(3).toList();
  }

  List<String> getSearchSuggestions() {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return [];
    }

    final matches = <String>{};
    for (final novel in novels) {
      final title = novel.title.toLowerCase();
      final author = novel.author.toLowerCase();
      final genre = novel.genre.toLowerCase();

      if (title.contains(query)) {
        matches.add(novel.title);
      }
      if (author.contains(query)) {
        matches.add(novel.author);
      }
      if (genre.contains(query)) {
        matches.add(novel.genre);
      }
    }

    return matches.toList()..sort();
  }

  Future<void> openAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddNovelScreen()),
    );

    loadNovels();
  }

  Future<void> toggleFavorite(Novel novel) async {
    final updatedNovel = Novel(
      id: novel.id,
      title: novel.title,
      author: novel.author,
      genre: novel.genre,
      rating: novel.rating,
      review: novel.review,
      coverImage: novel.coverImage,
      isFavorite: !novel.isFavorite,
      totalPages: novel.totalPages,
      pagesRead: novel.pagesRead,
      lastOpenedChapter: novel.lastOpenedChapter,
    );

    await DatabaseHelper.instance.updateNovel(updatedNovel);
    await loadNovels();
  }

  Widget buildBanner() {
    return SizedBox(
      height: 180,
      child: PageView(
        children: [
          buildBannerCard(
            title: 'Discover your next story',
            subtitle:
                'Browse popular books, continue reading, and get top recommendations.',
            color: Colors.deepOrange.shade400,
          ),
          buildBannerCard(
            title: 'Expand your collection',
            subtitle: 'Add new novels to your library with ease.',
            color: Colors.indigo.shade400,
          ),
          buildBannerCard(
            title: 'Track your reading',
            subtitle: 'Stay on top of progress and never lose your place.',
            color: Colors.teal.shade400,
          ),
        ],
      ),
    );
  }

  Widget buildBannerCard({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(onPressed: () {}, child: const Text('See all')),
        ],
      ),
    );
  }

  Widget buildPopularBooks() {
    final popularBooks = filteredNovels.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return SizedBox(
      height: 520,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: .55,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: popularBooks.length.clamp(0, 5),
        itemBuilder: (context, index) {
          final novel = popularBooks[index];
          return SizedBox(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child:
                      novel.coverImage != null && novel.coverImage!.isNotEmpty
                      ? CoverImageService.buildCoverPreview(
                          coverValue: novel.coverImage,
                          width: 140,
                          height: 180,
                        )
                      : Container(
                          width: 140,
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.menu_book,
                            size: 40,
                            color: Colors.brown,
                          ),
                        ),
                ),

                const SizedBox(height: 8),

                Text(
                  novel.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  novel.author,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildContinueReading() {
    final continueReading = novels
        .where((novel) => novel.totalPages > novel.pagesRead)
        .toList();

    if (continueReading.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('No books in progress yet.'),
      );
    }

    return Column(
      children: continueReading.map((novel) {
        final progress = novel.totalPages > 0
            ? novel.pagesRead / novel.totalPages
            : 0.0;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                novel.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${novel.pagesRead}/${novel.totalPages} pages read',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NovelReaderScreen(novel: novel),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Reading'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D4C41),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildRecommendedBooks() {
    final recommendations = buildRecommendations(novels);
    if (recommendations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('No recommendations available yet.'),
      );
    }

    return Column(
      children: recommendations.map((novel) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novel.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      novel.author,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      novel.genre,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(novel.rating.toStringAsFixed(1)),
                backgroundColor: Colors.orange.shade100,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // compute values only when needed to avoid unused variable warnings

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Novel Collection",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline, color: Colors.black),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6D4C41),
        icon: const Icon(Icons.library_add),
        label: const Text("Add Novel"),
        onPressed: openAddScreen,
      ),

      body: _selectedIndex == 0
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SearchBarWidget(),
                  buildBanner(),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: const [
                        Chip(label: Text('Fantasy')),
                        SizedBox(width: 8),
                        Chip(label: Text('Romance')),
                        SizedBox(width: 8),
                        Chip(label: Text('Mystery')),
                        SizedBox(width: 8),
                        Chip(label: Text('Comedy')),
                        SizedBox(width: 8),
                        Chip(label: Text('Action')),
                      ],
                    ),
                  ),
                  buildSectionTitle('Popular'),
                  buildPopularBooks(),
                  buildSectionTitle('Continue Reading'),
                  buildContinueReading(),
                  buildSectionTitle('Recommended'),
                  buildRecommendedBooks(),
                  const SizedBox(height: 24),
                ],
              ),
            )
          : _selectedIndex == 1
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: .55,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filteredNovels.length,
                itemBuilder: (context, index) {
                  final novel = filteredNovels[index];
                  return buildLibraryItem(novel);
                },
              ),
            )
          : Center(
              child: _selectedIndex == 2
                  ? const Text('Favorites (select from nav)')
                  : const Text('Profile (select from nav)'),
            ),
    );
  }

  Widget buildLibraryItem(Novel novel) {
    final tag = 'cover-${novel.id ?? novel.title}';
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BookDetailScreen(novel: novel),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final offsetAnimation = Tween(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Hero(
                tag: tag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      novel.coverImage != null && novel.coverImage!.isNotEmpty
                      ? CoverImageService.buildCoverPreview(
                          coverValue: novel.coverImage,
                          width: double.infinity,
                          height: 160,
                        )
                      : Container(
                          height: 160,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.menu_book,
                              size: 36,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: IconButton(
                      key: ValueKey<bool>(novel.isFavorite),
                      icon: Icon(
                        novel.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: novel.isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () => toggleFavorite(novel),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            novel.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            novel.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
