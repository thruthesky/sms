import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:v1/services/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';
import 'package:v1/widgets/commons/spinner.dart';

import 'package:geoflutterfire/geoflutterfire.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text('Map Screen'),
      ),
      endDrawer: CommonAppDrawer(),
      body: MapWidget(),
    );
  }
}

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Location location = new Location();
  GoogleMapController mapController;

  bool gettingLocation = true;
  bool locationServiceEnabled;
  PermissionStatus permissionStatus;

  CameraPosition initialLocation;

  StreamSubscription subscription;

  // markers
  // TODO: fill with markers of "near me"
  Map<String, Marker> markers = {};

  _getCurrentLocation() async {
    // check if service is enabled
    locationServiceEnabled = await location.serviceEnabled();
    if (!locationServiceEnabled) {
      // request if not enabled
      locationServiceEnabled = await location.requestService();
      if (!locationServiceEnabled) {
        return;
      }
    }

    // check if have permission to use location service
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      // request if permission is not granted.
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    // get current location of the user. base on device's location.
    LocationData loc = await location.getLocation();
    final LatLng position = LatLng(
      loc.latitude,
      loc.longitude,
    );

    // set current location as the initial position for the map.
    initialLocation = CameraPosition(
      target: position,
      zoom: 14.4746,
    );

    /// add "My location" marker
    _addMarker(position);

    /// get other locations near me.
    _getLocationsNearMe(position);

    ff.updateUserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    setState(() {
      gettingLocation = false;
    });
  }

  // TODO: add info window
  _addMarker(LatLng position) {
    String markerID = randomString();
    markers[markerID] = Marker(
      markerId: MarkerId(randomString()),
      position: position,
    );
  }

  // TODO: make it work...
  _getLocationsNearMe(LatLng position) {
    print('TODO: "Near Me"');

    GeoFirePoint point = ff.getGeoFirePoint(latitude: position.latitude, longitude: position.longitude);

    Query q = FirebaseFirestore.instance
        .collection('users-public')
        .where('geohash', isGreaterThanOrEqualTo: point.hash)
        .where('geohash', isLessThanOrEqualTo: point.hash);

    q.snapshots().listen((event) {
      print('event.size');
      print(event.size);

      event.docs.forEach((doc) {
        print(doc.data());
      });
    }).onError((e) {
      Service.error(e);
    });
  }

  @override
  void initState() {
    _getCurrentLocation();
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
    if (gettingLocation) return Center(child: CommonSpinner());

    if (!locationServiceEnabled)
      return Center(
        child: Text('Enable Location Service'),
      );

    if (permissionStatus == PermissionStatus.deniedForever ||
        permissionStatus == PermissionStatus.denied)
      return Center(
        child: Text('This app doesn\'t have permission to access Location'),
      );

    return GoogleMap(
      initialCameraPosition: initialLocation,
      onMapCreated: (controller) {
        setState(() {
          mapController = controller;
        });
      },
      markers: markers.values.toSet(),
      // myLocationEnabled: true,
    );
  }
}
