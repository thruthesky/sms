import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/controllers/user.controller.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_drawer.dart';

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
    users
        .doc(userController.user.uid)
        .collection('meta')
        .doc('public')
        .get()
        .then(
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
      endDrawer: CommonAppDrawer(),
      body: Column(
        children: [
          Container(
            child: Text('menu'.tr),
          ),
          Text('submit'.tr),
          StreamBuilder(
              stream: ff.authStateChanges,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    Text("User Uid: ${ff.user?.uid}"),
                    Text("User Nickname: ${ff.user?.displayName}"),
                    if (ff.user.isNull) ...[],
                    if (!ff.user.isNull) ...[
                      Text(
                        'Post Notification',
                        style: TextStyle(fontSize: Space.lg),
                      ),
                      Text('Comment Notification under my post'),
                      Switch(
                        value: notifyPost,
                        onChanged: (value) async {
                          try {
                            final userDoc = users
                                .doc(userController.user.uid)
                                .collection('meta')
                                .doc('public');
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
                      Text('Comment Notification under my comment'),
                      Switch(
                        value: notifyComment,
                        onChanged: (value) async {
                          try {
                            final userDoc = users
                                .doc(userController.user.uid)
                                .collection('meta')
                                .doc('public');
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
                      Text(ff.firebaseMessagingToken.substring(0, 20)),
                    ],
                  ],
                );
              }),
        ],
      ),
    );
  }
}
