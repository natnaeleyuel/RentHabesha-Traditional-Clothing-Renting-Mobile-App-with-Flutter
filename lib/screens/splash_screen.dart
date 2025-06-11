import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/colors.dart';
import '../repository/auth_repository.dart';
import '../routes/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndRedirect();
  }

  Future<void> _checkAuthAndRedirect() async {
    await Future.delayed(const Duration(seconds: 2));

    final authRepo = context.read<AuthRepository>();
    final prefs = context.read<SharedPreferences>();

    final lastRoute = prefs.getString('last_visited_route') ?? AppRoute.landing.path;
    final isLoggedIn = await authRepo.isLoggedIn();

    if (!mounted) return;

    context.go(isLoggedIn ? lastRoute : AppRoute.landing.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.brand, width: 1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset('assets/images/img_seventeen.png'),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'RentHabesha.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}