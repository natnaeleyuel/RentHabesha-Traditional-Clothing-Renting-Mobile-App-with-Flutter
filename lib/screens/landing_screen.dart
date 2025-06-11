import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rent_habesha_flutter_app/core/theme/colors.dart';
import 'package:rent_habesha_flutter_app/core/widgets/button.dart';
import '../routes/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: screenHeight * 0.35,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columnHeight = 120 * 2 + 10;
                      final imageRatio = 1.5;
                      final imageWidth = columnHeight / imageRatio;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: columnHeight.toDouble(),
                            width: imageWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: const Color(0xFFB88D8D),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.asset(
                                'assets/images/img_six.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(59),
                                child: Image.asset(
                                  'assets/images/img_one.png',
                                  height: 120,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(59),
                                child: Image.asset(
                                  'assets/images/img_nineteen.png',
                                  height: 120,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome to Rent Habesha!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : AppColors.textStrong,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Discover. Rent. Celebrate.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDarkMode ? Colors.white : AppColors.textStrong,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Your go-to platform for renting stunning traditional Ethiopian clothing for any occasion.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButton(
                        text: 'Get Started',
                        onPressed: () =>  context.go(AppRoute.signup.path)
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDarkMode ? Colors.white : AppColors.textStrong,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.go(AppRoute.signin.path);
                            },
                            child: Text(
                              'Sign in',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF00A86B),
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.brand,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}