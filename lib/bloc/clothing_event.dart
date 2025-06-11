part of 'clothing_bloc.dart';

@immutable
abstract class ClothingEvent extends Equatable {
  const ClothingEvent();
}

class AddClothingSubmitted extends ClothingEvent {
  final String title;
  final String description;
  final String rentalDuration;
  final String pricePerDay;
  final String type;
  final String careInstruction;
  final List<File> images;

  const AddClothingSubmitted({
    required this.title,
    required this.description,
    required this.rentalDuration,
    required this.pricePerDay,
    required this.type,
    required this.careInstruction,
    required this.images,
  });

  @override
  List<Object> get props => [
    title,
    description,
    rentalDuration,
    pricePerDay,
    type,
    careInstruction,
    images,
  ];
}

class EditClothingSubmitted extends ClothingEvent {
  final String clothingId;
  final String title;
  final String description;
  final String rentalDuration;
  final String pricePerDay;
  final String type;
  final String careInstruction;
  final List<File> newImages;
  final List<String> existingImageUrls;

  const EditClothingSubmitted({
    required this.clothingId,
    required this.title,
    required this.description,
    required this.rentalDuration,
    required this.pricePerDay,
    required this.type,
    required this.careInstruction,
    required this.newImages,
    required this.existingImageUrls,
  });

  @override
  List<Object> get props => [
    clothingId,
    title,
    description,
    rentalDuration,
    pricePerDay,
    type,
    careInstruction,
    newImages,
    existingImageUrls,
  ];
}

class DeleteClothing extends ClothingEvent {
  final String clothingId;
  const DeleteClothing(this.clothingId);

  @override
  List<Object> get props => [clothingId];
}

class LoadClothingForEdit extends ClothingEvent {
  final String clothingId;
  const LoadClothingForEdit(this.clothingId);

  @override
  List<Object> get props => [clothingId];
}