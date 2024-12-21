import 'package:flutter/material.dart';

class EditLocationPage extends StatelessWidget {
  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController gmapsLinkController = TextEditingController();
  final TextEditingController storeImageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Location',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: storeNameController,
                decoration: const InputDecoration(
                  labelText: 'Store Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: streetNameController,
                decoration: const InputDecoration(
                  labelText: 'Street Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: districtController,
                decoration: const InputDecoration(
                  labelText: 'District',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: gmapsLinkController,
                decoration: const InputDecoration(
                  labelText: 'Google Maps Link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: storeImageController,
                decoration: const InputDecoration(
                  labelText: 'Store Image URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Add functionality to submit the edited location details
                  },
                  child: const Text('Edit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
