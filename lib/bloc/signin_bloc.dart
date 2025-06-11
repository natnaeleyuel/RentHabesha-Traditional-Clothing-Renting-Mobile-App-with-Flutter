import 'package:flutter_bloc/flutter_bloc.dart';
import '/repository/auth_repository.dart';
import 'signin_event.dart';
import 'signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthRepository authRepository;

  SignInBloc({required this.authRepository}) : super(SignInInitial()) {
    on<SignInEmailChanged>(_onEmailChanged);
    on<SignInPasswordChanged>(_onPasswordChanged);
    on<SignInSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(SignInEmailChanged event, Emitter<SignInState> emit) {
    if (state is SignInData) {
      emit((state as SignInData).copyWith(email: event.email));
    } else {
      emit(SignInData(email: event.email, password: ''));
    }
  }

  void _onPasswordChanged(SignInPasswordChanged event, Emitter<SignInState> emit) {
    if (state is SignInData) {
      emit((state as SignInData).copyWith(password: event.password));
    } else {
      emit(SignInData(email: '', password: event.password));
    }
  }

  Future<void> _onSubmitted(SignInSubmitted event, Emitter<SignInState> emit) async {
    if (state is! SignInData) return;

    final data = state as SignInData;
    emit(SignInLoading(email: data.email, password: data.password));

    try {
      final authData = await authRepository.login(data.email, data.password);
      emit(SignInSuccess(
        token: authData['token'],
        user: authData['user'],
      ));
    } catch (e) {
      emit(SignInFailure(
        email: data.email,
        password: data.password,
        error: e.toString(),
      ));
    }
  }
}