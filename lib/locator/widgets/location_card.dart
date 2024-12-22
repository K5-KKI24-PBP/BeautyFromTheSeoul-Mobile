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
      height: 100, // Slightly reduced height
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final isSmallScreen = screenWidth < 320; // Added check for very small screens
    
    // Calculate responsive spacing
    final double topSpacing = isLargeScreen ? 16.0 : 12.0;
    final double contentPadding = isLargeScreen ? 12.0 : 8.0;
    final double buttonSpacing = isLargeScreen ? 20.0 : 12.0;

    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: _getBorderColor(index),
          width: 3.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSlide(imageUrl),
          SizedBox(height: topSpacing),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location['storeName'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16.0 : 15.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: isLargeScreen ? 18.0 : 16.0,
                    ),
                    const SizedBox(width: 4.0),
                    Expanded(
                      child: Text(
                        fullStreet,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 13.0 : 12.0,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: buttonSpacing),
                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: isSmallScreen ? 120 : 160,
                      child: ElevatedButton.icon(
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
                          padding: EdgeInsets.symmetric(
                            vertical: isLargeScreen ? 8.0 : 6.0,
                            horizontal: isSmallScreen ? 8.0 : 12.0,
                          ),
                        ),
                        icon: Icon(
                          Icons.map,
                          size: isSmallScreen ? 14.0 : (isLargeScreen ? 18.0 : 16.0),
                        ),
                        label: Text(
                          isSmallScreen ? 'Directions' : 'How Do I Get There?',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11.0 : (isLargeScreen ? 13.0 : 12.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: buttonSpacing / 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
