import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationCard extends StatelessWidget {
  final Map<String, dynamic> location;
  final bool isStaff;
  final Function(String) onDelete;
  final Function(String) onEdit;
  final int index;

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
      child: isStaff
          ? GestureDetector(
              onLongPress: () {
                // Show a dialog for edit and delete options
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Choose an action'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Edit Location'),
                          onTap: () {
                            Navigator.of(context).pop();
                            onEdit(location['id']);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('Delete Location'),
                          onTap: () {
                            Navigator.of(context).pop();
                            onDelete(location['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: _buildLocationCard(context, imageUrl, fullStreet),
            )
          : _buildLocationCard(context, imageUrl, fullStreet),
    );
  }

  Widget _buildLocationCard(BuildContext context, String imageUrl, String fullStreet) {
    return Card(
      elevation: 6.0,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
              ],
            ),
          )
        ],
      ),
    );
  }
}
