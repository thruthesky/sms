import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/translations.dart';

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
          Container(
            child: Text('menu'.tr),
          ),
          Text('submit'.tr),
          GetBuilder<UserController>(builder: (user) {
            return Column(
              children: [
                Text("User Uid: ${user.uid}"),
                Text("User Nickname: ${user.displayName}"),
                Text("User PhotoUrl: ${user.photoUrl}"),
                if (user.isNotLoggedIn) ...[
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.login),
                    child: Text('Login'),
                  ),
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.register),
                    child: Text('Register'),
                  ),
                ],
                if (user.isLoggedIn) ...[
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.profile),
                    child: Text('Profile'),
                  ),
                  RaisedButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: Text('Logout'),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      users
                          .doc(Service.userController.user.uid)
                          .collection('tokens')
                          .snapshots()
                          .listen((QuerySnapshot snapshot) {
                        if (snapshot.size == 0) return;

                        List<String> tokens = [];
                        snapshot.docs.forEach((DocumentSnapshot document) {
                          print(document.id);
                          tokens.add(document.id);
                        });

                        print(tokens);

                        Service().sendNotification(
                          'test title message only',
                          'test body message, from test notification button.',
                          RouteNames.profile,
                          registration_ids: tokens,
                          // topic: App.Settings.allTopic,
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
                    onPressed: () => Get.toNamed(RouteNames.forum,
                        arguments: {'category': 'qna'}),
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
                RaisedButton(
                  onPressed: () => Get.toNamed(RouteNames.settings),
                  child: Text('Settings'),
                ),
                for (var item in translations.keys)
                  Text('$item: ' + translations[item]['ko']),
              ],
            );
          }),
        ],
      ),
    );
  }
}
