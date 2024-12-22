import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/location_entry.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/edit_location.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/location_card.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/google_maps.dart';
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
        isLoading = true;
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
    final screenWidth = MediaQuery.of(context).size.width;

    double maxCrossAxisExtent = screenWidth < 300
        ? 200  // Smaller screen width
        : screenWidth < 400
            ? 250  // Medium screen width
            : screenWidth < 600
                ? 300  // Larger screen width
                : 350;  // Extra large screen width

    double cardAspectRatio = screenWidth < 300
        ? 0.4
        : screenWidth < 600
            ? 0.58
            : screenWidth < 700
                ? 0.6
                : 0.69;

    double mainAxisSpacing = screenWidth < 300
        ? 6.0
        : screenWidth < 400
            ? 8.0
            : screenWidth < 600
                ? 10.0
                : 12.0;

    double crossAxisSpacing = screenWidth < 300
        ? 6.0
        : screenWidth < 400
            ? 8.0
            : screenWidth < 600
                ? 10.0
                : 12.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Favorite Products',
          style: TextStyle(
            fontFamily: 'Laurasia',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF071a58), 
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/locator.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const Positioned(
                  top: 75,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        'Store Locator',
                        style: TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          fontFamily: 'Laurasia',
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Find a skincare store near you!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'TT',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Check Out Our Seoul Skincare Stores Map!',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Laurasia',
                color:  Color(0xff071a58),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xff071a58),  
                    width: 6,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: GoogleMaps(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Which district is closest to you?',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'TT',
                color: Color(0xff071a58),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("All Districts"),
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
            const SizedBox(height: 30),
            isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : filteredLocations.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'No locations available.',
                            style: TextStyle(
                              fontFamily: 'TT',
                              fontSize: 18),
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: maxCrossAxisExtent,
                          mainAxisSpacing: mainAxisSpacing,
                          crossAxisSpacing: crossAxisSpacing,
                          childAspectRatio: cardAspectRatio,
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
          ],
        ),
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton(
              onPressed: _navigateToAddLocation,
              backgroundColor: const Color(0xFF071a58),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: const Material3BottomNav(),
    );
  }
}