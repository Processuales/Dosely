import '../utils/web_stub.dart' if (dart.library.io) 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Captures an image from the camera.
  /// Returns the XFile caught by the picker, or null if cancelled.
  Future<XFile?> takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Optimize slightly
      );
      return photo;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  /// Saves the captured image to the application's document directory.
  /// Returns the absolute path of the saved file.
  Future<String?> saveImage(XFile image) async {
    if (kIsWeb) return null; // Web doesn't support file system saving this way

    try {
      final directory = await getApplicationDocumentsDirectory();
      final scansDir = Directory('${directory.path}/scans');
      if (!await scansDir.exists()) {
        await scansDir.create(recursive: true);
      }

      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(scansDir.path, fileName);

      await image.saveTo(savedPath);
      return savedPath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }
}
