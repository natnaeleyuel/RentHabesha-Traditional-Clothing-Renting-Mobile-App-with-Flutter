import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_bloc.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_event.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_state.dart';
import 'package:rent_habesha_flutter_app/screens/complete_profile_screen.dart';
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
            builder: (context, state) => const CompleteProfileScreen(),
          ),
        ],
      ),
      builder: (context, child) => BlocProvider<SignupBloc>.value(
        value: mockSignupBloc,
        child: child!,
      ),
    );
  }

  group('CompleteProfileScreen', () {
    testWidgets('renders complete profile form', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Complete Profile'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('shows error message when fields are empty',
        (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());
      when(mockSignupBloc.state)
          .thenReturn(SignupError('Please fill all fields'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('updates form fields', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(CustomTextField, 'Phone Number'), '912345678');
      await tester.tap(find.text('Gender'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Male'));
      await tester.pumpAndSettle();

      verify(mockSignupBloc.add(UpdateSignupData(phone: '912345678')))
          .called(1);
      verify(mockSignupBloc.add(UpdateSignupData(gender: 'Male'))).called(1);
    });

    testWidgets('navigates to add location on successful step 2',
        (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(
        SignupData(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          phone: '912345678',
          gender: 'Male',
          currentStep: 3,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(mockGoRouter.go('/add-location')).called(1);
    });

    testWidgets('shows loading state', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(
        SignupLoading(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          phone: '912345678',
          gender: 'Male',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('submits form when continue button is pressed',
        (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(
        SignupData(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          phone: '912345678',
          gender: 'Male',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      verify(mockSignupBloc.add(SubmitStep2())).called(1);
    });

    testWidgets('shows gender dropdown options', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gender'));
      await tester.pumpAndSettle();

      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
    });
  });
}
