import 'package:beauty_from_the_seoul_mobile/catalogue/models/products.dart';
import 'package:flutter/material.dart';
import '../screens/product_detail.dart';

class ProductCard extends StatelessWidget {
  final Products product;
  final bool isStaff;
  final bool isFavorite; // Track if the product is a favorite
  final VoidCallback onFavoriteToggle; // Callback to handle favorite toggle
  final VoidCallback onDelete; // Callback for delete action
  final VoidCallback onEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.isStaff,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () {
          print(
              'Navigating with product: ${product.fields.productName}, pk: ${product.pk}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetail(product: product),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Image.network(
                  product.fields.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.error)),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.fields.productName,
                      style: const TextStyle(
                        fontFamily: 'Laurasia',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.fields.productBrand,
                      style: const TextStyle(
                        fontFamily: 'TT',
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₩${product.fields.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'TT',
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: onFavoriteToggle,
                        ),
                        if (isStaff)
                          Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: onEdit,
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: onDelete,
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
      ),
    );
  }
}
