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
  ///   - calling `Get.removeRoute` inside this method will invoke this method.
  ///   - `routing.removed` will always have an empty `String` value if the navigation event is not removing a route.
  ///   - `Bottomsheet`, `Dialog`, `Snackbar`, `Alerts` and any other `Overlays` can also trigger this method.
  /// 
  ///   - `navStack` must also be reset whenever the app remove screens by batch (ex. by calling `Get.offAllNamed(routeName)`).
  static observer(Routing routing) {

    /// same page navigation is prevented since [preventDuplicate] property of `Get` route management is set to `true`.
    /// it is only possible when navigating to `forum` screen because [preventDuplicate] is set to `false`.
    /// 
    /// @SEE `Service.dart:openScreen()` and `Service.dart:openForumScreen()` for reference.
    if (routing.current == routing.previous &&
        routing.current != RouteNames.forum) return;
    if (routing.isBottomSheet || routing.isDialog || routing.isSnackbar) return;

    /// if `routing.removed` is not empty, remove also from `navStack`.
    if (routing.removed.isNotEmpty) {
      /// get removed route name, remove it from `navStack`.
      final routeName = getRouteName(routing, removed: true);
      navStack.remove(routeName);
      Get.routing.args = null;
      return;
    }

    /// if navigation event is going back, remove previous route from `navStack`.
    if (routing.isBack) {
      /// get the previous route name and remove it from `navStack`.
      final routeName = getRouteName(routing, previous: true);
      print('Previous route is removed!! $routeName');
      navStack.remove(routeName);
      Get.routing.args = null;
    }

    /// if not going back, check `navStack` for duplicates.
    else {
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

  /// if `previous` is set to true, it will use the `previous` route.
  /// if `removed` is set to true, it will use the `removed` route.
  /// if bost `previous` and `removed` are in default value or `false`, it will use the `current` route.
  static String getRouteName(
    Routing routing, {
    bool previous = false,
    bool removed = false,
  }) {
    String routeName = routing.current;
    if (previous) routeName = routing.previous;
    if (removed) routeName = routing.removed;

    /// if the route is forum route name, it adds the [category] from the routing argumets to `routeName`.
    if (routeName == RouteNames.forum) {
      dynamic args = routing.args;
      if (args != null) routeName += args['category'];
    }

    return routeName;
  }

  static resetNavStack() {
    navStack = {};
    print('navStack reset: $navStack');
  }
}
