import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../bloc/home_bloc.dart';

class ClothingItem extends Equatable {
  final String id;
  final String title;
  final String price;
  final String imageUrl;
  final String? type;
  final String? location;
  final String? description;
  final String? careInstruction;
  final Owner owner;
  final String? rentalDuration;
  final List<String> images;

  const ClothingItem({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.careInstruction,
    this.rentalDuration,
    this.type,
    this.location,
    this.description,
    required this.owner,
    this.images = const [],
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    try {
      final ownerJson = json['owner'] as Map<String, dynamic>? ?? {};
      final owner = Owner.fromJson(ownerJson);

      final allImages = json['images'] as List? ?? [];
      final random = Random();
      final imageUrl = allImages.isNotEmpty
          ? allImages[random.nextInt(allImages.length)].toString()
          : '';

      return ClothingItem(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        price: json['pricePerDay']?.toString() ?? '0',
        imageUrl: 'http://192.168.137.1:5000$imageUrl',
        type: json['type'] as String? ?? '',
        location: json['location'] as String?,
        description: json['description'] as String?,
        careInstruction: json['careInstruction'] as String?,
        rentalDuration: json['rentalDuration'] as String?,
        images: List<String>.from(json['images'] ?? []),
        owner: owner,
      );
    } catch (e, stack) {
      debugPrint('Error parsing ClothingItem: $e');
      debugPrint('Stack trace: $stack');
      debugPrint('Problematic JSON: $json');
      rethrow;
    }
  }

  @override
  List<Object?> get props => [id];
}