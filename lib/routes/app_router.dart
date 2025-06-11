import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/navigation/route_observer.dart';
import '/screens/add_card_screen.dart';
import '/screens/add_location_screen.dart';
import '/screens/add_clothing_screen.dart';
import '/screens/admin_dashboard_screen.dart';
import '/screens/complete_profile_screen.dart';
import '/screens/edit_clothing_screen.dart';
import '/screens/home_screen.dart';
import '/screens/landing_screen.dart';
import '/screens/orders_screen.dart';
import '/screens/notification_screen.dart';
import '/screens/password_manager_screen.dart';
import '/screens/payment_methods_screen.dart';
import '/screens/payment_status_screen.dart';
import '/screens/privacy_policy_screen.dart';
import '/screens/product_details_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/splash_screen.dart';
import '/screens/signup_screen.dart';
import '/screens/signin_screen.dart';
import '/screens/search_screen.dart';
import '/screens/settings_screen.dart';
import '/screens/shipping_address_screen.dart';
import '/screens/my_cart_screen.dart';

enum AppRoute {
  splash('/splash'),
  landing('/landing'),
  signup('/signup'),
  signin('/signin'),
  home('/home'),
  addCard('/add_card'),
  addLocation('/add_location'),
  addClothing('/add_clothing'),
  adminDashboard('/admin_dashboard'),
  checkout('/checkout'),
  clothingDetails('/clothing_details'),
  clothingManagement('/clothing_management'),
  completeProfile('/complete_profile'),
  editClothing('/edit_clothing'),
  orders('/orders'),
  notification('/notification'),
  passwordManager('/password_manager'),
  paymentMethods('/payment_methods'),
  paymentStatus('/payment_status'),
  privacyPolicy('/privacy_policy'),
  profile('/profile'),
  search('/search'),
  settings('/settings'),
  shippingAddress('/shipping_address'),
  userManagement('/users_management'),
  myCart('/my_cart');

  final String path;

  const AppRoute(this.path);
}

final routeObserver = RouteHistoryObserver();

final router = GoRouter(

  initialLocation: AppRoute.splash.path,
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: AppRoute.splash.path,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoute.landing.path,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoute.signup.path,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoute.signin.path,
      builder: (context, state) => const SignInScreen(),
    ),

    GoRoute(
      path: AppRoute.addLocation.path,
      builder: (context, state) => const AddLocationScreen(),
    ),
    GoRoute(
      path: AppRoute.completeProfile.path,
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: AppRoute.home.path,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoute.addClothing.path,
      builder: (context, state) => const AddClothingScreen(),
    ),
    /*
    GoRoute(
      path: AppRoute.addCard.path,
      builder: (context, state) => const AddCardScreen(),
    ),
    GoRoute(
      path: AppRoute.adminDashboard.path,
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: AppRoute.checkout.path,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoute.clothingManagement.path,
      builder: (context, state) => const ClothingManagementScreen(),
    ),
    */
    GoRoute(
      path: AppRoute.editClothing.path,
      redirect: (context, state) {
        final clothingId = state.extra as String?;
        if (clothingId == null || clothingId.isEmpty) {
          return AppRoute.home.path;
        }
        return null;
      },
      builder: (context, state) {
        final clothingId = state.extra as String;
        return EditClothingScreen(clothingId: clothingId);
        },
    ),
     /*
    GoRoute(
      path: AppRoute.orders.path,
      builder: (context, state) => const OrdersScreen(),
    ),
    GoRoute(
      path: AppRoute.notification.path,
      builder: (context, state) => const NotificationScreen(),
    ),
    */
    GoRoute(
      path: AppRoute.passwordManager.path,
      builder: (context, state) => const PasswordManagerScreen(),
    ),
    /*
    GoRoute(
      path: AppRoute.paymentMethods.path,
      builder: (context, state) => const PaymentMethodsScreen(),
    ),
    GoRoute(
      path: AppRoute.paymentStatus.path,
      builder: (context, state) => const PaymentStatusScreen(),
    ),
    */
    GoRoute(
      path: AppRoute.privacyPolicy.path,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoute.clothingDetails.path,
      redirect: (context, state) {
        final clothingId = state.extra as String?;
        if (clothingId == null || clothingId.isEmpty) {
          return AppRoute.home.path;
        }
        return null;
      },
      builder: (context, state) {
        final clothingId = state.extra as String;
        return ClothingDetailsScreen(clothingId: clothingId);
      },
    ),
    GoRoute(
      path: AppRoute.settings.path,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoute.profile.path,
      builder: (context, state) => const ProfileScreen(),
    ),
    /*
    GoRoute(
      path: AppRoute.search.path,
      builder: (context, state) => const SearchScreen(),
    ),

    GoRoute(
      path: AppRoute.shippingAddress.path,
      builder: (context, state) => const ShippingAddressScreen(),
    ),
    GoRoute(
      path: AppRoute.userManagement.path,
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: AppRoute.myCart.path,
      builder: (context, state) => const MyCartScreen(),
    ),
     */
  ],
);



