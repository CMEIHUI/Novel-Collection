import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class NovelFilePicker {
  static Future<Uint8List?> pickNovelFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    return result.files.first.bytes;
  }
}
