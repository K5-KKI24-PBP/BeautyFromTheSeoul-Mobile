import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationCard extends StatelessWidget {
  final Map<String, dynamic> location;
  final bool isStaff;
  final Function(String) onDelete;
  final Function(String) onEdit;
  final int index;  // Add an index parameter to determine border color

  const LocationCard({
    super.key,
    required this.location,
    required this.isStaff,
    required this.onDelete,
    required this.onEdit,
    required this.index,
  });

  Future<void> _launchGmaps(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  String _getFullImageUrl(String path) {
    const String baseUrl = 'https://beauty-from-the-seoul.vercel.app';
    return path.startsWith('http') ? path : '$baseUrl$path';
  }

  Color _getBorderColor(int index) {
    List<Color> borderColors = [
      const Color(0xff9fc6ff),  // Light Blue
      const Color(0xffffc03e),  // Yellow
      const Color(0xffccc2fe),  // Purple
    ];
    return borderColors[index % borderColors.length];
  }

  Widget _buildImageSlide(String imageUrl) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = _getFullImageUrl(location['storeImage'] ?? '');
    final String streetName = location['streetName'] ?? 'Unknown Street';
    final String district = location['district'] ?? 'Unknown District';
    final String fullStreet = '$streetName, $district';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: _getBorderColor(index),  // Apply border color dynamically
            width: 3.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImageSlide(imageUrl),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location['storeName'] ?? '',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 18.0,
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          fullStreet,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            Divider(height: 1.0, color: Colors.grey[300]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final gmapsLink = location['gmapsLink'] ?? '';
                      if (gmapsLink.isNotEmpty) {
                        _launchGmaps(gmapsLink);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google Maps link unavailable')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(45), // Full width button
                    ),
                    icon: const Icon(Icons.map),
                    label: const Text('How Do I Get There?'),
                  ),
                  
                  if (isStaff) ...[
                    const SizedBox(height: 8),  // Spacing between buttons
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => onEdit(location['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[300],
                              foregroundColor: Colors.black,
                              minimumSize: const Size.fromHeight(45),  // Full width button
                            ),
                            child: const Text('Edit'),
                          ),
                        ),
                        const SizedBox(width: 8),  // Spacing between buttons
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => onDelete(location['id']),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[100],
                              foregroundColor: Colors.black,
                              minimumSize: const Size.fromHeight(45),  // Full width button
                            ),
                            child: const Text('Delete'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
