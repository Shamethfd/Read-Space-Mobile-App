import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CloudinaryService {
  static const String _cloudName = 'wjfk7rkz';
  static const String _uploadPreset = 'readspace_upload';
  static const String _apiUrl = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Upload an image to Cloudinary using unsigned upload preset
  /// Returns the secure HTTPS URL of the uploaded image
  Future<String> uploadImage({
    required File imageFile,
    Function(double)? onProgress,
  }) async {
    try {
      // Validate file
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist');
      }

      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image size must be less than 10MB');
      }

      // Get MIME type
      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null || !mimeType.startsWith('image/')) {
        throw Exception('Invalid image file type');
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

      // Add fields
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = 'readspace';

      // Add file
      final file = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(file);

      // Send request
      print('📤 Uploading image to Cloudinary...');
      final response = await request.send();

      // Get response
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        print('❌ Cloudinary upload failed: ${response.statusCode}');
        print('Response: $responseBody');
        throw Exception('Upload failed with status ${response.statusCode}');
      }

      // Parse JSON response
      final jsonData = jsonDecode(responseBody);
      final secureUrl = jsonData['secure_url'] as String?;

      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('Failed to get image URL from Cloudinary response');
      }

      print('✅ Image uploaded successfully: $secureUrl');
      return secureUrl;
    } catch (e) {
      print('❌ Error uploading to Cloudinary: $e');
      rethrow;
    }
  }

  /// Delete an image from Cloudinary (requires API key/secret - not recommended for client-side)
  /// This is a placeholder - actual deletion should be done server-side
  Future<void> deleteImage(String publicId) async {
    throw Exception(
      'Image deletion requires server-side API key. '
      'Use Cloudinary admin API on your backend instead.',
    );
  }
}
