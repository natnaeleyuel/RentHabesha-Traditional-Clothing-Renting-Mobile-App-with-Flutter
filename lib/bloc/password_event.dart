part of 'password_bloc.dart';

abstract class PasswordEvent {}

class CurrentPasswordChanged extends PasswordEvent {
  final String password;
  CurrentPasswordChanged(this.password);
}

class NewPasswordChanged extends PasswordEvent {
  final String password;
  NewPasswordChanged(this.password);
}

class ConfirmPasswordChanged extends PasswordEvent {
  final String password;
  ConfirmPasswordChanged(this.password);
}

class PasswordSubmitted extends PasswordEvent {}