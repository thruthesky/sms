import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1/services/global_variables.dart';
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
  CameraPosition initialLocation;

  bool gettingLocation = true;

  bool locationServiceEnabled;
  PermissionStatus permissionStatus;

  StreamSubscription subscription;

  // "Near Me" search radius by kilometers
  // TODO: this can be added as part of app settings
  double searchRadius = 2;

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
    LocationData currentLoccation = await location.getLocation();
    // print(currentLoccation.latitude);
    // print(currentLoccation.longitude);

    // update user's new location
    ff.updateUserLocation(
      latitude: currentLoccation.latitude,
      longitude: currentLoccation.longitude,
    );

    // create position for the initi
    final LatLng position = LatLng(
      currentLoccation.latitude,
      currentLoccation.longitude,
    );

    // set current location as the initial position for the map.
    initialLocation = CameraPosition(
      target: position,
      zoom: 14.4746,
    );

    // get other locations near me.
    _getLocationsNearMe(position);

    setState(() {
      gettingLocation = false;
    });
  }

  _getLocationsNearMe(LatLng position) {
    GeoFirePoint point = ff.getGeoFirePoint(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    // collection reference
    CollectionReference ref = FirebaseFirestore.instance.collection(
      'users-public',
    );

    // query for "nearby me"
    // [radius] is by kilometers
    // cancel subscription later.
    subscription = ff.geo
        .collection(collectionRef: ref)
        .within(
          center: point,
          radius: searchRadius,
          field: 'location',
          strictMode: true,
        )
        .listen(_addMarkers);
  }

  // TODO: add info window
  _addMarkers(List<DocumentSnapshot> documents) {
    print('Locations near me:');
    documents.forEach((document) {
      Map<String, dynamic> data = document.data();
      GeoPoint pos = data['location']['geopoint'];
      String markerID = document.id;
      print(data);

      if (markerID != ff.user.uid) {
        setState(() {
          markers[markerID] = Marker(
            markerId: MarkerId(markerID),
            position: LatLng(pos.latitude, pos.longitude),
          );
        });
      }
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
      // toSet() removes duplicates if there's any.
      markers: markers.values.toSet(),
      myLocationEnabled: true,
    );
  }
}
