import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class FileSaver {
  static Future<String?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required List<String> allowedExtensions,
  }) async {
    final result = await FilePicker.saveFile(
      dialogTitle: 'Save file',
      fileName: fileName,
    );

    if (result == null) return null;

    final file = File(result);
    await file.writeAsBytes(bytes);
    return result;
  }
}
