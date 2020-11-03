import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/route-names.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';

class CommonAppDrawer extends StatefulWidget {
  @override
  _CommonAppDrawerState createState() => _CommonAppDrawerState();
}

class _CommonAppDrawerState extends State<CommonAppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: EdgeInsets.all(Space.pageWrap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: Space.xxxl),
            StreamBuilder(
              stream: ff.userChange,
              builder: (context, snapshot) {
                if (ff.userIsLoggedOut) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RaisedButton(
                        onPressed: () {
                          Get.back();
                          Service.openScreen(RouteNames.login);
                        },
                        child: Text('Login'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          Get.back();
                          Service.openScreen(RouteNames.register);
                        },
                        child: Text('Register'),
                      ),
                    ],
                  );
                }

                /// when user logged in,
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RaisedButton(
                      onPressed: () {
                        Get.back();
                        Service.openScreen(RouteNames.profile);
                      },
                      child: Text('Profile'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Service.logout();
                      },
                      child: Text('Logout'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Get.back();
                        Service.openScreen(RouteNames.settings);
                      },
                      child: Text('Settings'),
                    ),
                  ],
                );
              },
            ),
            RaisedButton(
              onPressed: () {
                Get.back();
                Service.openScreen(RouteNames.admin);
              },
              child: Text('Admin Screen'),
            ),
            RaisedButton(
              onPressed: () {
                Get.back();
                Service.openForumScreen('qna');
              },
              child: Text('QnA'),
            ),
            RaisedButton(
              onPressed: () {
                Get.back();
                Service.openForumScreen('discussion');
              },
              child: Text('Discussion'),
            ),
            RaisedButton(
              onPressed: () {
                Get.back();
                Service.openForumScreen('reminder');
              },
              child: Text('Reminder'),
            ),
            RaisedButton(
              onPressed: () {
                Get.back();
                Service.openScreen(
                  RouteNames.forumView,
                  arguments: {'id': '0YJHJum1EYb6ZaFOVNPx'},
                );
              },
              child: Text('Post View'),
            ),
            RaisedButton(
              onPressed: () {
                Get.back();
                Service.openScreen(RouteNames.search);
              },
              child: Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
