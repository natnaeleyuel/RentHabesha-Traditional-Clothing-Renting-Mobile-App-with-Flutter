import 'package:http/http.dart' as http;
import 'package:rent_habesha_flutter_app/repository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<http.Response> authenticatedGet(String url) async {
  final authRepository = AuthRepository(
    httpClient: http.Client(),
    prefs: await SharedPreferences.getInstance(),
    baseUrl: 'http://localhost:5000',
  );

  final token = await authRepository.getToken();
  print('Using Token: $token'); // Debug print

  return http.get(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Proper format
    },
  );
}