import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
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
  Location location = new Location();

  bool isLoadingLocations = true;
  bool isLocationServiceEnabled;
  PermissionStatus permissionStatus;
  StreamSubscription subscription;

  Map<String, dynamic> usersNearMe = {};

  /// todo Updating user location on firestore
  /// * When app starts update user location if user has logged in.
  /// * When user logs in.
  /// * When user moves to another location.
  /// todo interval should be adjustable and the default is 30 seconds.
  /// ! move this code to main. This must work in background since it may take time.
  _initLocation() async {
    // check if service is enabled
    isLocationServiceEnabled = await location.serviceEnabled();
    if (!isLocationServiceEnabled) {
      // request if not enabled
      isLocationServiceEnabled = await location.requestService();
      if (!isLocationServiceEnabled) {
        setState(() => isLoadingLocations = false);
        return;
      }
    }

    // check if have permission to use location service
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      setState(() => isLoadingLocations = false);
      return;
    }

    if (permissionStatus == PermissionStatus.denied) {
      // request if permission is not granted.
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        setState(() => isLoadingLocations = false);
        return;
      }
    }

    try {
      // get current location of the user. base on device's location.
      LocationData currentLocation = await location.getLocation();

      // update user's new location
      await Service.updateUserLocation(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );

      // get other users "near me".
      _getUsersNearMe(
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );

      setState(() {
        isLoadingLocations = false;
      });
    } catch (e) {
      return Service.error(e);
    }
  }

  _getUsersNearMe({double latitude, double longitude}) {
    subscription = Service.findLocationsNearMe(
      latitude: latitude,
      longitude: longitude,
    ).listen((List<DocumentSnapshot> documents) {
      documents.forEach((document) {
        // Map<String, dynamic> data = document.data();
        // GeoPoint pos = data['location']['geopoint'];
        // print(data);

        // if this is the current user's data. don't add it to the list.
        if (document.id == ff.user.uid) return;
        if (!mounted) return;

        // TODO: get other user's info near me.
        setState(() {
          usersNearMe.putIfAbsent(document.id, () => document.id);
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
    if (subscription != null) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingLocations) return Center(child: CommonSpinner());

    if (!isLocationServiceEnabled)
      return Center(
        child: Column(
          children: [
            Text('Enable Location Service'),
            SizedBox(height: Space.md),
            RaisedButton(
              onPressed: () {
                _initLocation();
              },
              child: Text('Retry'),
            )
          ],
        ),
      );

    if (permissionStatus == PermissionStatus.deniedForever ||
        permissionStatus == PermissionStatus.denied)
      return Center(
        child: Text('This app doesn\'t have permission to access Location'),
      );

    return Column(
      children: [
        Text('Users near you: '),
        for (String uid in usersNearMe.values)
          Padding(
            padding: EdgeInsets.only(top: Space.md),
            child: Text('$uid'),
          ),
      ],
    );
  }
}
