import 'dart:convert'; // Import this for jsonEncode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocatorEntryPage extends StatefulWidget {
  const LocatorEntryPage({super.key});

  @override
  _LocatorEntryPageState createState() => _LocatorEntryPageState();
}

class _LocatorEntryPageState extends State<LocatorEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _gmapsLinkController = TextEditingController();
  final TextEditingController _storeImageController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:8000/store-locator/create_location_flutter/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'storeName': _storeNameController.text,
            'streetName': _streetNameController.text,
            'district': _districtController.text,
            'gmapsLink': _gmapsLinkController.text,
            'storeImage': _storeImageController.text,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location submitted successfully!')),
          );
          Navigator.pop(context, true); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit location: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit a Store Location')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _storeNameController,
                decoration: const InputDecoration(labelText: 'Store Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the store name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _streetNameController,
                decoration: const InputDecoration(labelText: 'Street Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the street name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: 'District'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the district';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _gmapsLinkController,
                decoration: const InputDecoration(labelText: 'Google Maps Link'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Google Maps link';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _storeImageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
