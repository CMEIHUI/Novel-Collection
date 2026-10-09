// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

class FileSaver {
  static Future<String?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required List<String> allowedExtensions,
  }) async {
    final content = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(content);
    final anchor = html.document.createElement('a') as html.AnchorElement;
    anchor.href = url;
    anchor.download = fileName;
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return fileName;
  }
}
