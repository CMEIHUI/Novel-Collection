import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CoverImageService {
  static const String defaultCoverValue =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQABAA4AF0j1XQAAAABJRU5ErkJggg==';

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickCoverImage({required BuildContext context}) async {
    final source = await _showSourceSheet(context);
    if (source == null) return null;

    final xFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1600,
    );

    if (xFile == null) return null;

    final file = File(xFile.path);
    final compressedBytes = await compressFile(file);
    final directory = await getApplicationDocumentsDirectory();
    final coversDir = Directory('${directory.path}/covers');
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }

    final targetFile = File(
      '${coversDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await targetFile.writeAsBytes(compressedBytes);
    return targetFile.path;
  }

  static Future<Uint8List> compressFile(File file) async {
    final bytes = await file.readAsBytes();
    return compressBytes(bytes);
  }

  static Future<Uint8List> compressBytes(Uint8List bytes) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return bytes;
    }

    final resized = img.copyResize(decoded, width: 900);
    final compressed = img.encodeJpg(resized, quality: 85);
    return Uint8List.fromList(compressed);
  }

  static Future<ImageSource?> _showSourceSheet(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Use default cover'),
                onTap: () => Navigator.pop(sheetContext, null),
              ),
            ],
          ),
        );
      },
    );

    return source;
  }

  static Widget buildCoverPreview({
    required String? coverValue,
    double width = 120,
    double height = 170,
    BorderRadiusGeometry radius = const BorderRadius.all(Radius.circular(18)),
    BoxFit fit = BoxFit.cover,
  }) {
    final resolvedValue = (coverValue == null || coverValue.isEmpty)
        ? defaultCoverValue
        : coverValue;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.brown.shade300,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: _buildImage(resolvedValue, fit),
      ),
    );
  }

  static Widget _buildImage(String coverValue, BoxFit fit) {
    final file = File(coverValue);
    if (file.existsSync()) {
      return Image.file(file, fit: fit);
    }

    try {
      final bytes = base64Decode(coverValue);
      return Image.memory(bytes, fit: fit);
    } catch (_) {
      return Image.memory(base64Decode(defaultCoverValue), fit: fit);
    }
  }
}
