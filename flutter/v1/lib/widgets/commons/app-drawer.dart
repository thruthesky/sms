import 'package:flutter/material.dart';
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
      child: Column(
        children: [
          SizedBox(height: Space.xxxl),
          StreamBuilder(
            stream: ff.userChange,
            builder: (context, snapshot) {
              if (ff.userIsLoggedOut) {
                return Column(
                  children: [
                    RaisedButton(
                      onPressed: () => Service.openScreen(RouteNames.login),
                      child: Text('Login'),
                    ),
                    RaisedButton(
                      onPressed: () => Service.openScreen(RouteNames.register),
                      child: Text('Register'),
                    ),
                  ],
                );
              }

              /// when user logged in,
              return Column(
                children: [
                  RaisedButton(
                    onPressed: () => Service.openScreen(RouteNames.profile),
                    child: Text('Profile'),
                  ),
                  RaisedButton(
                    onPressed: ff.logout,
                    child: Text('Logout'),
                  ),
                  RaisedButton(
                    onPressed: () => Service.openScreen(RouteNames.settings),
                    child: Text('Settings'),
                  ),
                ],
              );
            },
          ),
          RaisedButton(
            onPressed: () => Service.openScreen(RouteNames.admin),
            child: Text('Admin Screen'),
          ),
          RaisedButton(
            onPressed: () => Service.openForumScreen('qna'),
            child: Text('QnA'),
          ),
          RaisedButton(
            onPressed: () => Service.openForumScreen('discussion'),
            child: Text('Discussion'),
          ),
          RaisedButton(
            onPressed: () => Service.openForumScreen('reminder'),
            child: Text('Reminder'),
          ),
          RaisedButton(
            onPressed: () => Service.openScreen(
              RouteNames.forumView,
              arguments: {'id': '0YJHJum1EYb6ZaFOVNPx'},
            ),
            child: Text('Post View'),
          ),
          RaisedButton(
            onPressed: () => Service.openScreen(RouteNames.search),
            child: Text('Search'),
          ),
        ],
      ),
    );
  }
}
