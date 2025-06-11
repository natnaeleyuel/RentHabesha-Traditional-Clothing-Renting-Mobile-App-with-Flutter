import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';
import '../core/theme/colors.dart';
import '../core/widgets/button.dart';
import '../routes/app_router.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final List<String> genders = ['Male', 'Female'];
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _genderFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is SignupData && state.currentStep == 3) {
            context.go(AppRoute.addLocation.path);
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 200,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Complete Profile',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: 40),
                    BlocBuilder<SignupBloc, SignupState>(
                      builder: (context, state) {
                        final phone = state is SignupData ? state.phone : '';
                        final gender = state is SignupData ? state.gender : '';
                        final error = state is SignupError ? state.message : null;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: const AssetImage('assets/images/profile_icon.png') as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _phoneFocusNode.requestFocus(),
                              child: Text(
                                'Phone Number',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: isDarkMode ? Colors.white : AppColors.textStrong,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              focusNode: _phoneFocusNode,
                              controller: TextEditingController(text: phone)
                                ..selection = TextSelection.collapsed(offset: phone.length),
                              onChanged: (value) => context.read<SignupBloc>().add(
                                UpdateSignupData(phone: value),
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('+251'),
                                      Icon(Icons.arrow_drop_down, size: 16),
                                      Text('|'),
                                    ],
                                  ),
                                ),
                                hintText: 'Enter phone number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(
                                    color: _phoneFocusNode.hasFocus
                                        ? AppColors.focusedTextFieldStroke(context)
                                        : AppColors.unfocusedTextFieldStroke(context),
                                  ),
                                ),
                                hintStyle: TextStyle(
                                  color: AppColors.unfocusedTextFieldText(context),
                                ),
                              ),
                              style: TextStyle(
                                color: _phoneFocusNode.hasFocus
                                    ? AppColors.focusedTextFieldText(context)
                                    : AppColors.unfocusedTextFieldText(context),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 24),

                            // Gender Dropdown
                            GestureDetector(
                              onTap: () => _genderFocusNode.requestFocus(),
                              child: Text(
                                'Gender',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: isDarkMode ? Colors.white : AppColors.textStrong,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<String>(
                              value: gender.isNotEmpty ? gender : null,
                              focusNode: _genderFocusNode,
                              items: genders.map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(
                                    gender,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SignupBloc>().add(
                                    UpdateSignupData(gender: value),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                hintText: 'Select',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                hintStyle: TextStyle(
                                  color: AppColors.unfocusedTextFieldText(context),
                                ),
                              ),
                              dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                              style: TextStyle(
                                color: _genderFocusNode.hasFocus
                                    ? AppColors.focusedTextFieldText(context)
                                    : AppColors.unfocusedTextFieldText(context),
                              ),
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // Complete Profile Button
                            CustomButton(
                              text: 'Complete Profile',
                              onPressed: () {
                                context.read<SignupBloc>().add(SubmitStep2());
                              },
                            ),

                            // Error Message
                            if (error != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}