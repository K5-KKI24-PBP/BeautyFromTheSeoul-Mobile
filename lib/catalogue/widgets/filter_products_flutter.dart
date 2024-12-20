import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FilterProductsWidget extends StatefulWidget {
  final Function(String?, String?, String?) onFilterApply;

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
  String? selectedSortBy;

  List<String> brands = [];
  List<String> productTypes = [];
  List<String> sortByOptions = ['Name', 'Price Ascending', 'Price Descending'];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchFilterData();
  }

  // Fetch brands and product types from the server
  Future<void> fetchFilterData() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://beauty-from-the-seoul.vercel.app/catalogue/filter_products_flutter/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // Send any required fields.
          // Example: If the API expects some data, send it here.
          "param1": "value1",
          "param2": "value2",
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          brands = List<String>.from(data['brands'] ?? []);
          productTypes = List<String>.from(data['product_types'] ?? []);
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
                    },
                    items: productTypes
                        .map<DropdownMenuItem<String>>((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  const Text('Sort By:'),
                  DropdownButton<String>(
                    value: selectedSortBy,
                    hint: const Text('-- Select Sort Option --'),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSortBy = newValue;
                      });
                    },
                    items: sortByOptions
                        .map<DropdownMenuItem<String>>((String sort) {
                      return DropdownMenuItem<String>(
                        value: sort,
                        child: Text(sort),
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
                selectedBrand, selectedProductType, selectedSortBy);
            Navigator.pop(context); // Close the modal
          },
          child: const Text('Apply Filter'),
        ),
      ],
    );
  }
}
