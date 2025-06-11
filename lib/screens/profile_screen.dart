import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../core/global_variabes/globals.dart';
import '../core/widgets/bottom_navigationbar.dart';
import '../repository/auth_repository.dart';
import '../core/widgets/top_navigation.dart';
import '../routes/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authRepo = context.read<AuthRepository>();
    final data = await authRepo.getCurrentUser();
    setState(() {
      userData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        onBackPressed: () => context.go(AppRoute.home.path),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(context),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    final userName = userData?['name'] ?? 'No Name';
    final userEmail = userData?['email'] ?? 'No Email';
    final imageUrl = userData?['profileImage'] ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: CircleAvatar(
            radius: 50,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage('${Globals.baseUrl}$imageUrl')
                : const AssetImage('assets/images/profile_icon.png') as ImageProvider,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            userName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            userEmail,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 40),
        _buildProfileItem(
          context,
          icon: Icons.history,
          title: 'Renting History',
          onTap: () => {} // context.go(AppRoute.rentingHistory.path),
        ),
        _buildProfileItem(
          context,
          icon: Icons.payment,
          title: 'Payment Methods',
          onTap: () => {} // context.go(AppRoute.paymentMethods.path),
        ),
        _buildProfileItem(
          context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: () => context.go(AppRoute.settings.path),
        ),
        _buildProfileItem(
          context,
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () => context.go(AppRoute.privacyPolicy.path),
        ),
        _buildProfileItem(
          context,
          icon: Icons.logout,
          title: 'Log Out',
          onTap: () async {
            if (_isLoggingOut) return;

            setState(() => _isLoggingOut = true);

            final scaffoldMessenger = ScaffoldMessenger.of(context);
            final authRepo = context.read<AuthRepository>();

            try {
              final success = await authRepo.logout();
              if (mounted) {
                setState(() => _isLoggingOut = false);
                if (success) {
                  context.go(AppRoute.signin.path);
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Logout failed, please try again')),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                setState(() => _isLoggingOut = false);
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            }
          },
          trailing: _isLoggingOut
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildProfileItem(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: trailing?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}