import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/app-router.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';

class Service {
  /// [locale] has the current locale.
  ///
  /// ``` dart
  /// I18n.locale;
  /// ```
  static String locale;
  static UserController userController = Get.find<UserController>();
  static final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  static final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');
  static String firebaseMessagingToken;

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
    if (data == null || data['uid'] == null) return false;
    return data['uid'] == userController.uid;
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

  static alertLoginFirst() {
    Get.defaultDialog(
      title: 'alert'.tr,
      middleText: "login first".tr,
      textConfirm: "ok".tr,
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  static alertUpdatePhoneNumber() {
    Get.defaultDialog(
      title: 'alert'.tr,
      middleText: "update phone number".tr,
      textConfirm: "ok".tr,
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(),
    );
  }

  static redirectAfterLoginOrRegister() {
    if (ff.appSetting('show-phone-verification-after-login') == true &&
        ff.user.phoneNumber.isNullOrBlank) {
      Get.toNamed(RouteNames.mobileAuth);
    } else {
      AppRouter.resetNavStack();
      Get.offAllNamed(RouteNames.home);
    }
  }

  static logout() {
    /// logout to firebase intance
    ff.logout();

    if (Get.currentRoute != RouteNames.home) {
      /// clear `AppRouter.navStack`.
      AppRouter.resetNavStack();

      /// clear all app screens until `home`,
      /// after moving to `home` screen, `AppRouter` will at it to it's `navStack`.
      Get.offAllNamed(RouteNames.home);
    }
  }
}
