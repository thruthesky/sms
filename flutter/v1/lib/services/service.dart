import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/definitions.dart';
import 'package:v1/services/functions.dart';
import 'package:v1/services/models.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/translations.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
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

  static Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseFirestore.instance.settings =
        Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
    initFirebaseMessaging();
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
      UserCredential user =
          await FirebaseAuth.instance.signInWithCredential(credential);

      onLogin(user);
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
      UserCredential user = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);

      onLogin(user);
      Get.toNamed(RouteNames.home);
    } catch (e) {
      error(e);
    }
  }

  static onLogin(UserCredential userCredential) {
    User user = userCredential.user;

    /// Update extra information information
    usersRef.doc(userCredential.user.uid).set({
      "notifyPost": true,
      "notifyComment": true,
    }, SetOptions(merge: true));

    updateToken(user);
  }

  /// @attention the app must call this method on app boot.
  /// This method is not called automatically.
  static Future<void> initFirebaseMessaging() async {
    await _firebaseMessagingRequestPermission();

    try {
      firebaseMessagingToken = await firebaseMessaging.getToken();
      if (userController.isLoggedIn) {
        updateToken(userController.user);
      }
    } catch (e) {
      print('Caught error on getting firebase token: ${e.message}');
    }

    /// subscribe to all topic
    await subscribeTopic(App.Settings.allTopic);

    _firebaseMessagingCallbackHandlers();
  }

  static Future subscribeTopic(String topicName) async {
    print('subscribeTopic $topicName');
    try {
      await firebaseMessaging.subscribeToTopic(topicName);
    } catch (e) {
      print(e);
    }
  }

  static Future unsubscribeTopic(String topicName) async {
    await firebaseMessaging.unsubscribeFromTopic(topicName);
  }

  /// Update push notification token to Firestore
  ///
  /// [user] is needed because when this method may be called immediately
  ///   after login but before `Firebase.AuthStateChange()` and when it happens,
  ///   the user appears not to be logged in even if the user already logged in.
  static updateToken(User user) {
    if (firebaseMessagingToken == null) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userController.user.uid)
        .collection('meta')
        .doc('tokens')
        .set({firebaseMessagingToken: true}, SetOptions(merge: true));
  }

  static Future<void> _firebaseMessagingRequestPermission() async {
    /// Ask permission to iOS user for Push Notification.
    if (Platform.isIOS) {
      firebaseMessaging.onIosSettingsRegistered.listen((event) {
        // Do something after user accepts the request.
      });
      await firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    } else {
      /// For Android, no permission request is required. just get Push token.
      await firebaseMessaging.requestNotificationPermissions();
    }
  }

  static _firebaseMessagingCallbackHandlers() {
    /// Configure callback handlers for
    /// - foreground
    /// - background
    /// - exited
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        _firebaseMessagingDisplayAndNavigate(message, true);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _firebaseMessagingDisplayAndNavigate(message, false);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        _firebaseMessagingDisplayAndNavigate(message, false);
      },
    );
  }

  /// Display notification & navigate
  ///
  /// @note the data on `onMessage` is like below;
  ///   {notification: {title: This is title., body: Notification test.}, data: {click_action: FLUTTER_NOTIFICATION_CLICK}}
  /// But the data on `onResume` and `onLaunch` are like below;
  ///   { data: {click_action: FLUTTER_NOTIFICATION_CLICK} }
  static void _firebaseMessagingDisplayAndNavigate(
      Map<String, dynamic> message, bool display) {
    var notification = message['notification'];

    /// iOS 에서는 title, body 가 `message['aps']['alert']` 에 들어온다.
    if (message['aps'] != null && message['aps']['alert'] != null) {
      notification = message['aps']['alert'];
    }
    // iOS 에서는 data 속성없이, 객체에 바로 저장된다.
    var data = message['data'] ?? message;

    // return if the senderID is the owner.
    if (data != null && data['senderID'] == userController.user.uid) {
      return;
    }

    if (display) {
      Get.snackbar(
        notification['title'].toString(),
        notification['body'].toString(),
        onTap: (_) {
          // print('onTap data: ');
          // print(data);
          Get.toNamed(data['route']);
        },
        mainButton: FlatButton(
          child: Text('Open'),
          onPressed: () {
            // print('mainButton data: ');
            // print(data);
            Get.toNamed(data['route']);
          },
        ),
      );
    } else {
      // TODO: Make it work.
      /// App will come here when the user open the app by tapping a push notification on the system tray.
      /// Do something based on the `data`.
      if (data != null && data['postId'] != null) {
        // Get.toNamed(Settings.postViewRoute, arguments: {'postId': data['postId']});
      }
    }
  }

  /// Pick photo ( or file ) from Camera or Photo Library
  ///
  ///

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

  Future<void> sendNotification(
    title,
    body, {
    route,
    token,
    tokens,
    topic,
  }) async {
    print('SendNotification');
    if (token == null && tokens == null && topic == null)
      return alert('Token/Topic is not provided.');

    final postUrl = 'https://fcm.googleapis.com/fcm/send';

    // String toParams = "/topics/" + App.Settings.allTopic;
    // print(token);
    // print(topic);

    final req = [];
    if (token != null) req.add({'key': 'to', 'value': token});
    if (topic != null) req.add({'key': 'to', 'value': "/topics/" + topic});
    if (tokens != null) req.add({'key': 'registration_ids', 'value': tokens});

    final headers = {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "key=" + App.Settings.firebaseServerToken
    };

    req.forEach((el) async {
      final data = {
        "notification": {"body": body, "title": title},
        "priority": "high",
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "sound": 'default',
          "senderID": userController.user.uid,
          'route': route,
        }
      };
      data[el['key']] = el['value'];
      final encodeData = jsonEncode(data);
      var dio = Dio();

      print('try sending notification');
      try {
        var response = await dio.post(
          postUrl,
          data: encodeData,
          options: Options(
            headers: headers,
          ),
        );
        if (response.statusCode == 200) {
          // on success do
          print("notification success");
        } else {
          // on failure do
          print("notification failure");
        }
        print(response.data);
      } catch (e) {
        print('Dio error in sendNotification');
        print(e);
      }
    });
  }

  static Future<String> uploadFile(
    String collection,
    File file, {
    void progress(double progress),
  }) async {
    final ref = FirebaseStorage.instance
        .ref(collection + filenameFromPath(file.path) + '.jpg');

    UploadTask task = ref.putFile(file);
    task.snapshotEvents.listen((TaskSnapshot snapshot) {
      double p = (snapshot.totalBytes / snapshot.bytesTransferred) * 100;
      progress(p);
    });

    await task;
    final url = await ref.getDownloadURL();
    print('DOWNLOAD URL : $url');
    return url;
  }

  static bool isMyPost(PostModel post) {
    return post.uid == userController.uid;
  }
}
