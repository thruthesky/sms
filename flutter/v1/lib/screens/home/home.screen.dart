import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
// import 'package:v1/services/translations.dart';
// import 'package:v1/tests/forum.test.dart';

import 'package:v1/settings.dart' as App;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    // final ft = ForumTest();
    // ft.runOrderTest();
    // ft.runAncestorTest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'.tr),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: ff.authStateChanges,
            builder: (context, snapshot) {
              if (ff.user == null) {
                return Column(
                  children: [
                    RaisedButton(
                      onPressed: () => Get.toNamed(RouteNames.login),
                      child: Text('Login'),
                    ),
                    RaisedButton(
                      onPressed: () => Get.toNamed(RouteNames.register),
                      child: Text('Register'),
                    ),
                  ],
                );
              }

              /// when user logged in,
              return Column(
                children: [
                  Text("User Uid: ${ff.user.uid}"),
                  Text("User Uid: ${ff.user.email}"),
                  Text("User Nickname: ${ff.user.displayName}"),
                  Text("User Gender: ${ff.data?.gender}"),
                  Text("User PhotoUrl: ${ff.user.photoURL}"),
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.profile),
                    child: Text('Profile'),
                  ),
                  RaisedButton(
                    onPressed: ff.logout,
                    child: Text('Logout'),
                  ),
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.settings),
                    child: Text('Settings'),
                  ),
                ],
              );
            },
          ),
          RaisedButton(
            onPressed: () async {
              users
                  .doc(Service.userController.user.uid)
                  .collection('meta')
                  .doc('tokens')
                  .snapshots()
                  .listen((DocumentSnapshot document) {
                List<String> tokens = [];
                print(document.id);
                tokens.add(document.id);

                print(tokens);

                Service().sendNotification(
                  'test title message only',
                  'test body message, from test notification button.',
                  route: RouteNames.profile,
                  token: ff.firebaseMessagingToken,
                  tokens: tokens,
                  topic: ff.allTopic,
                );
              });
            },
            child: Text('Send Test Notification'),
          ),
          RaisedButton(
            onPressed: () => Get.toNamed(RouteNames.admin),
            child: Text('Admin Screen'),
          ),
          RaisedButton(
            onPressed: () =>
                Get.toNamed(RouteNames.forum, arguments: {'category': 'qna'}),
            child: Text('QnA'),
          ),
          RaisedButton(
            onPressed: () => Get.toNamed(RouteNames.forum,
                arguments: {'category': 'discussion'}),
            child: Text('Discussion'),
          ),
          RaisedButton(
            onPressed: () => Get.toNamed(RouteNames.forum,
                arguments: {'category': 'reminder'}),
            child: Text('Reminder'),
          ),
        ],
      ),
    );
  }
}
