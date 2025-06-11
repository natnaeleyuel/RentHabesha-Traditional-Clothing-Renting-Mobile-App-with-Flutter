import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../core/models/clothing_model.dart';
import '../repository/auth_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final String baseUrl;
  final AuthRepository authRepository;
  static const int _defaultLimit = 10;


  HomeBloc({required this.baseUrl, required this.authRepository}) : super(HomeInitial()) {
    on<LoadClothingItems>(_onLoadClothingItems);
    on<ChangeFilter>(_onChangeFilter);
    on<LoadMoreClothingItems>(_onLoadMoreClothingItems);
  }

  Future<void> _onLoadClothingItems(
      LoadClothingItems event,
      Emitter<HomeState> emit,
      ) async {
    try {
      emit(HomeLoading());

      final response = await _fetchClothingItems(
        page: event.page,
        limit: event.limit,
        type: event.type,
        location: event.location,
        search: event.search,
      );

      if (response['success']) {
        final items = (response['data'] as List).map((itemJson) {
          try {
            return ClothingItem.fromJson(itemJson);
          } catch (e, stack) {
            debugPrint('Failed to parse item: $e\nItem: $itemJson\nStack: $stack');
            return ClothingItem(
              id: itemJson['_id']?.toString() ?? 'error_${DateTime.now().millisecondsSinceEpoch}',
              title: itemJson['title']?.toString() ?? 'Unknown Item',
              price: (itemJson['pricePerDay'] ?? itemJson['price'] ?? 0).toString(),
              imageUrl: (itemJson['images'] as List?)?.first?.toString() ?? '',
              owner: Owner(
                id: itemJson['owner']?['_id']?.toString() ?? '',
                name: itemJson['owner']?['name']?.toString() ?? 'Unknown Owner',
                email: itemJson['owner']?['email']?.toString() ?? '',
                phone: itemJson['owner']?['phone']?.toString() ?? '',
              ),
            );
          }
        }).toList();

        for (final item in items.take(3)) {
          debugPrint('Item sample: ${item.id} - ${item.title}');
          debugPrint('Image URL: ${item.imageUrl}');
        }

        emit(HomeLoaded(
          clothingItems: items,
          currentPage: response['page'],
          totalPages: response['pages'],
          totalItems: response['total'],
          selectedType: event.type,
          selectedLocation: event.location,
          searchQuery: event.search,
        ));
      } else {
        emit(HomeError(response['message'] ?? 'Failed to load items'));
      }
    } catch (e) {
      debugPrint('Error in _onLoadClothingItems: $e');
      emit(HomeError('Failed to process data'));
    }
  }

  Future<void> _onChangeFilter(
      ChangeFilter event,
      Emitter<HomeState> emit,
      ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      add(LoadClothingItems(
        type: event.type ?? currentState.selectedType,
        location: event.location ?? currentState.selectedLocation,
        search: event.search ?? currentState.searchQuery,
      ));
    }
  }

  Future<void> _onLoadMoreClothingItems(
      LoadMoreClothingItems event,
      Emitter<HomeState> emit,
      ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      if (currentState.currentPage >= currentState.totalPages) return;

      try {
        final response = await _fetchClothingItems(
          page: currentState.currentPage + 1,
          limit: _defaultLimit,
          type: currentState.selectedType,
          location: currentState.selectedLocation,
          search: currentState.searchQuery,
        );

        if (response['success']) {
          final newItems = (response['data'] as List)
              .map((json) => ClothingItem.fromJson(json))
              .toList();

          emit(currentState.copyWith(
            clothingItems: [...currentState.clothingItems, ...newItems],
            currentPage: response['page'],
            totalPages: response['pages'],
            totalItems: response['total'],
          ));
        }
      } catch (e) {
      }
    }
  }
  Future<Map<String, dynamic>> _fetchClothingItems({
    required int page,
    required int limit,
    String? type,
    String? location,
    String? search,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = await authRepository.getToken();

    final uri = Uri.parse('$baseUrl/api/clothing/').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (type != null) 'type': type,
        if (location != null) 'location': location,
        if (search != null) 'search': search,
      },
    );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed with status ${response.statusCode}');
      }
    } catch (e) {
      final cached = prefs.getString('cached_clothing_items');
      if (cached != null) {
        return jsonDecode(cached);
      }
      throw Exception('Network error and no cache available');
    }
  }
}



