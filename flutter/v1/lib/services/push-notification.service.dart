import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:v1/settings.dart' as App;

/// This class handles `Firebase Notification`
class PushNotificationService {
  final FirebaseMessaging _fcm = new FirebaseMessaging();

  final userController = Get.put(UserController());

  DocumentReference userInstance;

  /// @attention the app must call this method on app boot.
  /// This method is not called automatically.
  Future<void> init() async {
    print("Flutterbase Notification Init()");

    await _initRequestPermission();

    /// subscribe to all topic
    await subscribeTopic(App.Settings.allTopic);

    _initConfigureCallbackHandlers();

    initUpdateUserToken();
  }

  Future subscribeTopic(String topicName) async {
    await _fcm.subscribeToTopic(topicName);
  }

  Future unsubscribeTopic(String topicName) async {
    await _fcm.unsubscribeFromTopic(topicName);
  }

  /// Updates user token when app starts.
  initUpdateUserToken() {
    _fcm.getToken().then((tokenID) {
      print('token: $tokenID');
      saveToken(tokenID);
    }).catchError((err) {
      print(err);
      print(err.message.toString());
    });
  }

  saveToken(tokenID) {
    print('saveToken:: $tokenID');

    if (userController.isNotLoggedIn) return;
    FirebaseFirestore.instance
        .collection('users')
        .doc(userController.user.uid)
        .collection('tokens')
        .doc(tokenID)
        .set({'token': tokenID});
  }

  Future<void> _initRequestPermission() async {
    /// Ask permission to iOS user for Push Notification.
    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen((event) {
        // fb.setUserToken();
        // You can update the user's token here.
      });
      await _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      /// For Android, no permission request is required. just get Push token.
      await _fcm.requestNotificationPermissions();
    }
  }

  _initConfigureCallbackHandlers() {
    /// Configure callback handlers for
    /// - foreground
    /// - background
    /// - exited
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
        _displayAndNavigate(message, true);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
        _displayAndNavigate(message, false);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
        _displayAndNavigate(message, false);
      },
    );
  }

  /// Display notification & navigate
  ///
  /// Display & navigate
  ///
  /// 주의
  /// onMessage 콜백에서는 데이터가
  ///   {notification: {title: This is title., body: Notification test.}, data: {click_action: FLUTTER_NOTIFICATION_CLICK}}
  /// 와 같이 오는데,
  /// onResume & onLaunch 에서는 data 만 들어온다.
  void _displayAndNavigate(Map<String, dynamic> message, bool display) {
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

    // print('Get.route: ${Get.currentRoute}');
    // if (Get.currentRoute == RouteNames.chatting) return;

    // print('==> Got push data: $data');
    if (display) {
      // print('==> Display snackbar: notification: $notification')

      Get.snackbar(
        notification['title'].toString(),
        notification['body'].toString(),
        // onTap: () {
        //   print('data data: ');
        //   print(data);
        //   Get.toNamed(data['route']);
        // },
        mainButton: FlatButton(
          child: Text('Open'),
          onPressed: () {
            print('data data: ');
            print(data);
            Get.toNamed(data['route']);
          },
        ),
      );
    } else {
      /// App will come here when the user open the app by tapping a push notification on the system tray.
      /// Do something based on the `data`.
      if (data['postId'] != null) {
        // Get.toNamed(Settings.postViewRoute, arguments: {'postId': data['postId']});
      }
    }
  }

  showNotification(message) {
    Get.snackbar(message['title'].toString(), message['body'].toString());
  }

  // Future<void> sendNotification(title, body, route) async {
  //   // print('SendNotification');
  //   final postUrl = 'https://fcm.googleapis.com/fcm/send';

  //   String toParams = "/topics/" + chatroomTopic;

  //   final data = jsonEncode({
  //     "notification": {"body": body, "title": title},
  //     "priority": "high",
  //     "data": {
  //       "click_action": "FLUTTER_NOTIFICATION_CLICK",
  //       "id": "1",
  //       "status": "done",
  //       "sound": 'default',
  //       "senderID": _controller.user.uid,
  //       'route': route,
  //     },
  //     "to": "$toParams"
  //   });

  //   final headers = {
  //     HttpHeaders.contentTypeHeader: "application/json",
  //     HttpHeaders.authorizationHeader: "key=" + firebaseServerToken
  //   };

  //   var dio = Dio();

  //   // print('try sending notification');
  //   try {
  //     var response = await dio.post(
  //       postUrl,
  //       data: data,
  //       options: Options(
  //         headers: headers,
  //       ),
  //     );
  //     if (response.statusCode == 200) {
  //       // on success do
  //       print("notification success");
  //     } else {
  //       // on failure do
  //       print("notification failure");
  //     }
  //     print(response.data);
  //   } catch (e) {
  //     print('Dio error in sendNotification');
  //     print(e);
  //   }
  // }
}
