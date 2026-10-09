import '../models/novel.dart';
import 'database_helper.dart';

class AppRepository {
  static final AppRepository instance = AppRepository._();

  AppRepository._();

  Future<List<Novel>> getNovels() => DatabaseHelper.instance.getNovels();

  Future<int> saveNovel(Novel novel) async {
    if (novel.id == null) {
      return DatabaseHelper.instance.insertNovel(novel);
    }
    await DatabaseHelper.instance.updateNovel(novel);
    return novel.id!;
  }
}
