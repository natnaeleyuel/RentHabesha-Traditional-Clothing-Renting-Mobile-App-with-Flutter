import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rent_habesha_flutter_app/repository/auth_repository.dart';
import '../core/widgets/bottom_navigationbar.dart';
import '../core/widgets/top_navigation.dart';
import '../routes/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isDeleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Settings',
        onBackPressed: () => context.go(AppRoute.profile.path),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsItem(
            context,
            icon: Icons.notifications,
            title: 'Notification Settings',
            onTap: () => {},
          ),
          _buildSettingsItem(
            context,
            icon: Icons.lock,
            title: 'Password Manager',
            onTap: () => context.go(AppRoute.passwordManager.path),
          ),
          const SizedBox(height: 20),
          _buildSettingsItem(
            context,
            icon: Icons.delete,
            title: 'Delete Account',
            color: Colors.red,
            onTap: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _buildSettingsItem(BuildContext context, {
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account. '
              'Please enter your password to confirm.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await _showPasswordDialog(context);
    }
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    final authRepo = context.read<AuthRepository>();
    final scaffold = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Password'),
        content: TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _performAccountDeletion(context, authRepo, scaffold);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountDeletion(
      BuildContext context,
      AuthRepository authRepo,
      ScaffoldMessengerState scaffold,
      ) async {
    setState(() => _isDeleting = true);

    try {
      scaffold.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Deleting account...'),
            ],
          ),
        ),
      );

      final success = await authRepo.deleteAccount(_passwordController.text);
      scaffold.hideCurrentSnackBar();

      if (success && context.mounted) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
        context.go(AppRoute.signin.path);
      } else if (context.mounted) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Failed to delete account')),
        );
      }
    } catch (e) {
      scaffold.hideCurrentSnackBar();
      scaffold.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isDeleting = false);
    }
  }
}