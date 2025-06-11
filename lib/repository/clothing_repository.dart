import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/global_variabes/globals.dart';
import '../core/models/clothing_model.dart';

class AllClothingRepository {
  final String url = '${Globals.baseUrl}/api/clothing';

  Future<List<ClothingItem>> fetchClothing() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<ClothingItem> clothes = data.map((e) => ClothingItem.fromJson(e)).toList();

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('clothing_cache', json.encode(data));

        return clothes;
      } else {
        throw Exception("Failed to load clothing");
      }
    } catch (_) {
      return loadFromCache();
    }
  }

  Future<List<ClothingItem>> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('clothing_cache');

    if (cachedData != null) {
      List<dynamic> data = json.decode(cachedData);
      return data.map((e) => ClothingItem.fromJson(e)).toList();
    }
    return [];
  }
}
