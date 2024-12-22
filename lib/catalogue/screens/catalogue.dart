import 'package:beauty_from_the_seoul_mobile/catalogue/screens/add_product.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/screens/edit_product.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/widgets/filter_products_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/widgets/product_card.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CataloguePage extends StatefulWidget {
  final bool isStaff;
  final String? filterProductType;

  const CataloguePage({super.key, this.isStaff = false, this.filterProductType});

  @override
  _CataloguePageState createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  List<Products> products = [];
  bool isLoading = true;
  String? error;
  bool isStaff = false;
  Set<String> favoriteProductIds = {};

  String? selectedBrand;
  String? selectedProductType;
  String? selectedSortBy;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    fetchProducts(type: widget.filterProductType);
    // fetchProducts();
    fetchFavoriteProducts();
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('userRole') ?? '';
    setState(() {
      isStaff = userRole == 'admin';
    });
  }

  Future<void> fetchProducts({
    String? brand,
    String? type,
    String? sortBy,
  }) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/get_product/'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        
        // Parse all products first
        List<Products> allProducts = productsFromJson(response.body);
        
        // Apply filters client-side
        List<Products> filteredProducts = allProducts.where((product) {
          bool matchesBrand = brand == null || brand.isEmpty || 
                            product.fields.productBrand.toLowerCase() == brand.toLowerCase();
          bool matchesType = type == null || type.isEmpty || 
                            product.fields.productType.toLowerCase() == type.toLowerCase();
          return matchesBrand && matchesType;
        }).toList();

        print('Total products: ${allProducts.length}');
        print('Filtered products: ${filteredProducts.length}');
        print('Applied filters - Brand: $brand, Type: $type');

        setState(() {
          products = filteredProducts;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching products: $e');
      if (!mounted) return;
      setState(() {
        error = 'Failed to load products: $e';
        isLoading = false;
      });
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(Uri.parse(
          'https://beauty-from-the-seoul.vercel.app/catalogue/delete_product_flutter/$productId/'));
      print('Status Code: ${response.statusCode}');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> confirmDelete(String productId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await deleteProduct(productId);
      await fetchProducts();
    }
  }

  Future<void> fetchFavoriteProducts() async {
    final url = Uri.parse(
        'https://beauty-from-the-seoul.vercel.app/favorites/get_favorites/');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        setState(() {
          error = 'User ID not found.';
          isLoading = false;
        });
        return;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> favoriteIds =
            jsonDecode(response.body)['favorite_product_ids'];
        setState(() {
          favoriteProductIds = favoriteIds.map((id) => id.toString()).toSet();
        });
      } else {
        print('Failed to fetch favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching favorites: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> toggleFavorite(String productId) async {
    final url = Uri.parse(
        'https://beauty-from-the-seoul.vercel.app/favorites/add_favorites_flutter/');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final username = prefs.getString('username');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_id': productId,
          'user_id': userId,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          if (responseData['status'] == 'added') {
            favoriteProductIds.add(productId);
          } else if (responseData['status'] == 'removed') {
            favoriteProductIds.remove(productId);
          }
        });
      } else {
        print('Failed to toggle favorite: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while toggling favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Browse Our Extensive Catalogue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF071a58), // Blue background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
        ),
        actions: [
          if (isStaff) // Show Add Product button only for staff
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white), // Added white color
              tooltip: 'Add Product',
              onPressed: () {
                // Navigate to the Add Product Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddProductPage(),
                  ),
                ).then((_) {
                  // Refresh the product list when returning
                  fetchProducts();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white), // Added white color
            tooltip: 'Filter Products',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => FilterProductsWidget(
                  onFilterApply: (brand, type) {
                    fetchProducts(
                      brand: brand,
                      type: type,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width, // Full screen width
              height: 200, // Adjust height as needed
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/products.png'), // Replace with your image path
                  fit: BoxFit.cover, // Ensures the image fills the container
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Products grid
            GridView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true, // Shrink the GridView to fit content
              physics: const NeverScrollableScrollPhysics(), // Disable GridView's scrolling
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  isStaff: isStaff,
                  isFavorite: favoriteProductIds.contains(product.pk),
                  onFavoriteToggle: () {
                    toggleFavorite(product.pk); // Toggle favorite status
                  },
                  onDelete: () {
                    confirmDelete(product.pk); // Delete the product
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProductForm(productId: product.pk),
                      ),
                    ).then((result) {
                      if (result == true) {
                        fetchProducts(); // Refresh product list after editing
                      }
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Material3BottomNav(),
    );
  }

}
