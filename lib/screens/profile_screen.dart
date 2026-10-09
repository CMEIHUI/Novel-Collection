import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';
import '../database/app_repository.dart';
import '../models/novel.dart';
import '../utils/cover_image_service.dart';
import 'book_detail_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int totalBooks = 0;
  int favoriteBooks = 0;
  List<Novel> favorites = [];
  String? avatarPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final all = await AppRepository.instance.getNovels();
    final favs = all.where((n) => n.isFavorite).toList();
    if (!mounted) return;
    setState(() {
      totalBooks = all.length;
      favoriteBooks = favs.length;
      favorites = favs.take(6).toList();
      _loading = false;
    });
    await _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final user = AuthService.instance.currentUser;
    final key = 'avatar_${user?.username ?? 'guest'}';
    final path = prefs.getString(key);
    if (!mounted) return;
    setState(() {
      avatarPath = path;
    });
  }

  Future<void> _pickAvatar() async {
    final picked = await CoverImageService.pickCoverImage(context: context);
    if (picked == null) return;
    final prefs = await SharedPreferences.getInstance();
    final user = AuthService.instance.currentUser;
    final key = 'avatar_${user?.username ?? 'guest'}';
    await prefs.setString(key, picked);
    if (!mounted) return;
    setState(() {
      avatarPath = picked;
    });
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openBook(Novel novel) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            BookDetailScreen(novel: novel),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnim = Tween(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offsetAnim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF6D4C41),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: avatarPath != null && avatarPath!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CoverImageService.buildCoverPreview(
                            coverValue: avatarPath,
                            width: 80,
                            height: 80,
                            radius: const BorderRadius.all(Radius.circular(40)),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const CircleAvatar(
                          radius: 40,
                          child: Icon(Icons.person, size: 40),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? 'Guest',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user?.email ?? 'No email',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _statCard('Total', totalBooks.toString())),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard('Favorites', favoriteBooks.toString()),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Favorite Books',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (favorites.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No favorite books yet.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final n = favorites[index];
                    final tag = 'cover-${n.id ?? n.title}';
                    return GestureDetector(
                      onTap: () => _openBook(n),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: tag,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child:
                                  n.coverImage != null &&
                                      n.coverImage!.isNotEmpty
                                  ? CoverImageService.buildCoverPreview(
                                      coverValue: n.coverImage,
                                      width: 80,
                                      height: 110,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 110,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.menu_book),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 80,
                            child: Text(
                              n.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openSettings(),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
