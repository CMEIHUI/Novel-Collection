import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/novel.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static const _kKey = 'novel_collection';
  static const _kUsersKey = 'novel_collection_users';

  DatabaseHelper._init();

  Future<List<Map<String, dynamic>>> _readList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _writeList(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(list));
  }

  Future<int> insertNovel(Novel novel) async {
    final list = await _readList();
    final ids = list.map((e) => (e['id'] as int?) ?? 0).toList();
    final nextId = (ids.isEmpty)
        ? 1
        : (ids.reduce((a, b) => a > b ? a : b) + 1);
    final map = novel.toMap();
    map['id'] = nextId;
    map['isFavorite'] = novel.isFavorite;
    map['content'] = novel.content;
    list.add(map);
    await _writeList(list);
    return nextId;
  }

  Future<List<Novel>> getNovels() async {
    final list = await _readList();
    final novels = list.map((m) => Novel.fromMap(m)).toList();
    novels.sort((a, b) => a.title.compareTo(b.title));
    return novels;
  }

  Future<int> updateNovel(Novel novel) async {
    final list = await _readList();
    final idx = list.indexWhere((e) => e['id'] == novel.id);
    if (idx == -1) return 0;
    list[idx] = novel.toMap();
    await _writeList(list);
    return 1;
  }

  Future<int> deleteNovel(int id) async {
    final list = await _readList();
    final before = list.length;
    list.removeWhere((e) => e['id'] == id);
    await _writeList(list);
    return before - list.length;
  }

  Future<List<Map<String, dynamic>>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsersKey);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> _writeUsers(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsersKey, jsonEncode(list));
  }

  Future<int> insertUser(AppUser user) async {
    final list = await _readUsers();
    final nextId =
        (list.isEmpty
            ? 0
            : list
                  .map((e) => e['id'] as int? ?? 0)
                  .reduce((a, b) => a > b ? a : b)) +
        1;
    final map = user.toMap();
    map['id'] = nextId;
    list.add(map);
    await _writeUsers(list);
    return nextId;
  }

  Future<List<AppUser>> getUsers() async {
    final list = await _readUsers();
    return list.map((m) => AppUser.fromMap(m)).toList();
  }

  Future<int> updateUser(AppUser user) async {
    final list = await _readUsers();
    final idx = list.indexWhere((e) => e['id'] == user.id);
    if (idx == -1) return 0;
    list[idx] = user.toMap();
    await _writeUsers(list);
    return 1;
  }

  Future<int> clearUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsersKey);
    return 1;
  }

  Future<String> exportDatabase() async {
    final list = await _readList();
    return jsonEncode(list);
  }

  Future<int> importDatabase(String payload) async {
    final decoded = jsonDecode(payload) as List<dynamic>;
    final list = decoded.cast<Map<String, dynamic>>();
    await _writeList(list);
    return list.length;
  }

  Future close() async {
    // nothing to close for shared_preferences
  }
}
