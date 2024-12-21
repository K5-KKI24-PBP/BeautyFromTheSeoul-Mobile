import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/location_entry.dart';
import 'package:beauty_from_the_seoul_mobile/locator/widgets/edit_location.dart';

class LocatorPage extends StatefulWidget {
  const LocatorPage({super.key});

  @override
  State<LocatorPage> createState() => _LocatorPageState();
}

class _LocatorPageState extends State<LocatorPage> {
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to LocatorEntryPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LocatorEntryPage()),
                      );
                    },
                    child: const Text('Submit a Store Location'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to EditLocationPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditLocationPage()),
                      );
                    },
                    child: const Text('Edit a Store Location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Material3BottomNav(),
    );
  }
}
