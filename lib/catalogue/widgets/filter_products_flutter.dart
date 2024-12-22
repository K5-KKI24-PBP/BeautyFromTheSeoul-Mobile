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
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://beauty-from-the-seoul.vercel.app/catalogue/get_product/',  // Changed to product endpoint
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> productsData = jsonDecode(response.body);
        
        // Extract unique brands and types from products
        Set<String> brandSet = {};
        Set<String> typeSet = {};

        for (var product in productsData) {
          if (product['fields'] != null) {
            final fields = product['fields'];
            if (fields['product_brand'] != null) {
              brandSet.add(fields['product_brand']);
            }
            if (fields['product_type'] != null) {
              typeSet.add(fields['product_type']);
            }
          }
        }

        setState(() {
          brands = brandSet.toList()..sort();
          productTypes = typeSet.toList()..sort();

          print('Loaded brands: $brands');
          print('Loaded product types: $productTypes');

          // Clear selections if they're not in the new lists
          if (selectedBrand != null && !brands.contains(selectedBrand)) {
            selectedBrand = null;
          }
          if (selectedProductType != null && !productTypes.contains(selectedProductType)) {
            selectedProductType = null;
          }

          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load filter data: ${response.statusCode}';
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
                    Text(error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                  ],
                  const Text('Select Brand:'),
                  DropdownButton<String>(
                    value: selectedBrand,
                    hint: const Text('-- Select Brand --'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('-- Select Brand --'),
                      ),
                      ...brands.map((String brand) {
                        return DropdownMenuItem<String>(
                          value: brand,
                          child: Text(brand),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedBrand = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Product Type:'),
                  DropdownButton<String>(
                    value: selectedProductType,
                    hint: const Text('-- Select Product Type --'),
                    isExpanded: true,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('-- Select Product Type --'),
                      ),
                      ...productTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProductType = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Only pass non-null values when actually selected
            final brandValue = selectedBrand != null && selectedBrand != '-- Select Brand --' 
                ? selectedBrand 
                : null;
            final typeValue = selectedProductType != null && selectedProductType != '-- Select Product Type --' 
                ? selectedProductType 
                : null;
            
            print('Applying filters - Brand: $brandValue, Type: $typeValue'); // Debug print
            widget.onFilterApply(brandValue, typeValue);
            Navigator.pop(context);
          },
          child: const Text('Apply Filter'),
        ),
      ],
    );
  }
}
