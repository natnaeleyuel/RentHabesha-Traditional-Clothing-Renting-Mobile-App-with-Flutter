import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_bloc.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_event.dart';
import 'package:rent_habesha_flutter_app/bloc/signup_state.dart';
import 'package:rent_habesha_flutter_app/screens/add_location_screen.dart';
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
            builder: (context, state) => const AddLocationScreen(),
          ),
        ],
      ),
      builder: (context, child) => BlocProvider<SignupBloc>.value(
        value: mockSignupBloc,
        child: child!,
      ),
    );
  }

  group('AddLocationScreen', () {
    testWidgets('renders add location form', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Add Location'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows error message when address is empty',
        (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());
      when(mockSignupBloc.state)
          .thenReturn(SignupError('Please enter your address'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your address'), findsOneWidget);
    });

    testWidgets('updates address field', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupInitial());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Address'),
        '123 Main St, Addis Ababa',
      );

      verify(mockSignupBloc
              .add(UpdateSignupData(address: '123 Main St, Addis Ababa')))
          .called(1);
    });

    testWidgets('navigates to sign in on successful registration',
        (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(
        SignupSuccess({
          'id': '1',
          'name': 'John Doe',
          'email': 'john@example.com',
        }),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(mockGoRouter.go('/signin')).called(1);
    });

    testWidgets('shows loading state', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(
        SignupLoading(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          phone: '912345678',
          gender: 'Male',
          address: '123 Main St',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('submits form when submit button is pressed',
        (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(
        SignupData(
          name: 'John Doe',
          email: 'john@example.com',
          password: 'password123',
          phone: '912345678',
          gender: 'Male',
          address: '123 Main St',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      verify(mockSignupBloc.add(SubmitStep3())).called(1);
    });

    testWidgets('shows snackbar on error', (WidgetTester tester) async {
      when(mockSignupBloc.state).thenReturn(SignupError('Registration failed'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Registration failed'), findsOneWidget);
    });
  });
}
