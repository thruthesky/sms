import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// users collection referrence
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  final userController = Get.find<UserController>();

  bool notifyPost = false;
  bool notifyComment = false;

  @override
  void initState() {
    /// get document with current logged in user's uid.
    users.doc(userController.user.uid).get().then(
      (DocumentSnapshot doc) {
        if (!doc.exists) {
          // It's not an error. User may not have documentation. see README
          print('User has no document. fine.');
          return;
        }
        final data = doc.data();
        this.notifyPost = data['notifyPost'] ?? false;
        this.notifyComment = data['notifyComment'] ?? false;
        setState(() {});
      },
    );
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
                  Text('Post Notification'),
                  Switch(
                    value: notifyPost,
                    onChanged: (value) async {
                      try {
                        final userDoc = users.doc(userController.user.uid);
                        await userDoc.set({
                          "notifyPost": value,
                        }, SetOptions(merge: true));
                        Get.snackbar('Update', 'Settings updated!');
                      } catch (e) {
                        Service.error(e);
                      }
                      setState(() {
                        notifyPost = value;
                        print(notifyPost);
                      });
                    },
                  ),
                  Text('Comment Notification'),
                  Switch(
                    value: notifyComment,
                    onChanged: (value) async {
                      try {
                        final userDoc = users.doc(userController.user.uid);
                        await userDoc.set({
                          "notifyComment": value,
                        }, SetOptions(merge: true));
                        Get.snackbar('Update', 'Settings updated!');
                      } catch (e) {
                        Service.error(e);
                      }
                      setState(() {
                        notifyComment = value;
                        print(notifyComment);
                      });
                    },
                  ),
                  Text(Service.firebaseMessagingToken.substring(0, 20)),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}
