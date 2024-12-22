import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:beauty_from_the_seoul_mobile/locator/data/store_data.dart';

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({super.key});

  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController mapController;
  // Set of markers
  final Set<Marker> _markers = {};

  void _addMarkers(List<Map<String, dynamic>> locations) {
    for (var location in locations) {
      _markers.add(
        Marker(
          markerId: MarkerId(location['id']), // Use a unique ID for each marker
          position: LatLng(location['latitude'], location['longitude']),
          infoWindow: InfoWindow(
            title: location['name'],
            snippet: location['address'],
          ),
          icon: _getMarkerColor(location['name']), // Use custom icons if required
        ),
      );
    }
  }

  BitmapDescriptor _getMarkerColor(String storeName) {
    if (storeName.toLowerCase().contains('innisfree')) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // Light green
    } else if (storeName.toLowerCase().contains('olive young')) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan); // Dark green
    } else {
      return BitmapDescriptor.defaultMarker; // Default red
    }
  }

  @override
  void initState() {
    super.initState();

    _addMarkers(sampleLocations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.55394, 126.98181),
          zoom: 12,
        ),
        mapType: MapType.normal,
        markers: _markers, // Add the markers to the map
      ),
    );
  }
}