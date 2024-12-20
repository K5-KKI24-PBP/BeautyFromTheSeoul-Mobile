import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/widgets/product_detail.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Products> favorites = [];
  List<String> selectedProducts = []; // Track selected products
  bool isLoading = true;
  bool isEditMode = false; // Toggle for edit mode
  List<String> categories = ['Favorites'];
  String selectedSortOption = 'Most Oldest';

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    const url = 'https://beauty-from-the-seoul.vercel.app/favorites/get_favorites/';
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      print('User ID not set');
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('favorite_products')) {
          final List<dynamic> fetchedFavorites = responseData['favorite_products'];
          setState(() {
            favorites = fetchedFavorites
                .map<Products>((item) => Products.fromJson(item))
                .toList();
            categories = [
              'Favorites',
              ...favorites.map((product) => product.fields.productType).toSet(),
            ];
            isLoading = false;
          });
        } else {
          print('Favorite products not found in response');
          setState(() => isLoading = false);
        }
      } else {
        print('Failed to fetch favorites: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching favorites: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteFavorite(String productId) async {
    const url = 'https://beauty-from-the-seoul.vercel.app/favorites/delete_favorite/';
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    try {
      // Send a DELETE request with the product ID
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_id': productId,
          'user_id' : userId
          }),
      );

      if (response.statusCode == 200) {
        print('Product $productId deleted successfully');
      } else {
        print('Failed to delete product $productId: ${response.body}');
      }
    } catch (e) {
      print('Error deleting product $productId: $e');
    }
  }

  void toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
      selectedProducts.clear(); // Clear selection when toggling edit mode
    });
  }

  void toggleProductSelection(String productId) {
    setState(() {
      if (selectedProducts.contains(productId)) {
        selectedProducts.remove(productId);
      } else {
        selectedProducts.add(productId);
      }
    });
  }

  Future<void> deleteSelectedProducts() async {
    setState(() {
      isLoading = true; // Show loading spinner while deleting
    });

    try {
      // Loop through each selected product and delete it
      for (var productId in selectedProducts) {
        await deleteFavorite(productId); // Call the delete function for each selected product
      }

      // After deletion, update the UI to remove the products from the favorites list
      setState(() {
        // Remove the deleted products from the local favorites list
        favorites.removeWhere((product) => selectedProducts.contains(product.pk));
        selectedProducts.clear();
        toggleEditMode(); // Exit edit mode after deletion
      });
    } catch (e) {
      print('Error deleting selected products: $e');
    } finally {
      setState(() {
        isLoading = false; // Hide loading spinner after operation completes
      });
    }
  }

  void _onSortOptionChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      selectedSortOption = newValue;

      if (selectedSortOption == 'Most Recent') {
        // Reverse the list to show the most recent first
        favorites = List.from(favorites.reversed);
      } else if (selectedSortOption == 'Most Oldest') {
        // Reverse the list again to restore the original order
       favorites = List.from(favorites);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobileView = MediaQuery.of(context).size.width < 600;

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Favorite Products'),
          bottom: TabBar(
            isScrollable: isMobileView,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 3.0, color: Colors.black),
              insets: EdgeInsets.symmetric(horizontal: 18.0),
            ),
            tabs: categories.map((category) => Tab(text: category)).toList(),
          ),
        ),
        body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? const Center(
                  child: Text(
                    "No favorites yet!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${favorites.length} items',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            DropdownButton<String>(
                              value: selectedSortOption,
                              onChanged: _onSortOptionChanged,
                              style: const TextStyle(
                                fontSize: 12, // Set the font size
                                color: Colors.black, // Ensure text color remains black
                              ),
                              focusColor: Colors.transparent, // Remove gray highlight on focus
                              dropdownColor: Colors.white, // Set the dropdown menu background color
                              items: <String>['Most Oldest', 'Most Recent']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 12), // Set the desired font size here
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 220),
                            TextButton(
                              onPressed: toggleEditMode,
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF071a58),
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              ),
                              child: Text(
                                isEditMode ? 'Done' : 'Edit',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isEditMode)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: deleteSelectedProducts,
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      Expanded(
                        child: TabBarView(
                          children: categories.map((category) {
                            if (category == 'Favorites') {
                              return _buildProductGrid(favorites);
                            } else {
                              final filteredProducts = favorites
                                  .where((product) => product.fields.productType == category)
                                  .toList();
                              return _buildProductGrid(filteredProducts);
                            }
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
        bottomNavigationBar: const Material3BottomNav(),
      ),
    );
  }

  Widget _buildProductGrid(List<Products> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 products per row
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
        childAspectRatio: 0.5, // Adjust height-to-width ratio
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final isSelected = selectedProducts.contains(product.pk);

        return GestureDetector(
          onTap: () {
            if (isEditMode) {
              // Toggle selection in edit mode
              toggleProductSelection(product.pk);
            } else {
              // Navigate to ProductDetail page when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetail(product: product),
                ),
              );
            }
          },
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(product.fields.image),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product Brand
                  Text(
                    product.fields.productBrand,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  // Product Name
                  Text(
                    product.fields.productName,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  // Price
                  Text(
                    '\u20A9${product.fields.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (isEditMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      toggleProductSelection(product.pk);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
