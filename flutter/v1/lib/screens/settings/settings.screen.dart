import 'dart:async';

import 'package:fireflutter/fireflutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_drawer.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> public;

  StreamSubscription firebaseSubscription;
  bool loading = true;
  @override
  void initState() {
    firebaseSubscription = ff.firebaseInitialized.listen((value) async {
      public = await ff.userPublicData();
      setState(() => loading = false);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    firebaseSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.tr),
      ),
      endDrawer: CommonAppDrawer(),
      body: loading
          ? CircularProgressIndicator()
          : Column(
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
                            value: public[notifyPost] ?? false,
                            onChanged: (value) async {
                              setState(() => public[notifyPost] = value);
                              // try {
                              //   ff.updateUserMeta({
                              //     'public': {
                              //       notifyPost: value,
                              //     },
                              //   });
                              //   Get.snackbar('Update', 'Settings updated!');
                              // } catch (e) {
                              //   Service.error(e);
                              // }
                            },
                          ),
                          Text('Comment Notification under my comment'),
                          Switch(
                            value: public[notifyComment] ?? false,
                            onChanged: (value) async {
                              setState(() => public[notifyComment] = value);
                              // try {
                              //   ff.updateUserMeta({
                              //     'public': {
                              //       notifyComment: value,
                              //     },
                              //   });
                              //   Get.snackbar('Update', 'Settings updated!');
                              // } catch (e) {
                              //   Service.error(e);
                              // }
                            },
                          ),
                          Text(ff.firebaseMessagingToken.substring(0, 20)),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }
}
