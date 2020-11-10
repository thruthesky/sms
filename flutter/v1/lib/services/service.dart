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
  static final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');
  static String firebaseMessagingToken;

  ///
  static Geoflutterfire geo = Geoflutterfire();

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
      // reset `AppRouter.navStack`
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
  /// TODO: move to fireflutter package
  static Future<void> updateUserLocation({
    @required double latitude,
    @required double longitude,
    String fieldName = 'location',
  }) async {
    final GeoFirePoint point = geo.point(
      latitude: latitude,
      longitude: longitude,
    );

    // TODO: refactor to new conform with the new structure
    CollectionReference colRef =
        ff.db.collection('meta').doc('user').collection('public');

    return await colRef.doc(ff.user.uid).set(
      {fieldName: point.data},
      SetOptions(merge: true),
    );
  }

  /// returns list of locations near the given [latitude] and [longitude] within the [searchRadius].
  ///
  /// [searchRadius] is by kilometers, default value is set to `2`
  ///
  /// ```dart
  /// FireFlutter.findLocationsNearMe(
  ///   latitude: position.latitude,
  ///   longitude: position.longitude,
  ///   searchRadius: ...                // optional, default value is `2`.
  /// )
  /// ```
  /// 
  /// TODO: move to fireflutter package
  static Stream<List<DocumentSnapshot>> findLocationsNearMe({
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
    // TODO: refactor to new conform with the new structure
    CollectionReference colRef =
        ff.db.collection('meta').doc('user').collection('public');
    return geo.collection(collectionRef: colRef).within(
          center: point,
          radius: searchRadius,
          field: 'location',
          strictMode: true,
        );
  }
}
