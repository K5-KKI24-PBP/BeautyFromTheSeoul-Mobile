import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';
import 'package:flutter/material.dart';
import 'product_reviews.dart';

class ProductDetail extends StatelessWidget {
  final Products product;

  const ProductDetail({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.fields.productName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                product.fields.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.error)),
              ),
              const SizedBox(height: 16),
              Text(
                product.fields.productName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                product.fields.productBrand,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Price: ${product.fields.price}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              ProductReviews(productId: product.pk)
            ],
          ),
        ),
      ),
    );
  }
}
