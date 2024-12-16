import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // Controllers for input fields
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productBrandController = TextEditingController();
  final TextEditingController productTypeController = TextEditingController();
  final TextEditingController productDescriptionController =
      TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  // Loading state to manage submission button
  bool isSubmitting = false;

  // Function to send API request
  Future<void> addProduct() async {
    // Check if any field is empty
    if (productNameController.text.isEmpty ||
        productBrandController.text.isEmpty ||
        productTypeController.text.isEmpty ||
        productDescriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        imageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill out all fields!')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // API endpoint URL (replace with your actual backend URL)
      final response = await http.post(
        Uri.parse(
            'https://beauty-from-the-seoul.vercel.app/catalogue/add_product_flutter/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': imageController.text,
          'product_name': productNameController.text,
          'product_brand': productBrandController.text,
          'product_type': productTypeController.text,
          'product_description': productDescriptionController.text,
          'price': priceController.text,
        }),
      );

      // Check response from server
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added successfully!')),
        );
        Navigator.pop(context); // Close the page on success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Product Name
            TextField(
              controller: productNameController,
              decoration: InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Product Brand
            TextField(
              controller: productBrandController,
              decoration: InputDecoration(
                labelText: 'Product Brand',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Product Type
            TextField(
              controller: productTypeController,
              decoration: InputDecoration(
                labelText: 'Product Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Product Description
            TextField(
              controller: productDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Product Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Price
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),

            // Image URL
            TextField(
              controller: imageController,
              decoration: InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: isSubmitting ? null : addProduct,
              child: isSubmitting
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('Add Product'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up controllers
    productNameController.dispose();
    productBrandController.dispose();
    productTypeController.dispose();
    productDescriptionController.dispose();
    priceController.dispose();
    imageController.dispose();
    super.dispose();
  }
}
