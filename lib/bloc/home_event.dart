part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadClothingItems extends HomeEvent {
  final int page;
  final int limit;
  final String? type;
  final String? location;
  final String? search;

  const LoadClothingItems({
    this.page = 1,
    this.limit = 10,
    this.type,
    this.location,
    this.search,
  });

  @override
  List<Object?> get props => [page, limit, type, location, search];
}

class ChangeFilter extends HomeEvent {
  final String? type;
  final String? location;
  final String? search;

  const ChangeFilter({
    this.type,
    this.location,
    this.search,
  });

  @override
  List<Object?> get props => [type, location, search];
}

class LoadMoreClothingItems extends HomeEvent {
  const LoadMoreClothingItems();
}