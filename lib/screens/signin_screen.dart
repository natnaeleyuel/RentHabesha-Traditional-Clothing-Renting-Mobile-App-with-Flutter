import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../bloc/signin_bloc.dart';
import '../bloc/signin_event.dart';
import '../bloc/signin_state.dart';
import '../core/widgets/button.dart';
import '../core/widgets/text_field.dart';
import '../core/theme/colors.dart';
import '../routes/app_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess) {
          context.go(AppRoute.home.path);
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sign In',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              BlocBuilder<SignInBloc, SignInState>(
                builder: (context, state) {
                  final email = state is SignInData ? state.email : '';
                  final password = state is SignInData ? state.password : '';
                  final isLoading = state is SignInLoading;
                  final error = state is SignInFailure ? state.error : null;

                  return Column(
                    children: [
                      CustomTextField(
                        value: email,
                        onChanged: (value) => context.read<SignInBloc>().add(
                          SignInEmailChanged(value),
                        ),
                        label: 'Email',
                        placeholder: 'Enter your email',
                      ),
                      const SizedBox(height: 25),
                      CustomTextField(
                        value: password,
                        onChanged: (value) => context.read<SignInBloc>().add(
                          SignInPasswordChanged(value),
                        ),
                        label: 'Password',
                        placeholder: 'Enter your password',
                        isPassword: true,
                      ),
                      const SizedBox(height: 40),
                      CustomButton(
                        text: 'Sign In',
                        onPressed: isLoading
                            ? null
                            : () => context.read<SignInBloc>().add(SignInSubmitted()),
                        isLoading: isLoading,
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 25),
                      Align(
                        alignment: Alignment.topCenter,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDarkMode ? Colors.white : AppColors.textStrong,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go(AppRoute.signup.path),
                                child: Text(
                                  'Sign Up',
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
                      ),
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