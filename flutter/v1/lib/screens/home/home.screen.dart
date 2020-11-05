import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route_names.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text('app name'.tr),
        showBackButton: false,
      ),
      endDrawer: CommonAppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: ff.userChange,
              builder: (context, snapshot) {
                if (ff.userIsLoggedOut) {
                  return Column(
                    children: [
                      RaisedButton(
                        onPressed: () => Get.toNamed(RouteNames.login),
                        child: Text('Login'),
                      ),
                      RaisedButton(
                        onPressed: () =>
                            Get.toNamed(RouteNames.register, id: 2),
                        child: Text('Register'),
                      ),
                    ],
                  );
                }

                /// when user logged in,
                return Column(
                  children: [
                    Text('app_title'.tr),
                    Text("User Uid: ${ff.user.uid}"),
                    Text("User Email: ${ff.user.email}"),
                    Text("User Nickname: ${ff.user.displayName}"),
                    Text("User Gender: ${ff.data['gender']}"),
                    Text("User Phone number: ${ff.user.phoneNumber}"),
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
                final CollectionReference users =
                    FirebaseFirestore.instance.collection('users');
                users
                    .doc(ff.user.uid)
                    .collection('meta')
                    .doc('tokens')
                    .snapshots()
                    .listen((DocumentSnapshot document) {
                  List<String> tokens = [];
                  print(document.id);
                  tokens.add(document.id);

                  print(tokens);

                  ff.sendNotification(
                    'test title message only',
                    'test body message, from test notification button.',
                    // token: ff.firebaseMessagingToken,
                    // tokens: tokens,
                    id: '0X1upoaLklWc2Z07dsbn',
                    screen: '/forumView',
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
              onPressed: () => Get.toNamed(
                RouteNames.forum,
                arguments: {'category': 'qna'},
              ),
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
            RaisedButton(
              onPressed: () => Get.toNamed(RouteNames.forumView,
                  arguments: {'id': '0YJHJum1EYb6ZaFOVNPx'}),
              child: Text('Post View'),
            ),
            RaisedButton(
              onPressed: () => Get.toNamed(RouteNames.search),
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
