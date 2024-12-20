import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';

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
        title: Text('Store Locator'), // Add your desired title here
      ),
      body: Center(
        child: Text('Content goes here'), // Placeholder for your content
      ),
      bottomNavigationBar: const Material3BottomNav(),
    );
  }
}
