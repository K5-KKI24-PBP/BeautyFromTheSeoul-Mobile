import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FilterProductsWidget extends StatefulWidget {
  final Function(String?, String?) onFilterApply;

  const FilterProductsWidget({
    super.key,
    required this.onFilterApply,
  });

  @override
  _FilterProductsWidgetState createState() => _FilterProductsWidgetState();
}

class _FilterProductsWidgetState extends State<FilterProductsWidget> {
  String? selectedBrand;
  String? selectedProductType;

  List<String> brands = [];
  List<String> productTypes = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchFilterData(); // Load initial filter data
  }

  // Fetch brands and product types from the server
  Future<void> fetchFilterData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://127.0.0.1:8000/catalogue/filter_products_flutter/'
          '?product_brand=${selectedBrand ?? ""}'
          '&product_type=${selectedProductType ?? ""}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Here you should fill the brands and product types as needed
          // assuming the API sends them in the response.
          brands = List<String>.from(data['brands'] ?? []); // Update brands
          productTypes = List<String>.from(
              data['product_types'] ?? []); // Update product types
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load filter data';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        error = 'Network error occurred';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Products'),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (error != null) ...[
                    Text(error!, style: TextStyle(color: Colors.red)),
                    SizedBox(height: 8),
                  ],
                  const Text('Select Brand:'),
                  DropdownButton<String>(
                    value: selectedBrand,
                    hint: const Text('-- Select Brand --'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBrand = newValue;
                      });
                      fetchFilterData(); // Reload filters based on new selection
                    },
                    items: brands.map<DropdownMenuItem<String>>((String brand) {
                      return DropdownMenuItem<String>(
                        value: brand,
                        child: Text(brand),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  const Text('Select Product Type:'),
                  DropdownButton<String>(
                    value: selectedProductType,
                    hint: const Text('-- Select Product Type --'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProductType = newValue;
                      });
                      fetchFilterData(); // Reload filters based on new selection
                    },
                    items: productTypes
                        .map<DropdownMenuItem<String>>((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the modal without applying filter
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFilterApply(
                selectedBrand ?? '', // Brand (empty string if not selected)
                selectedProductType ??
                    ''); // Product Type (empty string if not selected)
            Navigator.pop(context); // Close the modal after applying filter
          },
          child: const Text('Apply Filter'),
        ),
      ],
    );
  }
}
