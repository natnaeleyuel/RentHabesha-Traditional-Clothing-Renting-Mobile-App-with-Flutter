import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../repository/auth_repository.dart';
import 'signup_state.dart';
import 'signup_event.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final String baseUrl;
  SignupBloc({required this.authRepository, required this.baseUrl}) : super(SignupInitial()) {
    on<UpdateSignupData>(_onUpdateSignupData);
    on<SubmitStep1>(_onSubmitStep1);
    on<SubmitStep2>(_onSubmitStep2);
    on<SubmitStep3>(_onSubmitStep3);
  }

  final AuthRepository authRepository;

  void _onUpdateSignupData(UpdateSignupData event, Emitter<SignupState> emit) {
    if (state is SignupData) {
      final currentState = state as SignupData;
      emit(currentState.copyWith(
        name: event.name ?? currentState.name,
        email: event.email ?? currentState.email,
        password: event.password ?? currentState.password,
        phone: event.phone ?? currentState.phone,
        gender: event.gender ?? currentState.gender,
        address: event.address ?? currentState.address,
      ));
    } else {
      emit(SignupData(
        name: event.name ?? '',
        email: event.email ?? '',
        password: event.password ?? '',
        phone: event.phone ?? '',
        gender: event.gender ?? '',
        address: event.address ?? '',
      ));
    }
  }

  void _onSubmitStep1(SubmitStep1 event, Emitter<SignupState> emit) {
    if (state is SignupData) {
      final currentState = state as SignupData;
      if (currentState.name.isNotEmpty &&
          currentState.email.isNotEmpty &&
          currentState.password.isNotEmpty) {
        emit(currentState.copyWith(currentStep: 2));
      } else {
        emit(SignupError('Please fill all fields'));
        emit(currentState);
      }
    }
  }

  void _onSubmitStep2(SubmitStep2 event, Emitter<SignupState> emit) {
    if (state is SignupData) {
      final currentState = state as SignupData;
      if (currentState.phone.isNotEmpty && currentState.gender.isNotEmpty) {
        emit(currentState.copyWith(currentStep: 3));
      } else {
        emit(SignupError('Please fill all fields'));
        emit(currentState);
      }
    }
  }

  Future<void> _onSubmitStep3(SubmitStep3 event, Emitter<SignupState> emit) async {
    if (state is! SignupData) return;

    final currentState = state as SignupData;

    if (currentState.address.isEmpty) {
      emit(SignupError('Please enter your address'));
      return;
    }

    emit(SignupLoading(
      name: currentState.name,
      email: currentState.email,
      password: currentState.password,
      phone: currentState.phone,
      gender: currentState.gender,
    ));

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': currentState.name,
          'email': currentState.email,
          'password': currentState.password,
          'phone': '+251${currentState.phone}',
          'gender': currentState.gender,
          'address': currentState.address,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(SignupSuccess(jsonDecode(response.body)['data']));
      } else {
        emit(SignupError(
          jsonDecode(response.body)['message'] ?? 'Registration failed',
        ));
      }
    } catch (e) {
      emit(SignupError(
        'Connection error: ${e.toString()}',
      ));
    }
  }
}


