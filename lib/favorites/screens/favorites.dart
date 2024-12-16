import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;
  List<String> categories = ['Favorites', 'Eye Treatment', 'Mask', 'Moisturizer'];

  @override
  void initState() {
    super.initState();
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    const url = 'http://localhost:8000/favorites/get_favorites/';
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
        final List<dynamic> fetchedFavorites = jsonDecode(response.body);
        setState(() {
          favorites = fetchedFavorites.map((item) => Map<String, dynamic>.from(item)).toList();
          isLoading = false;
        });
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
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Favorite Products'),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
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
                : TabBarView(
                    children: categories.map((category) {
                      // Placeholder: Filter products by category (if backend supports it)
                      final filteredProducts = favorites; // Add category filtering logic here
                      return _buildProductGrid(filteredProducts);
                    }).toList(),
                  ),
      bottomNavigationBar: const Material3BottomNav()
      ),
    );
  }

  Widget _buildProductGrid(List<Map<String, dynamic>> products) {
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(product['image'] ?? ''),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Product Brand
            Text(
              product['brand'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            // Product Name
            Text(
              product['name'] ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            // Price
            Text(
              '\u20A9${product['price']?.toStringAsFixed(2) ?? ''}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}
