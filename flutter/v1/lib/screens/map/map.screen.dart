import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:v1/services/functions.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1/services/global_variables.dart';
import 'package:v1/services/service.dart';
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

  bool gettingLocation = true;
  bool locationServiceEnabled;
  PermissionStatus permissionStatus;

  CameraPosition _myLocation;

  StreamSubscription subscription;

  // markers
  // TODO: fill with markers of "near me"
  Map<String, Marker> markers = {};

  _getMyLocation() async {
    locationServiceEnabled = await location.serviceEnabled();
    if (!locationServiceEnabled) {
      locationServiceEnabled = await location.requestService();
      if (!locationServiceEnabled) {
        return;
      }
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    LocationData loc = await location.getLocation();
    final LatLng position = LatLng(
      loc.latitude,
      loc.longitude,
    );

    _myLocation = CameraPosition(
      target: position,
      zoom: 14.4746,
    );
    _addMarker(position);
    _getLocationsNearMe(position);

    setState(() {
      gettingLocation = false;
    });
  }

  /// TODO: add info window
  _addMarker(LatLng position) {
    String markerID = randomString();
    markers[markerID] = Marker(
      markerId: MarkerId(randomString()),
      position: position,
    );
  }

  /// TODO: make it work...
  _getLocationsNearMe(LatLng position) {
    final geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);

    Query q = FirebaseFirestore.instance.collectionGroup('meta');

    q.snapshots().listen((event) {
      event.docs.forEach((doc) {
        print(doc.data());
      });
    }, onError: (err) => Service.error(err));
  }

  @override
  void initState() {
    _getMyLocation();
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
      initialCameraPosition: _myLocation,
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
