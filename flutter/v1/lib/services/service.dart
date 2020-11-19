import 'dart:async';

import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route_names.dart';

class Service {
  /// [locale] has the current locale.
  ///
  /// ``` dart
  /// I18n.locale;
  /// ```
  static String locale;
  static final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  static final Location location = new Location();
  static final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');
  static String firebaseMessagingToken;

  /// TODO: move to fireflutter
  static Geoflutterfire geo = Geoflutterfire();

  /// Realtime update of user's location.
  ///
  /// can be used in [StreamBuilder] widger or simply listened to.
  ///```dart
  /// // listening without StreamBuilder widget
  /// StreamSubscription subscription = Service.userLocation.listen((location) {
  ///   // ... do something.
  /// });
  ///
  /// // using StreamBuilder widget
  /// StreamBulder(
  ///   stream: Service.userLocation,
  ///   builder: (context, snapshopt) {
  ///     // ... do something.
  ///   }
  /// );
  ///```
  static Stream<LocationData> get userLocation =>
      location.onLocationChanged.asBroadcastStream();

  /// Display translation text in the device language.
  ///
  /// If you want to keep the language that had set in `main.ts`,
  ///   then, you don't have to call this method.
  ///   Or, This method should be called on boot to change to language of translation on boot.
  static Future<String> initLocale() async {
    String current = await Devicelocale.currentLocale;
    locale = current.substring(0, 2);
    // Get.updateLocale(Locale(locale));
    return locale;
  }

  static void alert(String msg) {
    Get.defaultDialog(
      title: "Alert".tr,
      middleText: msg,
      onConfirm: () {
        print('Ok...');
        Get.back();
      },
      barrierDismissible: false,
      textConfirm: "Ok".tr,
      confirmTextColor: Colors.white,
    );
  }

  static void error(dynamic e) {
    print('=> error(e): ');
    print(e);
    print('=> e.runtimeType: ${e.runtimeType}');

    String msg = '';

    if (e is String) {
      msg = e.tr;
    } else if (e is PlatformException) {
      // Firebase errors
      msg = e.message;
      print("Platform Exception: code: ${e.code} message: ${e.message}");
    } else if (e.runtimeType.toString() == '_AssertionError') {
      /// Assertion Error happens only on development.
      msg = e.toString();
    }
    // else if (e is PlatformException) {
    //   // Firebase errors

    //   print("Platform Exception: code: ${e.code} message: ${e.message}");
    // }

    /// Errors
    ///
    /// It can be Firebase errors, or handmaid errors.
    /// This may produce another error like 'something' has no instance getter 'code' and this is because
    /// it does not understand what [e] is.
    else {
      try {
        if (e.code != null && e.message != null) {
          print(
              "e has code & message. message: ${e.message}, code: (${e.code})");

          if (e.code == 'weak-password') {
            msg = 'The password provided is too weak.';
          } else if (e.code == 'email-already-in-use') {
            msg = 'The account already exists for that email.';
          } else if (e.code == 'permission-denied') {
            msg = 'Permission denied. You do not have permission.';
          } else {
            msg = "${e.message} (${e.code})";
          }

          /// If there is translated text, then use it. Or use the error message above.
          ///
          /// firebase_auth_account-exists-with-different-credential

          final translated = (e.code as String).replaceAll('/', '_').tr;
          if (translated != e.code) msg = translated;
        }
      } catch (err) {
        msg = e.toString();
      }
    }
    print('error msg: $msg');
    Get.snackbar('error'.tr, msg);
  }

  /// Change language to user device and download texts from firestore.
  ///
  /// [download] will be called after translation text has been downloaded. (works on offline)
  /// @see README for details
  // static updateLocale({Function download}) async {
  //   /// Change language on boot
  //   if (App.Settings.changeUserLanguageOnBoot) {
  //     /// Get locale
  //     String locale = await initLocale();
  //     Get.updateLocale(Locale(locale));
  //   }

  //   /// Download texts from translation
  //   CollectionReference texts =
  //       FirebaseFirestore.instance.collection('settings/translations/texts');

  //   /// Update downloaded texts into `GetX locale translations`
  //   texts.snapshots().listen((QuerySnapshot snapshot) {
  //     if (snapshot.size == 0) return;
  //     snapshot.docs.forEach((DocumentSnapshot document) {
  //       updateTranslation(document.id, document.data());
  //     });

  //     /// Call `download` callback to re-render the whole app after downloading translations.
  //     if (download != null) {
  //       download();
  //     }
  //   });
  // }

  static bool isMine(dynamic data) {
    if (ff.notLoggedIn) return false;
    if (data == null || data['uid'] == null) return false;
    return data['uid'] == ff.user.uid;
  }

  static bool phoneNumberRequired() {
    if (ff.appSetting('create-phone-verified-user-only') == '') return false;
    return ff.appSetting('create-phone-verified-user-only') == true &&
        ff.user.phoneNumber.isNullOrBlank;
  }

  static openForumEditScreen(String category) {
    if (ff.loggedIn) {
      if (phoneNumberRequired()) {
        alertUpdatePhoneNumber();
      } else {
        openScreen(
          RouteNames.forumEdit,
          arguments: {'category': category},
        );
      }
    } else {
      alertLoginFirst();
    }
  }

  static openForumScreen(String category) {
    /// prevent from going to new forum screen with same category
    dynamic args = Get.arguments;
    print(args);
    if (args != null) {
      if (args['category'] == category) return;
    }

    openScreen(
      RouteNames.forum,
      arguments: {'category': category},
      preventDuplicate: false,
    );
  }

