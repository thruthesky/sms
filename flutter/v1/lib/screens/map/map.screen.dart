import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:v1/widgets/commons/app_bar.dart';
import 'package:v1/widgets/commons/app_drawer.dart';
// import 'package:v1/widgets/commons/spinner.dart';

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
  GoogleMapController mapController;

  Location location = new Location();
  CameraPosition _myLocation;

  _getMyLocation() async {
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    PermissionStatus _permissionStatus = await location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    LocationData _locationData = await location.getLocation();
    setState(() {
      _myLocation = CameraPosition(
        target: LatLng(_locationData.latitude, _locationData.longitude),
        zoom: 14.4746,
      );
    });
  }

  @override
  void initState() {
    _getMyLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _myLocation != null
        ? GoogleMap(
            initialCameraPosition: _myLocation,
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
          )
        : SizedBox.shrink();
  }
}
