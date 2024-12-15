import 'dart:convert';
import 'package:beauty_from_the_seoul_mobile/catalogue/models/review.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductReviews extends StatefulWidget {
  final String productId; // Change from int to String

  const ProductReviews({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductReviews> createState() => _ProductReviewsState();
}

class _ProductReviewsState extends State<ProductReviews> {
  List<Review> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://beauty-from-the-seoul.vercel.app/catalogue/get_review/'),
      );
      if (response.statusCode == 200) {
        final allReviews = reviewFromJson(response.body);
        setState(() {
          reviews = allReviews
              .where((review) => review.fields.product == widget.productId)
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitReview(double rating, String comment) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://beauty-from-the-seoul.vercel.app/catalogue/add_review_flutter/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product': widget.productId, // Pass productId as String
          'rating': rating.toInt(),
          'comment': comment,
        }),
      );
      if (response.statusCode == 201) {
        _fetchReviews(); // Refresh reviews on successful submission
      } else {
        print('Failed to submit review');
      }
    } catch (e) {
      print('Error submitting review: $e');
    }
  }

  double _calculateAverageRating() {
    if (reviews.isEmpty) return 0;
    int sum = reviews.fold(0, (prev, review) => prev + review.fields.rating);
    return sum / reviews.length;
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double rating = 0;
        String comment = '';
        return AlertDialog(
          title: const Text('Write a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Comment'),
                onChanged: (value) => comment = value,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (rating > 0 && comment.isNotEmpty) {
                  _submitReview(rating, comment);
                  Navigator.pop(context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else ...[
          Text(
            'Reviews (${reviews.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (reviews.isEmpty)
            const Text('No reviews yet. Be the first to review!')
          else
            ...reviews.map(
              (review) => ListTile(
                leading: Icon(Icons.star, color: Colors.amber),
                title: Text('${review.fields.rating}'),
                subtitle: Text(review.fields.comment),
              ),
            ),
          const SizedBox(height: 16),
        ],
        Center(
          child: ElevatedButton(
            onPressed: _showReviewDialog,
            child: const Text('Write a Review'),
          ),
        ),
      ],
    );
  }
}
