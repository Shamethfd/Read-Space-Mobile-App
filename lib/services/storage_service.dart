import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StorageService {
  late FirebaseStorage _storage;
  final ImagePicker _picker = ImagePicker();

  StorageService() {
    try {
      _storage = FirebaseStorage.instance;
      print('✅ Firebase Storage initialized');
    } catch (e) {
      print('❌ Error initializing Firebase Storage: $e');
      rethrow;
    }
  }

  // Upload image file
  Future<String?> uploadImage({
    required File file,
    required String path,
    required String fileName,
  }) async {
    try {
      print('📤 Starting upload: $path/$fileName');
      print('📁 File exists: ${file.existsSync()}');
      print('📁 File size: ${file.lengthSync()} bytes');

      final ref = _storage.ref().child('$path/$fileName');
      print('📦 Storage ref created: ${ref.fullPath}');

      final uploadTask = ref.putFile(file);
      print('⏳ Upload task started');

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('📊 Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      });

      final snapshot = await uploadTask;
      print('✅ Upload completed');

      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('🔗 Download URL: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('❌ Firebase Storage error: ${e.code} - ${e.message}');
      if (e.code == 'object-not-found') {
        throw Exception('Storage bucket not found. Please check Firebase Storage configuration.');
      } else if (e.code == 'unauthorized') {
        throw Exception('Not authorized to upload. Please check storage rules.');
      } else if (e.code == 'quota-exceeded') {
        throw Exception('Storage quota exceeded. Please check your Firebase plan.');
      }
      throw Exception('Firebase Storage error: ${e.message}');
    } catch (e) {
      print('❌ Upload error: $e');
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
