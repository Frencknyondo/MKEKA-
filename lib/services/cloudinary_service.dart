import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dymt3uley';
  static const String uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'assets',
  );

  static Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw CloudinaryUploadException(_parseErrorMessage(body));
    }

    final responseData = json.decode(body) as Map<String, dynamic>;
    return responseData['secure_url'] as String?;
  }

  static String _parseErrorMessage(String body) {
    try {
      final data = json.decode(body) as Map<String, dynamic>;
      final error = data['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ?? 'Cloudinary upload failed.';
    } catch (_) {
      return 'Cloudinary upload failed.';
    }
  }
}

class CloudinaryUploadException implements Exception {
  final String message;

  const CloudinaryUploadException(this.message);
}
