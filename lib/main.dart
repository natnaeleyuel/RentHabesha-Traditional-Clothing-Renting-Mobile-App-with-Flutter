import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rent_habesha_flutter_app/bloc/password_bloc.dart';
import 'package:rent_habesha_flutter_app/provider/network_info_provider.dart';
import 'package:rent_habesha_flutter_app/repository/add_clothing_repository.dart';
import 'package:rent_habesha_flutter_app/repository/clothing_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'bloc/clothing_bloc.dart';
import 'bloc/home_bloc.dart';
import 'bloc/signin_bloc.dart';
import 'bloc/signup_bloc.dart';
import 'core/global_variabes/globals.dart';
import 'core/theme/theme.dart';
import 'routes/app_router.dart';
import 'repository/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();

  final authRepository = AuthRepository(
    httpClient: http.Client(),
    prefs: sharedPrefs,
    baseUrl: Globals.baseUrl,
  );

  final clothingRepository = ClothingRepository(
    client: http.Client(),
    baseUrl: Globals.baseUrl,
    authRepository: authRepository,
  );

  final allClothingRepository = AllClothingRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NetworkInfoProvider())
      ],
      child: MyApp(
        authRepository: authRepository,
        clothingRepository: clothingRepository,
        allClothingRepository: allClothingRepository,
        sharedPreferences: sharedPrefs,
      ))
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ClothingRepository clothingRepository;
  final AllClothingRepository allClothingRepository;
  final SharedPreferences sharedPreferences;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.clothingRepository,
    required this.allClothingRepository,
    required this.sharedPreferences,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: clothingRepository),
        RepositoryProvider.value(value: allClothingRepository),
        RepositoryProvider.value(value: sharedPreferences),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SignupBloc(
              authRepository: context.read<AuthRepository>(),
              baseUrl: Globals.baseUrl
            ),
          ),
          BlocProvider(
            create: (context) => SignInBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => HomeBloc(
              baseUrl: Globals.baseUrl,
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ClothingBloc(
              clothingRepository: context.read<ClothingRepository>(),
              authRepository: context.read<AuthRepository>(),
              allClothingRepository: context.read<AllClothingRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => PasswordBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          )
        ],
        child: MaterialApp.router(
          title: 'RentHabesha',
          theme: rentHabeshaTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}