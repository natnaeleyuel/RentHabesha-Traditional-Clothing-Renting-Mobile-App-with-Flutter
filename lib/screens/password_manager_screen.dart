import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/password_bloc.dart';
import '../core/widgets/bottom_navigationbar.dart';
import '../core/widgets/button.dart';
import '../core/widgets/top_navigation.dart';
import '../core/widgets/text_field.dart';
import '../repository/auth_repository.dart';
import '../routes/app_router.dart';

class PasswordManagerScreen extends StatelessWidget {
  const PasswordManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordBloc(authRepository: context.read<AuthRepository>()),
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Password Manager',
          onBackPressed: () => context.go(AppRoute.settings.path),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<PasswordBloc, PasswordState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    value: state.currentPassword,
                    onChanged: (value) => context.read<PasswordBloc>().add(
                      CurrentPasswordChanged(value),
                    ),
                    label: 'Current Password',
                    placeholder: 'Enter current password',
                    isPassword: true,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        //context.go(AppRoute.forgotPassword.path);
                      },
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, decorationColor: Colors.blue)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    value: state.newPassword,
                    onChanged: (value) => context.read<PasswordBloc>().add(
                      NewPasswordChanged(value),
                    ),
                    label: 'New Password',
                    placeholder: 'Enter new password',
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    value: state.confirmPassword,
                    onChanged: (value) => context.read<PasswordBloc>().add(
                      ConfirmPasswordChanged(value),
                    ),
                    label: 'Confirm New Password',
                    placeholder: 'Confirm new password',
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    onPressed: state.isValid
                        ? () {
                      context.read<PasswordBloc>().add(
                        PasswordSubmitted(),
                      );
                      if (state.status == PasswordStatus.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password changed successfully!')),
                        );
                        context.go(AppRoute.settings.path);
                      }
                      if (state.status == PasswordStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage ?? 'Password change failed')),
                        );
                      }
                    }
                        : null,
                    text: 'Change Password',
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: const CustomBottomNavigationBar(),
      ),
    );
  }
}