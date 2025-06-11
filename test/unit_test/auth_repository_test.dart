import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rent_habesha_flutter_app/repository/auth_repository.dart';

@GenerateMocks([http.Client, SharedPreferences])
import 'auth_repository_test.mocks.dart';

void main() {
  late MockClient mockHttpClient;
  late MockSharedPreferences mockPrefs;
  late AuthRepository authRepository;
  const baseUrl = 'https://example.com';

  setUp(() {
    mockHttpClient = MockClient();
    mockPrefs = MockSharedPreferences();
    authRepository = AuthRepository(
      httpClient: mockHttpClient,
      prefs: mockPrefs,
      baseUrl: baseUrl,
    );
  });

  group('AuthRepository', () {
    test('login success saves token and user', () async {
      const email = 'test@example.com';
      const password = 'password123';
      const token = 'test_token';
      final user = {'id': '1', 'name': 'Test User'};
      final responseMap = {'token': token, 'user': user};
      final response = http.Response(jsonEncode(responseMap), 200);

      when(mockHttpClient.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => response);
      when(mockPrefs.setString('auth_token', token))
          .thenAnswer((_) async => true);
      when(mockPrefs.setString('user_data', jsonEncode(user)))
          .thenAnswer((_) async => true);

      final result = await authRepository.login(email, password);
      expect(result['token'], token);
      expect(result['user'], user);
      verify(mockPrefs.setString('auth_token', token)).called(1);
      verify(mockPrefs.setString('user_data', jsonEncode(user))).called(1);
    });

    test('login failure throws exception', () async {
      const email = 'fail@example.com';
      const password = 'wrong';
      final response =
          http.Response(jsonEncode({'message': 'Login failed'}), 401);

      when(mockHttpClient.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => response);

      expect(
        () async => await authRepository.login(email, password),
        throwsA(isA<Exception>()),
      );
    });

    test('logout removes token and user data', () async {
      when(mockPrefs.getString('auth_token')).thenReturn('token');
      when(mockPrefs.remove('auth_token')).thenAnswer((_) async => true);
      when(mockPrefs.remove('user_data')).thenAnswer((_) async => true);
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/api/auth/logout'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{}', 200));

      final result = await authRepository.logout();
      expect(result, true);
      verify(mockPrefs.remove('auth_token')).called(1);
      verify(mockPrefs.remove('user_data')).called(1);
    });

    test('getCurrentUser returns user map', () async {
      final user = {'id': '1', 'name': 'Test User'};
      when(mockPrefs.getString('user_data')).thenReturn(jsonEncode(user));
      final result = await authRepository.getCurrentUser();
      expect(result, user);
    });

    test('getCurrentUserId returns user id', () async {
      final user = {'id': '1', 'name': 'Test User'};
      when(mockPrefs.getString('user_data')).thenReturn(jsonEncode(user));
      final result = await authRepository.getCurrentUserId();
      expect(result, '1');
    });

    test('getToken returns token', () async {
      when(mockPrefs.getString('auth_token')).thenReturn('token');
      final result = await authRepository.getToken();
      expect(result, 'token');
    });

    test('isLoggedIn returns true if token exists', () async {
      when(mockPrefs.containsKey('auth_token')).thenReturn(true);
      final result = await authRepository.isLoggedIn();
      expect(result, true);
    });
  });
}
