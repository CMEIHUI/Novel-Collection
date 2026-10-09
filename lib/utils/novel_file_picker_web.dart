// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class NovelFilePicker {
  static Future<Uint8List?> pickNovelFile() async {
    final input = html.FileUploadInputElement();
    input.accept = '.txt';
    input.click();

    final completer = Completer<Uint8List?>();

    input.onChange.listen((_) {
      final files = input.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }

      final reader = html.FileReader();
      reader.onLoad.listen((_) {
        final result = reader.result;
        if (result is String) {
          completer.complete(Uint8List.fromList(result.codeUnits));
        } else if (result is Uint8List) {
          completer.complete(result);
        } else {
          completer.complete(null);
        }
      });
      reader.readAsArrayBuffer(files.first);
    });

    return completer.future;
  }
}
