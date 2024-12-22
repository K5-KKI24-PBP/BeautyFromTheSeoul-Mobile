import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/location_entry.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/edit_location.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/location_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocatorPage extends StatefulWidget {
  final String? initialDistrict; 

  const LocatorPage({super.key, this.initialDistrict});

  @override
  State<LocatorPage> createState() => _LocatorPageState();
}

class _LocatorPageState extends State<LocatorPage> {
  bool isStaff = false;
  bool isLoading = true;
  List<Map<String, dynamic>> locations = [];
  List<Map<String, dynamic>> filteredLocations = [];
  String? selectedDistrict;

  List<String> districts = [];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _fetchLocations();
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('userRole') ?? '';
    setState(() {
      isStaff = userRole == 'admin';
    });
  }

  Future<void> _fetchLocations() async {
    const url = 'https://beauty-from-the-seoul.vercel.app/store-locator/fetch_location/';

    try {
      setState(() {
        isLoading = true;  // Start loading
      });

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final locationList = List<Map<String, dynamic>>.from(data['locations']);

        setState(() {
          locations = locationList;
          districts = _extractDistricts(locations);

          if (widget.initialDistrict != null && widget.initialDistrict!.isNotEmpty) {
            _filterByDistrict(widget.initialDistrict);
          } else {
            filteredLocations = locations;
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load locations');
      }
    } catch (error) {
      print('Error fetching locations: $error');
    }
  }

  List<String> _extractDistricts(List<Map<String, dynamic>> locations) {
    Set<String> districtSet = {};
    for (var location in locations) {
      districtSet.add(location['district']);
    }
    return districtSet.toList();
  }

  void _filterByDistrict(String? district) {
    setState(() {
      selectedDistrict = district;
      if (district == null || district.isEmpty) {
        filteredLocations = locations;
      } else {
        filteredLocations = locations
            .where((location) => location['district'] == district)
            .toList();
      }
    });
  }

  Future<void> _navigateToAddLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocatorEntryPage()),
    );

    if (result == true) {
      _fetchLocations();
    }
  }

  Future<void> deleteLocation(String id) async {
    final url = 'https://beauty-from-the-seoul.vercel.app/store-locator/delete_location/$id/';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          locations.removeWhere((location) => location['id'] == id);
          _filterByDistrict(selectedDistrict);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Location deleted successfully')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to delete location')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting location: $e')));
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

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text("Filter by District"),
              value: selectedDistrict,
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('All Districts'),
                ),
                ...districts.map((district) {
                  return DropdownMenuItem(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                _filterByDistrict(value);
              },
            ),
          ),

          Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : filteredLocations.isEmpty
                  ? const Center(
                      child: Text(
                        'No locations available.',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,  // Maximum width per card
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                        childAspectRatio: 0.75,  // Adjust for card height
                      ),
                      itemCount: filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = filteredLocations[index];
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
                          index: index,
                        );
                      },
                    ),
        )

        ],
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton(
              onPressed: _navigateToAddLocation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: const Material3BottomNav(),
    );
  }
}
