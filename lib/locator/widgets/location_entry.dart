import 'package:flutter/material.dart';

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
  final TextEditingController _imageLinkController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with submission
      print('Store Name: ${_storeNameController.text}');
      print('Street Name: ${_streetNameController.text}');
      print('District: ${_districtController.text}');
      print('Google Maps Link: ${_gmapsLinkController.text}');
      print('Image Link: ${_imageLinkController.text}');

      // Add logic to send data to the server or database
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit a Store Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16.0),
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
                const SizedBox(height: 16.0),
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
                const SizedBox(height: 16.0),
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
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _imageLinkController,
                  decoration: const InputDecoration(labelText: 'Image Link'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the image link';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
