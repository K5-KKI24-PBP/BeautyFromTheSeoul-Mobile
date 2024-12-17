import 'dart:convert';
import 'package:beauty_from_the_seoul_mobile/catalogue/models/review.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewService {
  static Future<bool> deleteReview(int reviewId) async {
    try {
      print('Attempting to delete review with ID: $reviewId');
      final response = await http.delete(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/delete_review_flutter/$reviewId/'),
        headers: {'Content-Type': 'application/json'},
      );
      print('Delete response status: ${response.statusCode}');
      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }
}

class ProductReviews extends StatefulWidget {
  final String productId;
  final Function(double) onRatingUpdate;  

  const ProductReviews({
    super.key, 
    required this.productId,
    required this.onRatingUpdate,  
  });

  @override
  State<ProductReviews> createState() => ProductReviewsState();  
}

class ProductReviewsState extends State<ProductReviews> {  
  List<Review> reviews = [];
  bool isLoading = true;
  bool isStaff = false;  
  bool hasUserReviewed = false;  
  int? currentUserId;  

  @override
  void initState() {
    super.initState();
    _checkStaffStatus();
    _fetchReviews();
  }

  Future<void> _checkStaffStatus() async { 
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isStaff = prefs.getBool('isStaff') ?? false;
      currentUserId = prefs.getInt('userId'); 
    });
  }

  void _checkUserReview() {
    if (currentUserId != null) {
      setState(() {
        hasUserReviewed = reviews.any((review) => 
          review.fields.user == currentUserId && 
          review.fields.product == widget.productId
        );
      });
    }
  }

  void _updateAverageRating() {
    double avgRating = _calculateAverageRating();
    widget.onRatingUpdate(avgRating);
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
          _checkUserReview();  
          _updateAverageRating();
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
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final username = prefs.getString('username');  

      if (userId == null || username == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to submit a review')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/catalogue/review_flutter/${widget.productId}/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user': userId,
          'username': username,  
          'rating': rating.toInt(),
          'comment': comment,
        }),
      );

      final responseData = jsonDecode(response.body);
      final message = responseData['message'] ?? 'Unknown error occurred';

      if (response.statusCode == 201) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: const Color(0xFF071a58)),
        );
        await _fetchReviews();  
        _updateAverageRating(); 
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: const Color(0xFFAE0000)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFAE0000)),
      );
    }
  }

  Future<void> _handleDeleteReview(Review review) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    ) ?? false;

    if (confirmed) {
      final success = await ReviewService.deleteReview(review.pk);
      if (success) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review deleted successfully')),
        );
        await _fetchReviews(); 
        _updateAverageRating();  
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete review'), backgroundColor: Colors.red),
        );
      }
    }
  }

  double _calculateAverageRating() {
    if (reviews.isEmpty) return 0;
    int sum = reviews.fold(0, (prev, review) => prev + review.fields.rating);
    return sum / reviews.length;
  }

  void _showReviewDialog() {
    double rating = 0;
    final commentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Write a Review'),
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
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) => rating = value,
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
            onPressed: () {
              if (rating == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please rate the product')),
                );
                return;
              }
              if (commentController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please write a comment')),
                );
                return;
              }
              _submitReview(rating, commentController.text);
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
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
                leading: const Icon(
                  Icons.person, 
                  color: Color(0xFF071a58)
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.fields.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    RatingBarIndicator(
                      rating: review.fields.rating.toDouble(),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(review.fields.comment),
                ),
                trailing: isStaff ? IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _handleDeleteReview(review),
                ) : null,
              ),
            ),
          const SizedBox(height: 16),
        ],
        if (!hasUserReviewed) 
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
