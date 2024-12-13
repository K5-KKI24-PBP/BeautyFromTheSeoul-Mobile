import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/models/review.dart';

class ProductCard extends StatelessWidget {
  final Products product;
  final bool isAdmin;
  List<Review> reviews = [];

  ProductCard({
    Key? key,
    required this.product,
    required this.isAdmin,
  }) : super(key: key);

  Future<void> _fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/get_review/'),
      );
      if (response.statusCode == 200) {
        final List<Review> allReviews = reviewFromJson(response.body);
        reviews = allReviews.where((review) => review.fields.product == product.pk).toList();
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  double _calculateAverageRating() {
    if (reviews.isEmpty) return 0;
    int sum = reviews.fold(0, (prev, review) => prev + review.fields.rating);
    return sum / reviews.length;
  }

  void _showReviewDialog(BuildContext context) {
    double rating = 0;
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Review ${product.fields.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 30,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                rating = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Write your review...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (rating == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rate the product!')),
                );
                return;
              }
              if (commentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Leave a comment!')),
                );
                return;
              }

              try {
                final productId = product.pk;

                final response = await http.post(
                  Uri.parse('http://beauty-from-the-seoul.vercel.app/catalogue/review_flutter/$productId/'),
                  body: jsonEncode({
                    'user': 1,
                    'rating': rating.toInt(),
                    'comment': commentController.text,
                  }),
                  headers: {'Content-Type': 'application/json'},
                );
              
                // Parse response body
                final responseData = jsonDecode(response.body);
                final message = responseData['message'] ?? 'Unknown error occurred';
              
                if (response.statusCode == 201) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Color(0xFF071a58),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Color(0xFFAE0000),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Network error: ${e.toString()}'),
                    backgroundColor: Color(0xFFAE0000),
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.rate_review),
                            onPressed: () => _showReviewDialog(context),
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

  void _showProductDetails(BuildContext context) async {
    await _fetchReviews();
    double avgRating = _calculateAverageRating();
    
    if (!context.mounted) return;
  
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Column(
          children: [
            AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Product Details'),
              backgroundColor: Colors.pink[100],
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rest of your existing product details content
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
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: avgRating,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                          ),
                          const SizedBox(width: 8),
                          Text('(${avgRating.toStringAsFixed(1)})')
                        ],
                      ),
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
                      const SizedBox(height: 16),
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...reviews.map((review) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${review.fields.user}:',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  RatingBarIndicator(
                                    rating: review.fields.rating.toDouble(),
                                    itemBuilder: (context, _) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 16.0,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    review.fields.createdAt.toString().split(' ')[0],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(review.fields.comment),
                            ],
                          ),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}