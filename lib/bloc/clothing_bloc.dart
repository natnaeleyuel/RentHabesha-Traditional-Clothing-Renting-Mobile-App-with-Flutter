import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:rent_habesha_flutter_app/core/models/clothing_model.dart';
import 'package:rent_habesha_flutter_app/repository/auth_repository.dart';
import '../repository/add_clothing_repository.dart';
import '../repository/clothing_repository.dart';

part 'clothing_event.dart';
part 'clothing_state.dart';

class ClothingBloc extends Bloc<ClothingEvent, ClothingState> {
  final ClothingRepository clothingRepository;
  final AllClothingRepository allClothingRepository;
  final AuthRepository authRepository;

  ClothingBloc({
    required this.clothingRepository,
    required this.allClothingRepository,
    required this.authRepository,
  }) : super(ClothingInitial()) {
    on<AddClothingSubmitted>(_onAddClothingSubmitted);
    on<EditClothingSubmitted>(_onEditClothingSubmitted);
    on<DeleteClothing>(_onDeleteClothing);
    on<LoadClothingForEdit>(_onLoadClothingForEdit);
  }

  Future<void> _onAddClothingSubmitted(
      AddClothingSubmitted event,
      Emitter<ClothingState> emit,
      ) async {
    emit(ClothingLoading());
    try {
      await clothingRepository.addClothing(
        title: event.title,
        description: event.description,
        rentalDuration: event.rentalDuration,
        pricePerDay: event.pricePerDay,
        type: event.type,
        careInstruction: event.careInstruction,
        images: event.images,
      );
      emit(AddClothingSuccess());
    } on SocketException {
      emit(ClothingFailure('No internet connection'));
    } on http.ClientException {
      emit(ClothingFailure('Server connection failed'));
    } catch (e) {
      emit(ClothingFailure(e.toString()));
    }
  }

  Future<void> _onEditClothingSubmitted(
      EditClothingSubmitted event,
      Emitter<ClothingState> emit,
      ) async {
    emit(ClothingLoading());
    try {
      await clothingRepository.editClothing(
        clothingId: event.clothingId,
        title: event.title,
        description: event.description,
        rentalDuration: event.rentalDuration,
        pricePerDay: event.pricePerDay,
        type: event.type,
        careInstruction: event.careInstruction,
        newImages: event.newImages,
        existingImageUrls: event.existingImageUrls,
      );
      emit(EditClothingSuccess());
    } on SocketException {
      emit(ClothingFailure('No internet connection'));
    } on http.ClientException {
      emit(ClothingFailure('Server connection failed'));
    } catch (e) {
      emit(ClothingFailure(e.toString()));
    }
  }

  Future<void> _onDeleteClothing(
      DeleteClothing event,
      Emitter<ClothingState> emit,
      ) async {
    emit(ClothingLoading());
    try {
      await clothingRepository.deleteClothing(event.clothingId);
      emit(ClothingDeleted());
    } catch (e) {
      emit(ClothingFailure(e.toString()));
    }
  }

  Future<void> _onLoadClothingForEdit(
      LoadClothingForEdit event,
      Emitter<ClothingState> emit,
      ) async {
    emit(ClothingLoading());
    try {
      debugPrint('Loading clothing for edit with ID: ${event.clothingId}');
      final clothing = await clothingRepository.getClothingById(event.clothingId);
      if (clothing == null) {
        debugPrint('Clothing not found for ID: ${event.clothingId}');
        emit(ClothingFailure('Clothing not found'));
      }else {
        debugPrint('Successfully loaded clothing for edit: ${clothing.title}');
        emit(ClothingLoadedForEdit(clothing));
      }
    } catch (e) {
      debugPrint('Detail error loading clothing: $e');
      emit(ClothingFailure('Failed to load clothing details: ${e.toString()}'));
    }
  }
}





