import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/route_manager.dart';
import 'package:v1/services/route-names.dart';

class AppRouter {
  /// this will hold the navigation history of the whole app.
  static Map<String, Route> navStack = {};

  /// all route navigation events will invoke this method
  ///   - calling `Get.removeRoute` inside this method will invoke this method.
  ///
  /// NOTE: `routing.removed` will always have a `String` value.
  ///   - empty string if the navigation event is not removing a route.
  static observer(Routing routing) {
    print('Previous route : ${routing.previous}');
    print('Current route : ${routing.current}');

    /// if `routing.removed` is not empty, remove also from `navStack`.
    if (routing.removed.isNotEmpty) {
      print('Route is removed!! ${routing.removed}');
      navStack.remove(routing.removed);
      Get.routing.args = null;
      return;
    }

    /// if navigation event is going to previous page, we only remove previous route from `navStack`.
    if (routing.isBack) {
      /// get the previous route name and remove it from stack.
      final routeName = getRouteName(routing, previous: true);
      print('Previous route is removed!! $routeName');
      navStack.remove(routeName);
      Get.routing.args = null;
    } else {
      final routeName = getRouteName(routing);
      final Route navRoute = navStack[routeName];

      /// check if the current route is already on the `navStack`.
      if (navRoute != null) {
        navStack.remove(routeName);
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Get.removeRoute(navRoute);
          Get.routing.args = null;
        });
      }

      /// add route to `navStack`
      navStack[routeName] = routing.route;
      print('Route is added!! $routeName');
    }

    print('Nav Stack : $navStack');
  }

  /// if `previous` is set to true, it will use the `previous` route name instead of `current`.
  static String getRouteName(
    Routing routing, {
    bool previous = false,
  }) {
    String routeName = previous ? routing.previous : routing.current;

    /// if the route name contains the forum route name, it adds the category to `routeName`.
    if (routeName == RouteNames.forum) {
      dynamic args = routing.args;
      routeName += args['category'];
    }
    return routeName;
  }
}
