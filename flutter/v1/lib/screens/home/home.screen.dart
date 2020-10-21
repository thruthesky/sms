import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/translations.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                    onPressed: () => Service().sendNotification(
                      'test message', 'test body',
                      RouteNames.profile,
                      // token: Service.firebaseMessagingToken
                    ),
                    child: Text('Send Test Notification'),
                  ),
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.admin),
                    child: Text('Admin Screen'),
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
