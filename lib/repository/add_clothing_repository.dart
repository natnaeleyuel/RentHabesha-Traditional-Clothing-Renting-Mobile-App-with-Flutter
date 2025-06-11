import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../core/models/clothing_model.dart';
import '../repository/auth_repository.dart';
import 'package:http_parser/http_parser.dart';

class ClothingRepository {
  final String baseUrl;
  final http.Client client;
  final AuthRepository authRepository;

  ClothingRepository({
    required this.baseUrl,
    required this.client,
    required this.authRepository,
  });

  Future<void> addClothing({
    required String title,
    required String description,
    required String rentalDuration,
    required String pricePerDay,
    required String type,
    required String careInstruction,
    required List<File> images,
  }) async {
    for (var image in images) {
      final extension = image.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        debugPrint('The file type causing problem: $extension');
        throw Exception('Invalid image type: $extension. Only JPG, JPEG, PNG or WEBP allowed');
      }

      final size = await image.length();
      if (size > 5 * 1024 * 1024) {
        throw Exception('Image ${image.path} is too large (max 5MB)');
      }
    }

    final uri = Uri.parse('$baseUrl/api/clothing');
    final token = await authRepository.getToken();

    try {
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['rentalDuration'] = rentalDuration;
      request.fields['pricePerDay'] = pricePerDay;
      request.fields['type'] = type;
      request.fields['careInstruction'] = careInstruction;

      for (var image in images) {
        final extension = image.path.split('.').last.toLowerCase();
        // final mimeType = _getMimeType(extension);

        print('''
          Image details:
          Path: ${image.path}
          Extension: ${image.path.split('.').last}
          Size: ${(await image.length()) / 1024} KB
          ''');

        final bytes = await image.readAsBytes();
        print('First bytes: ${bytes.sublist(0, 4).join(', ')}');

        request.files.add(await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType('image', extension == 'jpg' ? 'jpeg' : extension),
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.$extension',
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 201) {
        debugPrint('Upload failed with status ${response.statusCode}');
        debugPrint('Response body: $responseBody');
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['message'] ?? 'Upload failed');
      }

      return jsonDecode(responseBody);
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      throw Exception('An unexpected error occurred');
    }
  }

  Future<ClothingItem> getClothingById(String id) async {
    debugPrint('Fetching clothing with ID: $id');
    try {
      final uri = Uri.parse('$baseUrl/api/clothing/$id');
      final token = await authRepository.getToken();

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        debugPrint('Received data: $jsonResponse');

        final data = jsonResponse['data'];
        return ClothingItem.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Clothing item not found');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        debugPrint('Error response body: ${response.body}');
        throw Exception('Failed to load clothing (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      debugPrint('Error in getClothingById: $e');
      rethrow;
    }
  }

  Future<void> deleteClothing(String clothingId) async {
    try {
      final token = await authRepository.getToken();
      final response = await client.delete(
        Uri.parse('$baseUrl/api/clothing/$clothingId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Delete response status: ${response.statusCode}');
      debugPrint('Delete response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete clothing: ${response.body}');
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      rethrow;
    }
  }

  Future<void> editClothing({
    required String clothingId,
    required String title,
    required String description,
    required String rentalDuration,
    required String pricePerDay,
    required String type,
    required String careInstruction,
    required List<File> newImages,
    required List<String> existingImageUrls,
  }) async {
    for (var image in newImages) {
      final extension = image.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
        debugPrint('The file type causing problem: $extension');
        throw Exception('Invalid image type: $extension. Only JPG, JPEG, PNG or WEBP allowed');
      }

      final size = await image.length();
      if (size > 5 * 1024 * 1024) {
        throw Exception('Image ${image.path} is too large (max 5MB)');
      }
    }

    final uri = Uri.parse('$baseUrl/api/clothing/$clothingId');
    final token = await authRepository.getToken();

    try {
      var request = http.MultipartRequest('PATCH', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['rentalDuration'] = rentalDuration;
      request.fields['pricePerDay'] = pricePerDay;
      request.fields['type'] = type;
      request.fields['careInstruction'] = careInstruction;
      request.fields['clothingId'] = clothingId;

      request.fields['existingImages'] = jsonEncode(existingImageUrls);

      for (var image in newImages) {
        final extension = image.path.split('.').last.toLowerCase();
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType('image', extension == 'jpg' ? 'jpeg' : extension),
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.$extension',
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        debugPrint('Update failed with status ${response.statusCode}');
        debugPrint(request.fields.toString());
        debugPrint(request.url.toString());
        debugPrint('Response body: $responseBody');
        final errorData = jsonDecode(responseBody);
        throw Exception(errorData['message'] ?? 'Update failed');
      }

      return jsonDecode(responseBody);
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Failed to connect to server');
    } catch (e) {
      debugPrint('Error in editClothing: $e');
      throw Exception('An unexpected error occurred');
    }
  }
}

String _getMimeType(String extension) {
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    default:
      return 'application/octet-stream';
  }
}


