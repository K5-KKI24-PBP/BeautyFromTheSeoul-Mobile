import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditLocationPage extends StatefulWidget {
  final String id; // Add location ID
  final String storeName;
  final String streetName;
  final String district;
  final String gmapsLink;
  final String storeImage;
  final Function onSave;

  const EditLocationPage({
    super.key,
    required this.id, // Require location ID
    required this.storeName,
    required this.streetName,
    required this.district,
    required this.gmapsLink,
    required this.storeImage,
    required this.onSave, 
  });

  @override
  State<EditLocationPage> createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  late TextEditingController _storeNameController;
  late TextEditingController _streetNameController;
  late TextEditingController _districtController;
  late TextEditingController _gmapsLinkController;
  late TextEditingController _storeImageController;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController(text: widget.storeName);
    _streetNameController = TextEditingController(text: widget.streetName);
    _districtController = TextEditingController(text: widget.district);
    _gmapsLinkController = TextEditingController(text: widget.gmapsLink);
    _storeImageController = TextEditingController(text: widget.storeImage);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _streetNameController.dispose();
    _districtController.dispose();
    _gmapsLinkController.dispose();
    _storeImageController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final url = 'https://beauty-from-the-seoul.vercel.app/store-locator/edit_location_flutter/${widget.id}/';
    final body = {
      'store_name': _storeNameController.text,
      'street_name': _streetNameController.text,
      'district': _districtController.text,
      'gmaps_link': _gmapsLinkController.text,
      'store_image': _storeImageController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Successful update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully!')),
        );
        widget.onSave();
        Navigator.pop(context, body); // Return updated data
      } else {
        // Failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update location: ${response.body}')),
        );
      }
    } catch (e) {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Store Location',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                labelText: 'Store Name',
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _streetNameController,
              decoration: const InputDecoration(
                labelText: 'Street Name',
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _districtController,
              decoration: const InputDecoration(
                labelText: 'District',
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _gmapsLinkController,
              decoration: const InputDecoration(
                labelText: 'Google Maps Link',
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _storeImageController,
              decoration: const InputDecoration(
                labelText: 'Store Image URL',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
