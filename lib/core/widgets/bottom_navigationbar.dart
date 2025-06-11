import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/app_router.dart';
import '../theme/colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;

    if (currentRoute == AppRoute.home.path) {
      currentIndex = 0;
    } else if (currentRoute == AppRoute.orders.path) {
      currentIndex = 1;
    } else if (currentRoute == AppRoute.profile.path) {
      currentIndex = 2;
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.brand,
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.home, currentIndex == 0),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.shopping_bag, currentIndex == 1),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: _buildIcon(Icons.account_circle, currentIndex == 2),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(AppRoute.home.path);
            break;
          case 1:
            context.go(AppRoute.orders.path);
            break;
          case 2:
            context.go(AppRoute.profile.path);
            break;
        }
      },
    );
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.brand : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey,
        size: 24,
      ),
    );
  }
}