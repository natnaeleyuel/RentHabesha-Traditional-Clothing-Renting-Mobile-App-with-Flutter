import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:rent_habesha_flutter_app/bloc/signin_bloc.dart';
import 'package:rent_habesha_flutter_app/bloc/signin_event.dart';
import 'package:rent_habesha_flutter_app/bloc/signin_state.dart';
import 'package:rent_habesha_flutter_app/repository/auth_repository.dart';
import 'package:rent_habesha_flutter_app/screens/signin_screen.dart';
import 'package:rent_habesha_flutter_app/core/widgets/text_field.dart';

class MockSignInBloc extends Mock implements SignInBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockSignInBloc mockSignInBloc;
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockSignInBloc = MockSignInBloc();
    mockGoRouter = MockGoRouter();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SignInScreen(),
          ),
        ],
      ),
      builder: (context, child) => BlocProvider<SignInBloc>.value(
        value: mockSignInBloc,
        child: child!,
      ),
    );
  }

  group('SignInScreen', () {
    testWidgets('renders sign in form', (WidgetTester tester) async {
      when(mockSignInBloc.state).thenReturn(SignInInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsNWidgets(2)); // Title and button
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('shows loading state when signing in',
        (WidgetTester tester) async {
      when(mockSignInBloc.state).thenReturn(
        SignInLoading(email: 'test@example.com', password: 'password123'),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNWidgets(2));
    });

    testWidgets('shows error message on failure', (WidgetTester tester) async {
      const errorMessage = 'Invalid credentials';
      when(mockSignInBloc.state).thenReturn(
        SignInFailure(
          email: 'test@example.com',
          password: 'wrong',
          error: errorMessage,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('navigates to home on successful sign in',
        (WidgetTester tester) async {
      when(mockSignInBloc.state).thenReturn(
        SignInSuccess(
          token: 'test_token',
          user: {'id': '1', 'name': 'Test User'},
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(mockGoRouter.go('/home')).called(1);
    });

    testWidgets('updates email and password fields',
        (WidgetTester tester) async {
      when(mockSignInBloc.state).thenReturn(SignInInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(CustomTextField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(CustomTextField, 'Password'), 'password123');

      verify(mockSignInBloc.add(SignInEmailChanged('test@example.com')))
          .called(1);
      verify(mockSignInBloc.add(SignInPasswordChanged('password123')))
          .called(1);
    });

    testWidgets('submits form when sign in button is pressed',
        (WidgetTester tester) async {
      when(mockSignInBloc.state).thenReturn(
        SignInData(email: 'test@example.com', password: 'password123'),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      verify(mockSignInBloc.add(SignInSubmitted())).called(1);
    });

    testWidgets('navigates to sign up screen', (WidgetTester tester) async {
      when(mockSignInBloc.state).thenReturn(SignInInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      verify(mockGoRouter.go('/signup')).called(1);
    });
  });
}
