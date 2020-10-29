import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/definitions.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/translations.dart';
import 'package:v1/settings.dart' as App;
import 'package:v1/widgets/commons/photo-picker-bottom-sheet.dart';

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
    String msg = '';

    print('error(e): ');
    print(e);
    print('e.runtimeType: ${e.runtimeType}');

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
    print('error msg: $msg');
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

  static Future<File> pickImage({
    double maxWidth = 1024,
    int quality = 80,
  }) async {
    /// instantiate image picker.
    final picker = ImagePicker();

    /// choose upload option.
    ImageSource res = await Get.bottomSheet(
      PhotoPickerBottomSheet(),
      backgroundColor: Colors.white,
    );

    /// do nothing when user cancel option selection.
    if (res == null) return null;

    Permission permission =
        res == ImageSource.camera ? Permission.camera : Permission.photos;

    /// request permission status.
    ///
    /// Android:
    ///   - Camera permission is automatically granted, meaning it will not ask for permission.
    ///     unless we specify the following on the AndroidManifest.xml:
    ///       - <uses-permission android:name="android.permission.CAMERA" />
    PermissionStatus permissionStatus = await permission.status;
    print('permission status:');
    print(permissionStatus);

    /// if permission is permanently denied,
    /// the only way to grant permission is changing in AppSettings.
    if (permissionStatus.isPermanentlyDenied) {
      await openAppSettings();
    }

    /// alert the user if the permission is restricted.
    if (permissionStatus.isRestricted) {
      error(ERROR_PERMISSION_RESTRICTED);
      return null;
    }

    /// check if the app have the permission to access camera or photos
    if (permissionStatus.isUndetermined || permissionStatus.isDenied) {
      /// request permission if not granted, or user haven't chosen permission yet.
      print('requesting permisssion again');
      // does not request permission again. (BUG: iOS)
      // await permission.request();
    }

    PickedFile pickedFile = await picker.getImage(
      source: res,
      maxWidth: maxWidth,
      imageQuality: quality,
    );

    // return null if user picked nothing.
    if (pickedFile == null) return null;
    print('pickedFile.path: ${pickedFile.path} ');

    String localFile = await localFilePath(randomString() + '.jpeg');
    File file = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path, // source file
      localFile, // target file. Overwrite the source with compressed.
      quality: quality,
    );

    return file;
  }

  static bool isMine(dynamic data) {
    if (data == null || data['uid'] == null) return false;
    return data['uid'] == userController.uid;
  }
}
