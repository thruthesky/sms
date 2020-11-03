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
    /// remove route only when:
    ///   1. the navigation event is moving to previous page.
    ///   2. `Get.removeRoute` is called, thus, `routing.removed` will not be empty.
    if (routing.isBack || routing.removed.isNotEmpty) {
      /// get the previous route name and remove it from stack.
      final routeName = getRouteName(routing, previous: true);
      navStack.remove(routeName);
      print('navStack.removed');
      print(routeName);
      print(navStack);
    } else {
      /// ignore if `routing.removed` is empty, since it is handled above.
      if (routing.removed.isNotEmpty) return;

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

      navStack[routeName] = routing.route;
      print('navStack.added');
      print(routeName);
      print(navStack);
    }
  }

  /// if `previous` is set to true, it will use the `previous` route name instead of `current`.
  static String getRouteName(
    Routing routing, {
    bool previous = false,
  }) {
    String routeName = previous ? routing.previous : routing.current;

    /// if the route name contains the forum route name, it adds the category to `routeName`.
    if (routeName.contains(RouteNames.forum)) {
      dynamic args = routing.args;
      routeName += args['category'];
    }
    return routeName;
  }
}
