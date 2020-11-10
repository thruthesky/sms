import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
import 'package:v1/services/spaces.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';
import 'package:v1/widgets/commons/spinner.dart';

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

  // markers
  // TODO: fill with markers of "near me" locations
  Map<String, Marker> markers = {};

  _initLocation() async {
    // check if service is enabled
    locationServiceEnabled = await location.serviceEnabled();
    if (!locationServiceEnabled) {
      // request if not enabled
      locationServiceEnabled = await location.requestService();
      if (!locationServiceEnabled) {
        setState(() => gettingLocation = false);
        return;
      }
    }

    // check if have permission to use location service
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      setState(() => gettingLocation = false);
      return;
    }
    if (permissionStatus == PermissionStatus.denied) {
      // request if permission is not granted.
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        setState(() => gettingLocation = false);
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

      // create position for the initial map location.
      final LatLng position = LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      );

      // set current location as the initial position for the map.
      initialLocation = CameraPosition(
        target: position,
        zoom: 15,
      );

      // get other locations "near me".
      _getLocationsNearMe(position);

      setState(() {
        gettingLocation = false;
      });
    } catch (e) {
      return Service.error(e);
    }
  }

  _getLocationsNearMe(LatLng position) async {
    subscription = Service
        .findLocationsNearMe(
          latitude: position.latitude,
          longitude: position.longitude,
        )
        .listen(_updateMapMarkers);
  }

  // TODO: add info window
  _updateMapMarkers(List<DocumentSnapshot> documents) {
    // print('Locations near me:');
    documents.forEach((document) {
      Map<String, dynamic> data = document.data();
      GeoPoint pos = data['location']['geopoint'];
      String markerID = document.id;
      // print(data);

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
    if (gettingLocation) return Center(child: CommonSpinner());

    if (!locationServiceEnabled)
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

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialLocation,
          onMapCreated: (controller) {
            setState(() {
              mapController = controller;
            });
          },
          // toSet() removes duplicates if there's any.
          markers: markers.values.toSet(),
          myLocationEnabled: true,
        ),
        Positioned(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(Space.sm),
            child: Text('${markers.values.toSet().length} person near you'),
          ),
          top: Space.md,
          left: Space.md,
        ),
      ],
    );
  }
}
