import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_bloc.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_event.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_state.dart';
import 'package:rent_habesha_flutter_app/screens/signup_screen.dart';
import 'package:rent_habesha_flutter_app/core/widgets/text_field.dart';

class MockSignupBloc extends Mock implements SignupBloc {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockSignupBloc mockSignupBloc;
  late MockGoRouter mockGoRouter;

  setUp(() {
    mockSignupBloc = MockSignupBloc();
    mockGoRouter = MockGoRouter();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SignupScreen(),
          ),
        ],
      ),
      builder: (context, child) => BlocProvider<SignupBloc>.value(
        value: mockSignupBloc,
        child: child!,
      ),
    );
  }

  group('SignupScreen', () {
    testWidgets('renders sign up form', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows error message when fields are empty',
        (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());
      when(mockSignupBloc.state)
          .thenReturn(SignupError('Please fill all fields'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('updates form fields', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(CustomTextField, 'Full Name'), 'John Doe');
      await tester.enterText(
          find.widgetWithText(CustomTextField, 'Email'), 'john@example.com');
      await tester.enterText(
          find.widgetWithText(CustomTextField, 'Password'), 'password123');

      verify(mockSignupBloc.add(UpdateSignupData(name: 'John Doe'))).called(1);
      verify(mockSignupBloc.add(UpdateSignupData(email: 'john@example.com')))
          .called(1);
      verify(mockSignupBloc.add(UpdateSignupData(password: 'password123')))
          .called(1);
    });

    testWidgets('navigates to complete profile on successful step 1',
        (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(
        SignupData(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          currentStep: 2,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(mockGoRouter.go('/complete-profile')).called(1);
    });

    testWidgets('navigates to sign in screen', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      verify(mockGoRouter.go('/signin')).called(1);
    });

    testWidgets('shows loading state', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(
        SignupLoading(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('submits form when sign up button is pressed',
        (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(
        SignupData(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      verify(mockSignupBloc.add(SubmitStep1())).called(1);
    });
  });
}
