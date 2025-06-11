// signin_state.dart
abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInData extends SignInState {
  final String email;
  final String password;

  SignInData({required this.email, required this.password});

  SignInData copyWith({String? email, String? password}) {
    return SignInData(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class SignInLoading extends SignInData {
  SignInLoading({required super.email, required super.password});
}

class SignInSuccess extends SignInState {
  final String token;
  final Map<String, dynamic> user;
  SignInSuccess({required this.token, required this.user});
}

class SignInFailure extends SignInData {
  final String error;
  SignInFailure({
    required super.email,
    required super.password,
    required this.error,
  });
}