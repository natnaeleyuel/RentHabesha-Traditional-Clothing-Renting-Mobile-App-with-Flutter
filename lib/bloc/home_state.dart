part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  final List<ClothingItem> clothingItems;
  const HomeState({this.clothingItems = const []});

  @override
  List<Object?> get props => [clothingItems];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<ClothingItem> clothingItems;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String? selectedType;
  final String? selectedLocation;
  final String? searchQuery;

  const HomeLoaded({
    required this.clothingItems,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.selectedType,
    this.selectedLocation,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
    clothingItems,
    currentPage,
    totalPages,
    totalItems,
    selectedType,
    selectedLocation,
    searchQuery,
  ];

  HomeLoaded copyWith({
    List<ClothingItem>? clothingItems,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? selectedType,
    String? selectedSize,
    String? selectedLocation,
    String? searchQuery,
  }) {
    return HomeLoaded(
      clothingItems: clothingItems ?? this.clothingItems,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      selectedType: selectedType ?? this.selectedType,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class Owner extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;

  const Owner({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone];
}