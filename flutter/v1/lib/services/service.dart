import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/push-notification.service.dart';
import 'package:v1/services/translations.dart';
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
    PushNotificationService().init();
  }

  static error(dynamic e) {
    print('e.runtimeType: ${e.runtimeType}');
    print("${e.message} (${e.code})");
    String msg = '';

    /// For firebase error object
    if (e.code != null && e.message != null) {
      if (e.code == 'weak-password') {
        msg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'The account already exists for that email.';
      } else if (e.code == 'permission-denied') {
        msg = 'Permission denied. You do not have permission.';
      } else {
        msg = "${e.message} (${e.code})";
      }
    } else {
      msg = 'Unknown error';
    }
    Get.snackbar('Error', msg);
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
}
