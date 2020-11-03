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
import 'package:v1/screens/mobile-auth/mobile-auth.screen.dart';
import 'package:v1/screens/mobile-auth/mobile-code-verification.screen.dart';
import 'package:v1/screens/profile/profile.screen.dart';
import 'package:v1/screens/register/register.screen.dart';
import 'package:v1/screens/search/search.screen.dart';
import 'package:v1/screens/settings/settings.screen.dart';
import 'package:v1/services/route-names.dart';

class AppRouter extends NavigatorObserver {
  /// this will hold the navigation history of the whole app.
  static Map<String, MaterialPageRoute> navStack = {};

  static Route<dynamic> generate(RouteSettings settings) {
    Route route;

    switch (settings.name) {
      case RouteNames.home:
        route = _buildRoute(settings, HomeScreen());
        break;
      case RouteNames.login:
        route = _buildRoute(settings, LoginScreen());
        break;
      case RouteNames.register:
        route = _buildRoute(settings, RegisterScreen());
        break;
      case RouteNames.mobileAuth:
        route = _buildRoute(settings, MobileAuthScreen());
        break;
      case RouteNames.mobileCodeVerification:
        route = _buildRoute(settings, MobileCodeVerificationScreen());
        break;
      case RouteNames.profile:
        route = _buildRoute(settings, ProfileScreen());
        break;
      case RouteNames.forum:
        route = _buildRoute(settings, ForumScreen());
        break;
      case RouteNames.forumEdit:
        route = _buildRoute(settings, ForumEditScreen());
        break;
      case RouteNames.forumView:
        route = _buildRoute(settings, ForumViewScreen());
        break;
      case RouteNames.search:
        route = _buildRoute(settings, SearchScreen());
        break;
      case RouteNames.settings:
        route = _buildRoute(settings, SettingsScreen());
        break;
      case RouteNames.admin:
        route = _buildRoute(settings, AdminScreen());
        break;
      case RouteNames.adminCategory:
        route = _buildRoute(settings, AdminCategoryScreen());
        break;
      case RouteNames.adminPushNotification:
        route = _buildRoute(settings, AdminPushNotificationScreen());
        break;
      default:
        route = MaterialPageRoute(
          builder: (c) => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(80.0),
                child: Column(
                  children: <Widget>[
                    Text('No route defined for ${settings.name}'),
                    Builder(
                      builder: (context) => RaisedButton(
                        child: Text('Go To Home'),
                        onPressed: () {
                          Get.toNamed(RouteNames.home);
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
        break;
    }

    /// get routeName
    var routeName = _getRouteName(settings);

    /// check if the routeName already exists on the `navStack`,
    if (navStack[routeName] != null) {
      /// if yes, remove it.
      Navigator.removeRoute(
        /// `Get.overlayContext` provide the current overlay context.
        Get.overlayContext,
        navStack[routeName],
      );
    }

    /// add current page on top of `navStack`.
    navStack[routeName] = route;

    return route;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    final routeName = _getRouteName(route.settings);

    /// remove the corresponding route in `navStack` everytime `didPop` happens.
    navStack.remove(routeName);
    print(navStack);
  }

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return new MaterialPageRoute(settings: settings, builder: (c) => builder);
  }

  static String _getRouteName(RouteSettings settings) {
    var routeName = settings.name;

    /// if the route is for forum, this includes the category as part of the `routeName`.
    if (routeName == RouteNames.forum) {
      Map<String, dynamic> args = settings.arguments;
      routeName += args['category'] ?? '';
    }
    return routeName;
  }

  static resetNavStack({
    String routeName,
  }) {
    navStack = {};
  }
}
