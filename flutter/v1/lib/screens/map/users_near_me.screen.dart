import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
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

class _UsersNearMeState extends State<UsersNearMe> {
  bool loadingLocations = true;
  PermissionStatus locationPermission;

  StreamSubscription locationSubscription;
  StreamSubscription nearMeSubscription;
  Map<String, dynamic> usersNearMe = {};

  _initLocation() async {
    locationPermission = await Service.location.hasPermission();

    if (locationPermission != PermissionStatus.granted){
      return setState(() => loadingLocations = false);
    }

    locationSubscription = Service.userLocation.listen(_getUsersNearMe);
  }

  _getUsersNearMe(LocationData location) {
    nearMeSubscription = Service.findUsersNearMe(
      latitude: location.latitude,
      longitude: location.longitude,
    ).listen((List<DocumentSnapshot> documents) {
      setState(() => loadingLocations = false);

      if (documents.isEmpty) setState(() => usersNearMe = {});

      documents.forEach((document) {
        print("user location near me");
        print(document.id);

        // if this is the current user's data. don't add it to the list.
        if (document.id == ff.user.uid) return;
        if (!mounted) return;

        // TODO: get other user's info near me.
        setState(() {
          usersNearMe.putIfAbsent(document.id, () => document.data());
        });
      });
    });
  }

  @override
  void initState() {
    _initLocation();
    super.initState();
  }

  @override
  void dispose() {
    if (locationSubscription != null) {
      locationSubscription.cancel();
      if (nearMeSubscription != null) {
        nearMeSubscription.cancel();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loadingLocations)
      return Center(
        child: CommonSpinner(),
      );

    if (locationPermission != PermissionStatus.granted)
      return Center(
        child: Text(
            'This app doesn\'t have the permission to use location service.'),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${usersNearMe.length} User near you: '),
        for (dynamic user in usersNearMe.values)
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
