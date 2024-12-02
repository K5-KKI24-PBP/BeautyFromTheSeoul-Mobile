import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';

class CataloguePage extends StatefulWidget {
  final bool isAdmin;
  const CataloguePage({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  _CataloguePageState createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  List<Products> products = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProducts();
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
        title: const Text('Beauty from the Seoul'),
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
            isAdmin: widget.isAdmin,
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Products product;
  final bool isAdmin;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _showProductDetails(context),
              child: Image.network(
                product.fields.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error));
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.fields.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    product.fields.productBrand,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.fields.price}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        color: Colors.red,
                        onPressed: () {
                          // Implement favorite toggle
                        },
                      ),
                    ],
                  ),
                  if (isAdmin)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Implement edit
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            // Implement delete
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.fields.productName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(product.fields.productBrand),
            const SizedBox(height: 8),
            Text(product.fields.productDescription),
            const SizedBox(height: 8),
            Text(
              '${product.fields.price}',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}