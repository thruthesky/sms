import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/route_manager.dart';
import 'package:v1/services/route_names.dart';

class AppRouter {
  /// this will hold the duplicate navigation history of the app.
  static Map<String, Route> navStack = {};

  /// all route navigation events will invoke this method
  ///
  ///
  /// Things to consider:
  ///   - `Bottomsheet`, `Dialog`, `Snackbar`, `Alerts` and any other `Overlays` can also trigger this method.
  ///
  ///   - `navStack` must also be reset whenever the app remove screens by batch (ex. by calling `Get.offAllNamed(routeName)`).
  ///
  ///   - `routing.removed` will only have a value when `Get.removeRoute` is called.
  ///   - even if `routing.isBack` returns `true`, `routing.removed` won't have a value.
  static observer(Routing routing) {
    /// if `current` and `previous` routes are the same, an overlay may have opened or closed.
    ///   - example of this is the [datePicker] used in register screen.
    if (routing.current == routing.previous &&
        routing.current != RouteNames.forum) {
      return;
    }

    /// ignore non-screen overlays.
    if (routing.isBottomSheet || routing.isDialog || routing.isSnackbar) return;

    final routeName = getRouteName(routing, isPrevious: routing.isBack);
    final Route navRoute = navStack[routeName];

    /// check if the route already exist on the `navStack`.
    if (navRoute != null) {
      navStack.remove(routeName);

      /// don't remove a route from navigation when:
      ///   1. going back, since it is already removed.
      ///   2. `routing.removed` holds a non-empty value, meaning that route is already removed.
      if (!routing.isBack && routing.removed.isEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Get.removeRoute(navRoute);
        });
      }
    }

    /// if going back, don't add route to `navStack`.
    if (routing.isBack) {
      routing.args = null;
      return;
    } else {
      /// add new route to `navStack`
      navStack[routeName] = routing.route;
    }
  }

  static String getRouteName(Routing routing, {bool isPrevious = false}) {
    String routeName = isPrevious ? routing.previous : routing.current;

    /// if the route is forum route name, it adds the [category] from the routing argumets to `routeName`.
    if (routeName == RouteNames.forum) {
      dynamic args = routing.args;
      if (args != null) routeName += args['category'];
    }
    return routeName;
  }

  static resetNavStack() {
    navStack = {};
  }
}
