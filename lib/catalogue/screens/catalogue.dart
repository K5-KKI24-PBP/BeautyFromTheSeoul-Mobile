import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/widgets/product_card.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class CataloguePage extends StatefulWidget {
  final bool isStaff;
  const CataloguePage({Key? key, this.isStaff = false}) : super(key: key);

  @override
  _CataloguePageState createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  List<Products> products = [];
  bool isLoading = true;
  String? error;
  bool isStaff = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    fetchProducts();
  }

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('userRole') ?? '';
    setState(() {
      isStaff = userRole == 'admin';
    });
    print('User role from SharedPreferences: $userRole');
    print('isStaff value: $isStaff');
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/get_product/'),
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Our Extensive Catalogue!'),
        centerTitle: true,
      ),
      body: GridView.builder(
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
          );
        },
      ),
      bottomNavigationBar: const Material3BottomNav(),
    );
  }
}