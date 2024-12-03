import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final String?  name;  // Can be null
  final String? description;  // Can be null
  final DateTime startDate;  // Assuming date fields are always present
  final DateTime endDate;  // Assuming date fields are always present
  final String? location;  // Can be null
  final String? promotionType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    Key? key,
    required this. name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.promotionType,
    required this.location,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 254, 250, 244),
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity, // Ensures the container fills the card width
            decoration: const BoxDecoration(
              color: Color(0xFF071a58), // Blue background color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), 
                topRight: Radius.circular(8)
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10), // Adjust padding as needed
            child: Text(
              '$name in $location', // Dynamically replace with event name and location
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24, // Adjust font size as needed
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text color
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description?? 'No description available',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$startDate - $endDate',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 203, 68, 74), 
                      borderRadius: BorderRadius.circular(12),
                    ),                  
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), 
                  child: Text(
                    promotionType?? 'No promotion type available',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: onEdit,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black, backgroundColor: const Color.fromARGB(255, 245, 195, 88),
                      ),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onDelete,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black, backgroundColor: const Color.fromARGB(255, 202, 194,249),
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
