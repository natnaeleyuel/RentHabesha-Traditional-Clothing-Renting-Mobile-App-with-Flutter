import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rent_habesha_flutter_app/core/widgets/button.dart';
import 'package:rent_habesha_flutter_app/core/widgets/top_navigation.dart';
import 'package:rent_habesha_flutter_app/routes/app_router.dart';
import '../bloc/clothing_bloc.dart';
import '../core/theme/colors.dart';
import '../core/widgets/text_field.dart';

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({Key? key}) : super(key: key);

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _careInstructionController = TextEditingController();

  String? _selectedType;
  String? _selectedRentalPeriod;
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final validFiles = await Future.wait(
          pickedFiles.map((file) async {
            final imageFile = File(file.path);
            return await imageFile.exists() ? imageFile : null;
          }),
        );

        setState(() {
          _images.addAll(validFiles.whereType<File>());
        });
      }
    } catch (e) {
      _showError('Failed to pick images: ${e.toString()}');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      _showError('Please add at least one image');
      return;
    }

    if (_selectedType == null || _selectedRentalPeriod == null) {
      _showError('Please select all dropdown options');
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;
    if (price <= 0) {
      _showError('Price must be greater than zero');
      return;
    }

    setState(() => _isLoading = true);

    context.read<ClothingBloc>().add(
      AddClothingSubmitted(
        title: _nameController.text,
        description: _descriptionController.text,
        rentalDuration: _selectedRentalPeriod!,
        pricePerDay: price.toString(),
        type: _selectedType!,
        careInstruction: _careInstructionController.text,
        images: _images,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _careInstructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClothingBloc, ClothingState>(
      listener: (context, state) {
        if (state is AddClothingSuccess) {
          context.go(AppRoute.home.path);
        } else if (state is ClothingFailure) {
          setState(() => _isLoading = false);
          _showError(state.error);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Add Clothing', onBackPressed: () => context.go(AppRoute.home.path),),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImagePicker(),
                const SizedBox(height: 20),
                _buildNameField(),
                const SizedBox(height: 20),
                _buildCategoryAndRentalRow(),
                const SizedBox(height: 20),
                _buildDescriptionField(),
                const SizedBox(height: 20),
                _buildCareInstructionField(),
                const SizedBox(height: 20),
                _buildPriceField(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildSubmitButton(),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _images.isEmpty
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 40),
            SizedBox(height: 8),
            Text('Add Images'),
          ],
        )
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                Image.file(_images[index], fit: BoxFit.cover),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _removeImage(index),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
      child: BlocBuilder<ClothingBloc, ClothingState>(
        builder: (context, state) {
          return CustomButton(
            onPressed: state is ClothingLoading ? null : _submitForm,
            text: 'Add',
            isLoading: state is ClothingLoading,
          );
        },
      ),
    );
  }

  Widget _buildNameField() {
    return CustomTextField2(
      controller: _nameController,
      label: 'Clothing Name',
      placeholder: 'Enter clothing name',
      focusNode: FocusNode(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Name is required';
        }
        return null;
      },
      maxLines: 1,
      keyboardType: TextInputType.text,
      onChanged: (value) {},
    );
  }

  Widget _buildCategoryAndRentalRow() {
    return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppColors.bodyText(context),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 60,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedType,
                      hint: const Text('Category', style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.normal)),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(color: AppColors.brand),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                              color: AppColors.unfocusedTextFieldStroke(
                                  context)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.fromLTRB(
                            24, 18, 10, 18),
                      ),
                      items: ['Men', 'Women', 'Kids']
                          .map((type) =>
                          DropdownMenuItem(
                            value: type,
                            child: Text(type, style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.normal)),
                          ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedType = value),
                      validator: (value) =>
                      value == null
                          ? 'Please select a category'
                          : null,
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rental Period',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: AppColors.bodyText(context),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedRentalPeriod,
                    hint: const Text('Rental Period', style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.normal)),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: AppColors.brand),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(
                            color: AppColors.unfocusedTextFieldStroke(context)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.fromLTRB(24, 18, 10, 18),
                    ),
                    items: ['1 day', '3 days', '1 week', '2 weeks', '1 month']
                        .map((period) =>
                        DropdownMenuItem(
                          value: period,
                          child: Text(period, style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal)),
                        ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedRentalPeriod = value),
                    validator: (value) =>
                    value == null
                        ? 'Please select rental period'
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ]
    );
  }

  Widget _buildDescriptionField() {
    return CustomTextField2(
      controller: _descriptionController,
      label: 'About Clothing',
      placeholder: 'Enter description',
      focusNode: FocusNode(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Description is required';
        }
        return null;
      },
      maxLines: 3,
      keyboardType: TextInputType.text,
      onChanged: (String value) {},
    );
  }

  Widget _buildCareInstructionField() {
    return CustomTextField2(
      controller: _careInstructionController,
      label: 'Care Instruction',
      placeholder: 'Enter care instructions',
      focusNode: FocusNode(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Care instructions are required';
        }
        return null;
      },
      maxLines: 1,
      keyboardType: TextInputType.text,
      onChanged: (value) {},
    );
  }

  Widget _buildPriceField() {
    return CustomTextField2(
      controller: _priceController,
      label: 'Price Per Day',
      placeholder: 'Enter price per day',
      focusNode: FocusNode(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Price is required';
        }
        if (double.tryParse(value) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
      maxLines: 1,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: (value) {},
    );
  }
}
