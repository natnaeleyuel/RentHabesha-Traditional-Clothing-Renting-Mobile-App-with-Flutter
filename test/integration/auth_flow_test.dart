import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_habesha_flutter_app/bloc/signin_bloc.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_bloc.dart';
import 'package:rent_habesha_flutter_app/repository/auth_repository.dart';
import 'package:rent_habesha_flutter_app/screens/signin_screen.dart';
import 'package:rent_habesha_flutter_app/screens/signup_screen.dart';
import 'package:rent_habesha_flutter_app/screens/complete_profile_screen.dart';
import 'package:rent_habesha_flutter_app/screens/add_location_screen.dart';
import 'package:rent_habesha_flutter_app/core/widgets/text_field.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockGoRouter mockGoRouter;
  late SignupBloc signupBloc;
  late SignInBloc signInBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockGoRouter = MockGoRouter();
    signupBloc = SignupBloc(
      authRepository: mockAuthRepository,
      baseUrl: 'https://example.com',
    );
    signInBloc = SignInBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    signupBloc.close();
    signInBloc.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: '/signin',
            builder: (context, state) => const SignInScreen(),
          ),
          GoRoute(
            path: '/complete-profile',
            builder: (context, state) => const CompleteProfileScreen(),
          ),
          GoRoute(
            path: '/add-location',
            builder: (context, state) => const AddLocationScreen(),
          ),
        ],
      ),
      builder: (context, child) {
        if (child == null) {
          return const SizedBox();
        }
        return MultiBlocProvider(
          providers: [
            BlocProvider<SignupBloc>.value(value: signupBloc),
            BlocProvider<SignInBloc>.value(value: signInBloc),
          ],
          child: child,
        );
      },
    );
  }

  group('Authentication Flow Integration', () {
    testWidgets('complete signup flow and sign in',
        (WidgetTester tester) async {
      when(mockAuthRepository.login('john@example.com', 'password123')).thenAnswer((_) async => {
            'token': 'test_token',
            'user': {'id': '1', 'name': 'John Doe'},
          });

      // Start at signup screen
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Fill signup form
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Email'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      // Submit signup form
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify navigation to complete profile
      expect(find.text('Complete Profile'), findsOneWidget);

      // Fill complete profile form
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone Number'),
        '912345678',
      );
      await tester.tap(find.text('Gender'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();

      // Submit complete profile form
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Verify navigation to add location
      expect(find.text('Add Location'), findsOneWidget);

      // Fill location form
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Address'),
        '123 Main St, Addis Ababa',
      );
      await tester.pumpAndSettle();

      // Submit location form
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Verify navigation to sign in
      expect(find.text('Sign In'), findsOneWidget);

      // Fill sign in form
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Email'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      // Submit sign in form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify successful sign in
      verify(mockAuthRepository.login('john@example.com', 'password123'))
          .called(1);
    });

    testWidgets('handles signup validation errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('handles sign in validation errors',
        (WidgetTester tester) async {
      // Navigate to sign in screen
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('handles network errors during signup',
        (WidgetTester tester) async {
      // Mock network error
      when(mockAuthRepository.login('john@example.com', 'password123'))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Fill and submit signup form
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Email'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Password'),
        'password123',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify error handling
      expect(find.text('Network error'), findsOneWidget);
    });
  });
}
