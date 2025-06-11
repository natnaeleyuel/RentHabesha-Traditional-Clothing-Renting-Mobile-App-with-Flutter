import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/colors.dart';
import '../core/widgets/bottom_navigationbar.dart';
import '../core/widgets/button.dart';
import '../core/widgets/top_navigation.dart';
import '../routes/app_router.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Privacy Policy',
        onBackPressed: () => context.go(AppRoute.profile.path),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RentHabesha Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.brand),
            ),
            const SizedBox(height: 24),
            const Text(
              'We Collect:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- Basic info (name, email, phone)'),
            const Text('- Payment details (processed securely)'),
            const Text('- Rental history & preferences'),
            const Text('- Device data for app improvement'),
            const SizedBox(height: 16),
            const Text(
              'We Use It To:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- Process rentals & deliveries'),
            const Text('- Improve our app'),
            const Text('- Send important updates'),
            const SizedBox(height: 16),
            const Text(
              'We Share Only When Needed:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- With trusted service providers'),
            const Text('- For legal compliance'),
            const SizedBox(height: 16),
            const Text(
              'Your Rights:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('- Access/delete your data'),
            const Text('- Opt out of marketing'),
            const SizedBox(height: 16),
            const Text(
              'Security:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('We protect your data with encryption'),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}