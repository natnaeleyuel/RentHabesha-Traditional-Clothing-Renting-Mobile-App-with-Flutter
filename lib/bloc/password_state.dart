part of 'password_bloc.dart';

enum PasswordStatus { initial, loading, success, failure }

class PasswordState {
  final String currentPassword;
  final String? currentPasswordError;
  final String newPassword;
  final String? newPasswordError;
  final String confirmPassword;
  final PasswordStatus status;
  final String? confirmPasswordError;
  final String? errorMessage;

  bool get isValid =>
      currentPassword.isNotEmpty &&
          newPassword.length >= 6 &&
          confirmPassword == newPassword &&
          currentPasswordError == null &&
          newPasswordError == null &&
          confirmPasswordError == null;

  const PasswordState({
    required this.currentPassword,
    this.currentPasswordError,
    required this.newPassword,
    required this.status,
    this.newPasswordError,
    required this.confirmPassword,
    this.confirmPasswordError,
    this.errorMessage,
  });

  factory PasswordState.initial() => const PasswordState(
    currentPassword: '',
    newPassword: '',
    confirmPassword: '',
    status: PasswordStatus.initial,
  );

  PasswordState copyWith({
    String? currentPassword,
    String? currentPasswordError,
    String? newPassword,
    String? newPasswordError,
    String? confirmPassword,
    String? confirmPasswordError,
    PasswordStatus? status,
    String? errorMessage,
  }) {
    return PasswordState(
      currentPassword: currentPassword ?? this.currentPassword,
      currentPasswordError: currentPasswordError ?? this.currentPasswordError,
      newPassword: newPassword ?? this.newPassword,
      newPasswordError: newPasswordError ?? this.newPasswordError,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      confirmPasswordError: confirmPasswordError ?? this.confirmPasswordError,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}