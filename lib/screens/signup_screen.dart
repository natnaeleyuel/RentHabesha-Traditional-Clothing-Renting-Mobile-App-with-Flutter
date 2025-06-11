import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/signup_bloc.dart';
import '../bloc/signup_event.dart';
import '../bloc/signup_state.dart';
import '../routes/app_router.dart';
import '/core/widgets/button.dart';
import '/core/widgets/text_field.dart';
import '/core/theme/colors.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
          } else if (state is SignupData && state.currentStep == 2) {
            context.go(AppRoute.completeProfile.path);
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 200,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    BlocBuilder<SignupBloc, SignupState>(
                      builder: (context, state) {
                        final name = state is SignupData ? state.name : '';
                        final email = state is SignupData ? state.email : '';
                        final password = state is SignupData ? state.password : '';
                        final error = state is SignupError ? state.message : null;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextField(
                              value: name,
                              onChanged: (value) => context.read<SignupBloc>().add(
                                UpdateSignupData(name: value),
                              ),
                              label: 'Full Name',
                              placeholder: 'Enter your full name',
                            ),
                            const SizedBox(height: 25),
                            CustomTextField(
                              value: email,
                              onChanged: (value) => context.read<SignupBloc>().add(
                                UpdateSignupData(email: value),
                              ),
                              label: 'Email',
                              placeholder: 'Enter your email',
                            ),
                            const SizedBox(height: 25),
                            CustomTextField(
                              value: password,
                              onChanged: (value) => context.read<SignupBloc>().add(
                                UpdateSignupData(password: value),
                              ),
                              label: 'Password',
                              placeholder: 'Enter your password',
                              isPassword: true,
                            ),
                            const SizedBox(height: 40),
                            CustomButton(
                              text: 'Sign Up',
                              onPressed: () {
                                context.read<SignupBloc>().add(SubmitStep1());
                              },
                            ),
                            if (error != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: isDarkMode ? Colors.white : AppColors.textStrong,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go(AppRoute.signin.path),
                                    child: Text(
                                      'Sign In',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppColors.brand,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.brand
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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