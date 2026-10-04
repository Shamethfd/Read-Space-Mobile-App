import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload image file
  Future<String?> uploadImage({
    required File file,
    required String path,
    required String fileName,
  }) async {
    try {
      final ref = _storage.ref().child('$path/$fileName');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload image from camera
  Future<String?> uploadFromCamera({
    required String path,
    required String fileName,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo == null) return null;
      return await uploadImage(
        file: File(photo.path),
        path: path,
        fileName: fileName,
      );
    } catch (e) {
      throw Exception('Failed to capture and upload image: $e');
    }
  }

  // Upload image from gallery
  Future<String?> uploadFromGallery({
    required String path,
    required String fileName,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return null;
      return await uploadImage(
        file: File(image.path),
        path: path,
        fileName: fileName,
      );
    } catch (e) {
      throw Exception('Failed to pick and upload image: $e');
    }
  }

  // Delete file
  Future<void> deleteFile(String fullPath) async {
    try {
      await _storage.ref(fullPath).delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Get download URL
  Future<String?> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref(path);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }
}
