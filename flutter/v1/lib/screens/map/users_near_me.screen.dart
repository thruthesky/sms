import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:v1/services/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';
import 'package:v1/widgets/commons/spinner.dart';

class UsersNearMeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text('Users Near Me'),
      ),
      endDrawer: CommonAppDrawer(),
      body: Container(
        padding: EdgeInsets.all(Space.pageWrap),
        child: UsersNearMe(),
      ),
    );
  }
}

class UsersNearMe extends StatefulWidget {
  @override
  _UsersNearMeState createState() => _UsersNearMeState();
}

class _UsersNearMeState extends State<UsersNearMe> with WidgetsBindingObserver {
  // bool loadingLocations = true;
  bool serviceEnabled = false;
  bool hasPermission = false;

  // Subscriptions
  StreamSubscription locationSubscription;
  StreamSubscription usersSubscription;

  Map<String, dynamic> users = {};
  checkPermission() async {
    hasPermission = await location.hasPermission();
    serviceEnabled = await location.instance.serviceEnabled();
    setState(() {});
  }

  @override
  void initState() {
    locationSubscription = location.change.listen((point) {
      print(
          "User changed his location. Search users again based on the user's new location");
    });
    usersSubscription = location.users.listen((users) {
      print("Got users near me");
      print(users);
      setState(() {
        this.users = users;
      });
    });
    checkPermission();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  // check permissions when app is resumed
  // this is when permissions are changed in app settings outside of app
  //
  // [see](https://github.com/Baseflow/flutter-permission-handler/issues/247)
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('in users near me screen');
    // if state is resumed, do initialize user location again.
    if (state == AppLifecycleState.resumed) {
      checkPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (usersSubscription != null) {
      usersSubscription.cancel();
    }
    if (locationSubscription != null) {
      locationSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission)
      return Center(
        child: Column(
          children: [
            Text(
              'This app doesn\'t have the permission to use location service.',
            ),
            RaisedButton(
              onPressed: () {
                ff.openAppSettings();
              },
              child: Text('Changes App Settings'),
            )
          ],
        ),
      );

    // if (loadingLocations) return Center(child: CommonSpinner());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Location Service: ' + (serviceEnabled ? 'ON' : 'OFF')),
        Text('Location Permission: ' + (hasPermission ? 'ON' : 'OFF')),
        Text('${users.length} User near you: '),
        for (dynamic user in users.values)
          Padding(
            padding: EdgeInsets.only(top: Space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Photo URL: ${user['photoURL']}'),
                Text('Display Name: ${user['displayName']}'),
              ],
            ),
          ),
      ],
    );
  }
}
