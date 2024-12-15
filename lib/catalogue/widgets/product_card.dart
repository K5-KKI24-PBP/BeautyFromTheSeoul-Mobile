import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/models/review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static Future<bool> deleteReview(int reviewId) async {
    try {
      print('Attempting to delete review with ID: $reviewId'); // Debug print
      final response = await http.delete(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/delete_review_flutter/$reviewId/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('Delete response status: ${response.statusCode}'); 
      print('Delete response body: ${response.body}');  
      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }
}

class ProductCard extends StatefulWidget {
  final Products product;
  final bool isStaff;

  const ProductCard({
    Key? key,
    required this.product,
    required this.isStaff,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  List<Review> reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await http.get(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/get_review/'),
      );
      if (response.statusCode == 200) {
        final List<Review> allReviews = reviewFromJson(response.body);
        setState(() {
          reviews = allReviews.where((review) => review.fields.product == widget.product.pk).toList();
        });
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
        title: Text('Review ${widget.product.fields.productName}'),
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
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt('userId');  // Get stored user ID

                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User ID not found. Please login again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final productId = widget.product.pk;
                final response = await http.post(
                  Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/review_flutter/$productId/'),
                  body: jsonEncode({
                    'user': userId, 
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
                widget.product.fields.image,
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
                    widget.product.fields.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.product.fields.productBrand,
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
                        '${widget.product.fields.price}',
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

    final prefs = await SharedPreferences.getInstance();
    final currentUsername = prefs.getString('username') ?? '';
  
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
                      // Product details section
                      Text(
                        widget.product.fields.productName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.product.fields.productBrand),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: avgRating,
                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 20.0,
                          ),
                          const SizedBox(width: 8),
                          Text('(${avgRating.toStringAsFixed(1)})')
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.product.fields.productDescription),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.product.fields.price}',
                        style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Reviews',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Reviews section
                      ...reviews.map((review) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${review.fields.username}:',  // Add username here
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            RatingBarIndicator(
                                              rating: review.fields.rating.toDouble(),
                                              itemBuilder: (context, _) => 
                                                  const Icon(Icons.star, color: Colors.amber),
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
                                      ],
                                    ),
                                  ),
                                  if (widget.isStaff) ...[
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _handleDeleteReview(context, review),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review.fields.comment,
                                style: const TextStyle(fontSize: 14),
                              ),
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

  Future<void> _handleDeleteReview(BuildContext context, Review review) async {
    print('Delete button pressed for review: ${review.pk}');
    
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
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
      ),
    ) ?? false;

    if (confirmed) {
      try {
        final success = await ReviewService.deleteReview(review.pk);
        if (!context.mounted) return;
        
        if (success) {
          // Close the bottom sheet first
          Navigator.pop(context);
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review deleted successfully')),
          );
          
          // Fetch updated reviews and refresh UI
          await _fetchReviews();
          
          // Show product details again with updated reviews
          _showProductDetails(context);
          
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete review'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}