  static openScreen(
    String routeName, {
    Map<String, dynamic> arguments,
    bool preventDuplicate = true,
  }) {
    Get.toNamed(
      routeName,
      arguments: arguments,
      preventDuplicates: preventDuplicate,
    );
  }

  /// Alerts user if they need to login first to make any further actions.
  ///
  static alertLoginFirst() {
    Get.defaultDialog(
      title: 'alert'.tr,
      middleText: "login first".tr,
      textConfirm: "ok".tr,
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  /// Alerts user if they need to update their phone number.
  ///
  static alertUpdatePhoneNumber() {
    Get.defaultDialog(
        title: 'alert'.tr,
        middleText: "update phone number".tr,
        textConfirm: "update".tr,
        textCancel: "cancel".tr,
        confirmTextColor: Colors.white,
        onConfirm: () => Get.toNamed(RouteNames.mobileAuth),
        onCancel: () => Get.back());
  }

  /// redirects the user after logging in or registering.
  ///
  /// If the app setting [show-phone-verification-after-login] is set to true,
  /// the user will be redirected to phone authentication screen,
  /// otherwise it will redirect to home screen.
  ///
  static redirectAfterLoginOrRegister() {
    if (ff.appSetting('show-phone-verification-after-login') == true &&
        ff.user.phoneNumber.isNullOrBlank) {
      Get.toNamed(RouteNames.mobileAuth);
    } else {
      Get.offAllNamed(RouteNames.home);
    }
  }

  /// Updates user location
  ///
  /// This will add a document under firebase storage [users-public] collection,
  /// with a document id the same as the value the current user's uid.
  ///
  /// [fieldName] is where the user's location data will be saved on the document.
  /// - it is optional, the default value is `location`
  ///
  /// ```dart
  /// FireFlutter.updateUserLocation(
  ///   latitude: _latitude,
  ///   longitude: _longitude,
  ///   fieldName: "this is optional, default value is 'location'"
  /// );
  /// ```
  ///
  /// TODO: move to fireflutter package.
  /// TODO: update user location only when it has changes.
  static Future<void> updateUserLocation({
    @required double latitude,
    @required double longitude,
    String fieldName = 'location',
  }) async {
    final GeoFirePoint point = geo.point(
      latitude: latitude,
      longitude: longitude,
    );

    return await ff.publicDoc.set(
      {fieldName: point.data},
      SetOptions(merge: true),
    );
  }

  /// returns list of locations near the given [latitude] and [longitude] within the [searchRadius].
  ///
  /// [searchRadius] is by kilometers, default value is set to `2`
  ///
  /// ```dart
  /// FireFlutter.findUsersNearMe(
  ///   latitude: _latitude,
  ///   longitude: _longitude,
  ///   searchRadius: ...                // optional, default value is `2`.
  /// )
  /// ```
  ///
  /// TODO: move to fireflutter package
  static Stream<List<DocumentSnapshot>> findUsersNearMe({
    @required double latitude,
    @required double longitude,
    double searchRadius = 2,
  }) {
    final GeoFirePoint point = geo.point(
      latitude: latitude,
      longitude: longitude,
    );

    // query for "nearby me"
    // [radius] is by kilometers
    return geo.collection(collectionRef: ff.publicCol).within(
          center: point,
          radius: searchRadius,
          field: 'location',
          strictMode: true,
        );
  }

  /// User's last known location.
  static LocationData lastKnownUserLocation;

  ///
  static bool hasLocationPermission;

  /// initialize location service use, and returns user location.
  ///
  /// [updateDisctance] is the distance limit whenever location change updates.
  /// [onInitialLocation] provides a
  ///
  /// todo Updating user location on firestore
  /// * When app starts update user location if user has logged in.
  /// * When user logs in.
  /// * When user moves to another location.
  /// todo interval should be adjustable and the default is 30 seconds.
  static initUserLocation({
    double updateDistance = 10,
    onInitialLocation(LocationData locationData),
  }) async {
    print('initUserLocation');

    bool locationServiceEnabled;
    PermissionStatus permissionStatus;

    // check if service is enabled
    locationServiceEnabled = await location.serviceEnabled();
    if (!locationServiceEnabled) {
      // request if not enabled
      locationServiceEnabled = await location.requestService();
      if (!locationServiceEnabled) {
        return;
      }
    }

    // check if have permission to use location service
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      // request if permission is not granted.
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return hasLocationPermission = false;
      }
    }
    hasLocationPermission = true;

    print('permission granted');

    // Changes settings to whenever the `onChangeLocation` should emit new locations.
    location.changeSettings(
      distanceFilter: updateDistance,
      accuracy: LocationAccuracy.high,
    );

    // get initial location.
    if (onInitialLocation != null) {
      // return last location if already set.
      if (lastKnownUserLocation != null) {
        onInitialLocation(lastKnownUserLocation);
      }
      // if not, get device's location.
      else {
        await location.getLocation().then((location) {
          lastKnownUserLocation = location;
          onInitialLocation(lastKnownUserLocation);
        }).catchError(error);
        // userLocation = location.onLocationChanged.asBroadcastStream();
      }
    }

    print('location on changed listen');
    // listen to user location changes
    location.onLocationChanged.listen((newLocation) {
      if (ff.notLoggedIn) return;

      // update last known location.
      lastKnownUserLocation = newLocation;
      // TODO: Update user location if logged in
      print('update user location on firestore');
      // updateUserLocation(
      //   latitude: newLocation.latitude,
      //   longitude: newLocation.longitude,
      // );
    }).onError(error);
  }
}
