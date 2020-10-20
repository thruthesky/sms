import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:v1/services/definitions.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/translations.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:v1/settings.dart' as App;

class Service {
  /// [locale] has the current locale.
  ///
  /// ``` dart
  /// I18n.locale;
  /// ```
  static String locale;

  /// Display translation text in the device language.
  ///
  /// If you want to keep the language that had set in `main.ts`,
  ///   then, you don't have to call this method.
  ///   Or, This method should be called on boot to change to language of translation on boot.
  static Future<String> initLocale() async {
    String current = await Devicelocale.currentLocale;
    locale = current.substring(0, 2);
    return locale;
  }

  static Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings =
        Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }

  static void error(dynamic e) {
    String msg = '';

    print('error(e): ' + 'home'.tr);
    print(e);
    print('e.runtimeType: ${e.runtimeType}');

    if (e is String) {
      msg = e.tr;
    } else if (e is PlatformException) {
      // Firebase errors

      print("Platform Exception: code: ${e.code} message: ${e.message}");
    }

    /// Errors
    /// It can be Firebase errors, or handmaid errors.
    else if (e.code != null && e.message != null) {
      print("${e.message} (${e.code})");

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
    } else {
      msg = 'Unknown error';
    }
    Get.snackbar('error'.tr, msg);
  }

  /// Change language to user device and download texts from firestore.
  ///
  /// [download] will be called after translation text has been downloaded. (works on offline)
  /// @see README for details
  static updateLocale({Function download}) async {
    /// Change language on boot
    if (App.Settings.changeUserLanguageOnBoot) {
      /// Get locale
      String locale = await initLocale();
      Get.updateLocale(Locale(locale));
    }

    /// Download texts from translation
    CollectionReference texts =
        FirebaseFirestore.instance.collection('settings/translations/texts');

    /// Update downloaded texts into `GetX locale translations`
    texts.snapshots().listen((QuerySnapshot snapshot) {
      if (snapshot.size == 0) return;
      snapshot.docs.forEach((DocumentSnapshot document) {
        updateTranslation(document.id, document.data());
      });

      /// Call `download` callback to re-render the whole app after downloading translations.
      if (download != null) {
        download();
      }
    });
  }

  /// Google sign-in
  ///
  ///
  static Future<void> signInWithGoogle() async {
    // Trigger the authentication flow

    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return error(ERROR_SIGNIN_ABORTED);

    try {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);
      Get.toNamed(RouteNames.home);
    } catch (e) {
      error(e);
    }
  }

  /// Facebook social login
  ///
  ///
  static Future<void> signInWithFacebook() async {
    // Trigger the sign-in flow
    LoginResult result;
    try {
      await FacebookAuth.instance
          .logOut(); // Need to logout to avoid 'User logged in as different Facebook user'
      result = await FacebookAuth.instance.login();
      if (result == null || result.accessToken == null) {
        return error(ERROR_SIGNIN_ABORTED);
      }
    } catch (e) {
      error(e);
    }

    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(result.accessToken.token);

    try {
      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

      Get.toNamed(RouteNames.home);
    } catch (e) {
      error(e);
    }
  }
}
