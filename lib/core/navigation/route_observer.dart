import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_router.dart';

class RouteHistoryObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _saveRoute(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _saveRoute(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _saveRoute(newRoute?.settings.name);
  }

  Future<void> _saveRoute(String? route) async {
    if (route == null || route == AppRoute.splash.path) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_visited_route', route);
  }
}