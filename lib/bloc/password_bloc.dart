import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/auth_repository.dart';

part 'password_event.dart';
part 'password_state.dart';

class PasswordBloc extends Bloc<PasswordEvent, PasswordState> {
  final AuthRepository authRepository;
  PasswordBloc({required this.authRepository}) : super(PasswordState.initial()) {
    on<CurrentPasswordChanged>(_onCurrentPasswordChanged);
    on<NewPasswordChanged>(_onNewPasswordChanged);
    on<ConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<PasswordSubmitted>(_onPasswordSubmitted);
  }

  void _onCurrentPasswordChanged(
      CurrentPasswordChanged event,
      Emitter<PasswordState> emit,
      ) {
    emit(state.copyWith(
      currentPassword: event.password,
      currentPasswordError: event.password.isEmpty ? 'Required' : null,
    ));
  }

  void _onNewPasswordChanged(
      NewPasswordChanged event,
      Emitter<PasswordState> emit,
      ) {
    final error = event.password.length < 6 ? 'Minimum 6 characters' : null;
    emit(state.copyWith(
      newPassword: event.password,
      newPasswordError: error,
    ));
  }

  void _onConfirmPasswordChanged(
      ConfirmPasswordChanged event,
      Emitter<PasswordState> emit,
      ) {
    final error = event.password != state.newPassword ? 'Passwords don\'t match' : null;
    emit(state.copyWith(
      confirmPassword: event.password,
      confirmPasswordError: error,
    ));
  }

  Future<void> _onPasswordSubmitted(
      PasswordSubmitted event,
      Emitter<PasswordState> emit,
      ) async {
    if (state.currentPassword.isEmpty) {
      emit(state.copyWith(currentPasswordError: 'Required'));
      return;
    }

    if (state.newPassword.isEmpty) {
      emit(state.copyWith(newPasswordError: 'Required'));
      return;
    }

    if (state.newPassword.length < 8) {
      emit(state.copyWith(newPasswordError: 'Minimum 8 characters'));
      return;
    }

    if (state.confirmPassword != state.newPassword) {
      emit(state.copyWith(confirmPasswordError: 'Passwords don\'t match'));
      return;
    }

    emit(state.copyWith(status: PasswordStatus.loading));

    try {
      final success = await authRepository.changePassword(
        state.currentPassword,
        state.newPassword,
      );

      if (success) {
        emit(state.copyWith(status: PasswordStatus.success));
      } else {
        emit(state.copyWith(
          status: PasswordStatus.failure,
          errorMessage: 'Password change failed',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PasswordStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}