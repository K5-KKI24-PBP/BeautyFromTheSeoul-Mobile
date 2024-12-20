import 'package:beauty_from_the_seoul_mobile/catalogue/widgets/add_product.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/widgets/product_card.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CataloguePage extends StatefulWidget {
  final bool isStaff;
  const CataloguePage({super.key, this.isStaff = false});

  @override
  _CataloguePageState createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  List<Products> products = [];
  bool isLoading = true;
  String? error;
  bool isStaff = false;
  Set<String> favoriteProductIds = {}; 

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    fetchProducts();
    fetchFavoriteProducts();
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('userRole') ?? '';
    setState(() {
      isStaff = userRole == 'admin';
    });
  }
  
  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://beauty-from-the-seoul.vercel.app/catalogue/get_product/'),
      );

      if (response.statusCode == 200) {
        setState(() {
          products = productsFromJson(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load products';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error occurred';
        isLoading = false;
      });
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/delete_product_flutter/$productId/'));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    } catch (e) {
      print('Error: $e');
      

    }
  }

  /// Fetch favorite product IDs for the current user
  Future<void> fetchFavoriteProducts() async {
    final url = Uri.parse('https://beauty-from-the-seoul.vercel.app/favorites/get_favorites/');
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
        final List<dynamic> favoriteIds = jsonDecode(response.body)['favorite_product_ids'];
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
    final url = Uri.parse('https://beauty-from-the-seoul.vercel.app/favorites/add_favorites_flutter/');

    try { 
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final username = prefs.getString('username'); 
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'product_id': productId,
            'user_id' : userId,
            'username' : username,
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
        title: const Text('Browse Our Extensive Catalogue!'),
        centerTitle: true,
        actions: [
          if (isStaff) // Show Add Product button only for staff
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Product',
              onPressed: () {
                // Navigate to the Add Product Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductPage(),
                  ),
                ).then((_) {
                  // Refresh the product list when returning
                  fetchProducts();
                });
              },
            ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
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
                        deleteProduct(product.pk); // Delete the product
                      }

                    );
                  },
                ),
      bottomNavigationBar: const Material3BottomNav(),
      // Add a FAB for adding products (optional)
      floatingActionButton: isStaff
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductPage(),
                  ),
                ).then((_) {
                  fetchProducts(); // Refresh the products
                });
              },
              tooltip: 'Add Product',
              child: const Icon(Icons.add),
            )
          : null, // Show FAB only for staff
    );
  }
}