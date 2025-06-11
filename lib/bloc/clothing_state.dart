part of 'clothing_bloc.dart';

abstract class ClothingState extends Equatable {
  const ClothingState();

  @override
  List<Object> get props => [];
}

class ClothingInitial extends ClothingState {}

class ClothingLoading extends ClothingState {}

class AddClothingSuccess extends ClothingState {}

class EditClothingSuccess extends ClothingState {}

class ClothingDeleted extends ClothingState {}

class ClothingFailure extends ClothingState {
  final String error;
  const ClothingFailure(this.error);

  @override
  List<Object> get props => [error];
}

class ClothingLoadedForEdit extends ClothingState {
  final ClothingItem clothing;
  const ClothingLoadedForEdit(this.clothing);

  @override
  List<Object> get props => [clothing];
}