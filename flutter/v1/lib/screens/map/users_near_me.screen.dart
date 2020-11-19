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

class _UsersNearMeState extends State<UsersNearMe> with WidgetsBindingObserver {
  bool loadingLocations = true;
  bool hasLocationPermission = true;

  StreamSubscription nearMeSubscription;
  Map<String, dynamic> usersNearMe = {};

  checkPermission() async {
    PermissionStatus permission = await Service.location.hasPermission();
    hasLocationPermission = permission == PermissionStatus.granted;
    setState(() {
      if (hasLocationPermission) {
        loadingLocations = false;
      }
    });
  }

  _getUsersNearMe(LocationData location) {
    print('_getUsersNearMe');
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
    checkPermission();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  /// Workaround: [see](https://github.com/Baseflow/flutter-permission-handler/issues/247)
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      setState(() => loadingLocations = true);
      checkPermission();
      Service.initUserLocation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (nearMeSubscription != null) {
      nearMeSubscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!hasLocationPermission)
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

    return StreamBuilder(
      stream: Service.location.onLocationChanged,
      builder: (c, s) {
        if (s.hasData) {
          _getUsersNearMe(s.data);

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
        } else {
          return Center(
            child: CommonSpinner(),
          );
        }
      },
    );
  }
}
