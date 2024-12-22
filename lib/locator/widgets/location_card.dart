import 'package:flutter/material.dart';

class LocationCard extends StatelessWidget {
  final Map<String, dynamic> location;
  final bool isStaff;
  final Function(String) onDelete;
  final Function(String) onEdit;

  const LocationCard({
    super.key,
    required this.location,
    required this.isStaff,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12.0)),
              child: Image.network(
                location['storeImage'] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
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
                          location['streetName'] ?? '',
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
            Divider(height: 1.0, color: Colors.grey[300]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Open Google Maps link
                      final gmapsLink = location['gmapsLink'] ?? '';
                      if (gmapsLink.isNotEmpty) {
                        // Use appropriate URL launcher logic
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.map),
                    label: const Text('How Do I Get There?'),
                  ),
                  if (isStaff)
                    ElevatedButton(
                      onPressed: () => onDelete(location['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[100],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Delete'),
                    ),
                  if (isStaff)
                    ElevatedButton(
                      onPressed: () => onEdit(location['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[300],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Edit'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
