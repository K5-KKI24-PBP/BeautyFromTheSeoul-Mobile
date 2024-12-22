import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/location_entry.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/edit_location.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/location_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocatorPage extends StatefulWidget {
  const LocatorPage({super.key});

  @override
  State<LocatorPage> createState() => _LocatorPageState();
}

class _LocatorPageState extends State<LocatorPage> {
  bool isStaff = false;
  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _fetchLocations(); // Fetch locations from the server
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('userRole') ?? '';
    setState(() {
      isStaff = userRole == 'admin';
    });
  }

  Future<void> _fetchLocations() async {
    const Url = 'http://localhost:8000/store-locator/fetch_location/';

    try {
      final response = await http.get(Uri.parse(Url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Assuming the API returns a list of locations under the "locations" key
        setState(() {
          locations = List<Map<String, dynamic>>.from(data['locations']);
        });
        print(locations);
      } else {
        // Handle server errors
        throw Exception('Failed to load locations');
      }
    } catch (error) {
      // Handle network errors
      print('Error fetching locations: $error');
    }
  }

  Future<void> _navigateToAddLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocatorEntryPage()),
    );

    // If the result is true, fetch locations again
    if (result == true) {
      _fetchLocations();
    }
  }

  // Delete location from the backend
  Future<void> deleteLocation(String id) async {
    final url = 'http://localhost:8000/store-locator/delete_location/$id/';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          locations.removeWhere((location) => location['id'] == id); // Remove from UI
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete location')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Locator'),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 3),
                    const Text(
                      'Find a skincare store near you!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 60,
                      height: 3,
                      color: const Color(0xFFE1DCCA),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: locations.isEmpty
                ? const Center(
                    child: Text(
                    'No locations available.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];
                      return LocationCard(
                        location: location,
                        isStaff: isStaff,
                        onDelete: deleteLocation,
                        onEdit: (id) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditLocationPage(
                                id: id,
                                storeName: location['storeName'] ?? '',
                                streetName: location['streetName'] ?? '',
                                district: location['district'] ?? '',
                                gmapsLink: location['gmapsLink'] ?? '',
                                storeImage: location['storeImage'] ?? '',
                                onSave: _fetchLocations,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isStaff
        ? FloatingActionButton(
            onPressed: _navigateToAddLocation,
            child: const Icon(Icons.add),
            backgroundColor: Colors.blue,
          )
        : null,  // When isStaff is false, no floating action button will be shown
    bottomNavigationBar: const Material3BottomNav(),
    );
  }
}