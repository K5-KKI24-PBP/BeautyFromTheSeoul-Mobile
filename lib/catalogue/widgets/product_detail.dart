import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/models/review.dart'; 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'product_reviews.dart';

class ProductDetail extends StatefulWidget {  
  final Products product;

  const ProductDetail({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final reviewsKey = GlobalKey<ProductReviewsState>();  
  double averageRating = 0.0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.fields.productName),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.product.fields.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.error)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.fields.productName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.product.fields.productBrand,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ProductReviewsSummary(productId: widget.product.pk),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Price: ₩${widget.product.fields.price.toStringAsFixed(2)}',  
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              ProductReviews(
                key: reviewsKey,
                productId: widget.product.pk,
                onRatingUpdate: (double newRating) {  
                  setState(() {
                    averageRating = newRating;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductReviewsSummary extends StatelessWidget {
  final String productId;

  const ProductReviewsSummary({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _calculateAverageRating(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${snapshot.data!.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<double> _calculateAverageRating() async {
    try {
      final response = await http.get(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/get_review/'),
      );
      if (response.statusCode == 200) {
        final reviews = reviewFromJson(response.body)
            .where((review) => review.fields.product == productId)
            .toList();
            
        if (reviews.isEmpty) return 0;
        final sum = reviews.fold(0, (prev, review) => prev + review.fields.rating);
        return sum / reviews.length;
      }
    } catch (e) {
      print('Error calculating average rating: $e');
    }
    return 0;
  }
}