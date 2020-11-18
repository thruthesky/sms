import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:v1/screens/admin/admin.category.screen.dart';
import 'package:v1/screens/admin/admin.push-notification.dart';
import 'package:v1/screens/admin/admin.screen.dart';
import 'package:v1/screens/forum/forum.edit.screen.dart';
import 'package:v1/screens/forum/forum.screen.dart';
import 'package:v1/screens/forum/forum.view.screen.dart';
import 'package:v1/screens/home/home.screen.dart';
import 'package:v1/screens/login/login.screen.dart';
import 'package:v1/screens/map/users_near_me.screen.dart';
import 'package:v1/screens/mobile-auth/mobile_auth.screen.dart';
import 'package:v1/screens/mobile-auth/mobile_code_verification.screen.dart';
import 'package:v1/screens/profile/profile.screen.dart';
import 'package:v1/screens/register/register.screen.dart';
import 'package:v1/screens/search/search.screen.dart';
import 'package:v1/screens/settings/settings.screen.dart';
import 'package:v1/screens/in-app-purchase/in-app-purchase.screen.dart';
import 'package:v1/services/route_names.dart';

class AppRouter extends NavigatorObserver {
  static Map<String, GetPageRoute> navStack = {};

  /// `routeNames` with corresponding `Screen`/`Widget`
  static final Map<String, Widget> screens = {
    RouteNames.home: HomeScreen(),
    RouteNames.login: LoginScreen(),
    RouteNames.register: RegisterScreen(),
    RouteNames.profile: ProfileScreen(),
    RouteNames.mobileAuth: MobileAuthScreen(),
    RouteNames.mobileCodeVerification: MobileCodeVerificationScreen(),
    RouteNames.admin: AdminScreen(),
    RouteNames.adminCategory: AdminCategoryScreen(),
    RouteNames.adminPushNotification: AdminPushNotificationScreen(),
    RouteNames.settings: SettingsScreen(),
    RouteNames.search: SearchScreen(),
    RouteNames.forum: ForumScreen(),
    RouteNames.forumEdit: ForumEditScreen(),
    RouteNames.forumView: ForumViewScreen(),
    RouteNames.inAppPurchase: InAppPurchase(),
    RouteNames.usersNearMe: UsersNearMeScreen(),
  };

  static GetPageRoute generate(RouteSettings routeSettings) {
    // This will be different especially for `forum` route.
    final routeName = _getRouteName(routeSettings);

    // check if the route already exists on `navStack`.
    if (navStack[routeName] != null) {
      /// remove if it exists.
      navigator.removeRoute(navStack[routeName]);
    }

    // add to `navStack`
    navStack[routeName] = GetPageRoute(
      settings: routeSettings,
      routeName: routeSettings.name,
      page: () => screens[routeSettings.name],
    );

    return navStack[routeName];
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    final routeName = _getRouteName(route.settings);
    navStack.remove(routeName);
  }

  /// get route name.
  ///
  /// For `forum` route, we add the `category` from the arguments to make it unique.
  static String _getRouteName(RouteSettings settings) {
    var routeName = settings.name;
    if (routeName == RouteNames.forum) {
      Map<String, dynamic> args = settings.arguments;
      routeName += args['category'] ?? '';
    }
    return routeName;
  }
}
