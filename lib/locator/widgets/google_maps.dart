import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMaps extends StatefulWidget {
  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController mapController;
  // Set of markers
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();

    // Adding a sample marker
    _markers.add(
      const Marker(
        markerId: MarkerId('Olive Young Itaewon Branch'),
        position: LatLng(37.53457, 126.98994), // Sample position
        infoWindow: InfoWindow(
          title: 'Olive Young Itaewon Branch',
          snippet: '145 Itaewon-ro, Yongsan District, Seoul, South Korea',

        ),
        icon: BitmapDescriptor.defaultMarker, // You can use a custom marker icon if needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.55394, 126.98181),
          zoom: 12,
        ),
        mapType: MapType.normal,
        markers: _markers, // Add the markers to the map
      ),
    );
  }
}