import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:rent_habesha_flutter_app/bloc/signin_bloc.dart';
import 'package:rent_habesha_flutter_app/repository/auth_repository.dart';
import 'package:rent_habesha_flutter_app/bloc/signin_event.dart';
import 'package:rent_habesha_flutter_app/bloc/signin_state.dart';

@GenerateMocks([AuthRepository])
import 'auth_bloc_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignInBloc signInBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signInBloc = SignInBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    signInBloc.close();
  });

  group('SignInBloc', () {
    test('initial state is SignInInitial', () {
      expect(signInBloc.state, isA<SignInInitial>());
    });

    test('emits SignInData when email is changed', () {
      const email = 'test@example.com';

      signInBloc.add(SignInEmailChanged(email));

      expect(signInBloc.state, isA<SignInData>());
      expect((signInBloc.state as SignInData).email, equals(email));
    });

    test('emits SignInData when password is changed', () {
      const password = 'password123';

      signInBloc.add(SignInPasswordChanged(password));

      expect(signInBloc.state, isA<SignInData>());
      expect((signInBloc.state as SignInData).password, equals(password));
    });

    test('emits SignInLoading and SignInSuccess when login is successful',
        () async {
      const email = 'test@example.com';
      const password = 'password123';
      const token = 'test_token';
      const user = {'id': '1', 'name': 'Test User'};

      when(mockAuthRepository.login(email, password))
          .thenAnswer((_) async => {'token': token, 'user': user});

      signInBloc.add(SignInEmailChanged(email));
      signInBloc.add(SignInPasswordChanged(password));
      signInBloc.add(SignInSubmitted());

      await expectLater(
        signInBloc.stream,
        emitsInOrder([
          isA<SignInData>(),
          isA<SignInLoading>(),
          isA<SignInSuccess>().having(
            (state) => state.token,
            'token',
            equals(token),
          ),
        ]),
      );

      verify(mockAuthRepository.login(email, password)).called(1);
    });

    test('emits SignInLoading and SignInFailure when login fails', () async {
      const email = 'test@example.com';
      const password = 'password123';
      const errorMessage = 'Invalid credentials';

      when(mockAuthRepository.login(email, password))
          .thenThrow(Exception(errorMessage));

      signInBloc.add(SignInEmailChanged(email));
      signInBloc.add(SignInPasswordChanged(password));
      signInBloc.add(SignInSubmitted());

      await expectLater(
        signInBloc.stream,
        emitsInOrder([
          isA<SignInData>(),
          isA<SignInLoading>(),
          isA<SignInFailure>().having(
            (state) => state.error,
            'error',
            contains(errorMessage),
          ),
        ]),
      );

      verify(mockAuthRepository.login(email, password)).called(1);
    });
  });
}
