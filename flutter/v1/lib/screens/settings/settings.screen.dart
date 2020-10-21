import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/route-names.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, bool> option = {
    'notifyComment': false,
    'notifyPost': false,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.tr),
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
                if (user.isNotLoggedIn) ...[],
                if (user.isLoggedIn) ...[
                  RaisedButton(
                    onPressed: () => Get.toNamed(RouteNames.profile),
                    child: Text('Profile'),
                  ),
                  RaisedButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: Text('Logout'),
                  ),
                  Text('Comment Notification'),
                  Switch(
                    value: option['notifyComment'],
                    onChanged: (value) {
                      setState(() {
                        option['notifyComment'] = value;
                        print(option['notifyComment']);
                      });
                    },
                  ),
                  Text('Comment Notification'),
                  Switch(
                    value: option['notifyComment'],
                    onChanged: (value) {
                      setState(() {
                        option['notifyComment'] = value;
                        print(option['notifyComment']);
                      });
                    },
                  )
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}
