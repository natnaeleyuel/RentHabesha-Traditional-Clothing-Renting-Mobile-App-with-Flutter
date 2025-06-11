import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';
import '../core/theme/colors.dart';
import '../core/widgets/button.dart';
import '../core/widgets/text_field.dart';

class AddLocationScreen extends StatelessWidget {
  const AddLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is SignupSuccess) {
            context.go('/signin');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
          child: Column(
            children: [
              Icon(
                Icons.location_on,
                size: 40,
                color: AppColors.brand,
              ),
              const SizedBox(height: 25),
              Text(
                'Your Location',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'Add your location to find nearby rentals',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              BlocBuilder<SignupBloc, SignupState>(
                builder: (context, state) {
                  final address = state is SignupData ? state.address : '';
                  final isLoading = state is SignupLoading;
                  final error = state is SignupError ? state.message : null;

                  return Column(
                    children: [
                      CustomTextField(
                        value: address,
                        onChanged: (value) => context.read<SignupBloc>().add(
                          UpdateSignupData(address: value),
                        ),
                        label: 'Your Location',
                        placeholder: 'Enter your location',
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: CustomButton(
                          text: 'Add Location',
                          onPressed: isLoading
                              ? null
                              : () => context.read<SignupBloc>().add(SubmitStep3()),
                          isLoading: isLoading,
                        ),
                      ),
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
      ),
    );
  }
}