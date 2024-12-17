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
  bool isLoading = true;
  List<String> categories = ['Favorites'];

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
        // Decode the response as a map
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if 'favorite_products' exists in the response
        if (responseData.containsKey('favorite_products')) {
          final List<dynamic> fetchedFavorites = responseData['favorite_products'];
            setState(() {
              // Convert the fetched favorites into a List<Products>
            favorites = fetchedFavorites.map<Products>((item) => Products.fromJson(item)).toList();

            // Extract unique categories from the favorite products
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

  @override
  Widget build(BuildContext context) {
    final isMobileView = MediaQuery.of(context).size.width < 600; // Adjust the width threshold for mobile/tablet

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Favorite Products'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50), // Adjust the height as needed
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16), // Add space to the left and right
                child: TabBar(
                  isScrollable: isMobileView, // Scrollable tabs for mobile view
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  tabs: categories.map((category) => Tab(text: category)).toList(),
                ),
              ),
            ),
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
              : TabBarView(
                  children: categories.map((category) {
                    if (category == 'Favorites') {
                      // Show all products in the "Favorites" tab
                      return _buildProductGrid(favorites);
                    } else {
                      // Filter products by category
                      final filteredProducts = favorites
                          .where((product) => product.fields.productType == category)
                          .toList();
                      return _buildProductGrid(filteredProducts);
                    }
                  }).toList(),
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
        return GestureDetector(
          onTap: () {
            // Navigate to ProductDetail page when tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetail(product: product),
              ),
            );
          },
          child: Column(
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
        );
      },
    );
  }
}
