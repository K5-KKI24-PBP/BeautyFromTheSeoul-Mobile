import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final String? name;  // Can be null
  final String? description;  // Can be null
  final DateTime startDate;  // Assuming date fields are always present
  final DateTime endDate;  // Assuming date fields are always present
  final String? location;  // Can be null
  final String? promotionType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isStaff;
  final bool isRsvp; //check if the customer already RSVP
  final VoidCallback onCancelRsvp;
  final VoidCallback onRsvp;

  const EventCard({
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.promotionType,
    required this.location,
    required this.onEdit,
    required this.onDelete,
    required this.isRsvp,
    required this.isStaff,
    required this.onCancelRsvp,
    required this.onRsvp,
  });

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedStartDate = formatter.format(startDate);
    final String formattedEndDate = formatter.format(endDate);

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
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF071a58), 
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), 
                topRight: Radius.circular(8)
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10), 
            child: Text(
              '$name in $location', 
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Laurasia',
                fontSize: 20, 
                color: Colors.white, 
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
                    fontFamily: 'Laurasia',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$formattedStartDate - $formattedEndDate',
                  style: const TextStyle(
                    fontFamily: 'TT',
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
                      fontFamily: 'TT',
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isStaff) ...[
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
                          foregroundColor: Colors.black, backgroundColor: const Color.fromARGB(255, 202, 194, 249),
                        ),
                        child: const Text('Delete'),
                      ),
                    ] else ...[
                      if (isRsvp) ...[
                        ElevatedButton(
                          onPressed: onCancelRsvp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFF071a58),
                            backgroundColor: const Color.fromARGB(255, 254, 250, 244),
                            side: BorderSide(color: const Color(0xFF071a58), width: 2),
                          ),
                          child: const Text('Cancel RSVP', style: TextStyle(fontFamily: 'TT')),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: onRsvp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color.fromARGB(255, 254, 250, 244),
                            backgroundColor: const Color(0xFF071a58),
                          ),
                          child: const Text('RSVP', style: TextStyle(fontFamily: 'TT')),
                        ),
                      ],
                    ],
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
