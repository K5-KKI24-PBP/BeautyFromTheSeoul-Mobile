import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:beauty_from_the_seoul_mobile/locator/screens/locations.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> storeLocations = [
      {
        "name": "Olive Young",
        "image": 'images/store1.png',
        "borderColor": const Color(0xff9fc6ff),
        "mapsUrl": "https://www.google.com/maps?cid=9929880658946518724",
      },
      {
        "name": "La Nueva",
        "image": 'images/store_lanueva.png',
        "borderColor": const Color(0xffffc03e),
        "mapsUrl": "https://maps.app.goo.gl/LaNuevaLocation",
      },
      {
        "name": "Klavuu",
        "image": 'images/store_klavuu.png',
        "borderColor": const Color(0xffccc2fe),
        "mapsUrl": "https://maps.app.goo.gl/KlavuuLocation",
      },
      {
        "name": "All Mask Story",
        "image": 'images/store_allmaskstory.png',
        "borderColor": const Color(0xff9fc6ff),
        "mapsUrl": "https://maps.app.goo.gl/AllMaskStoryLocation",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Stores Near You",
                  style: TextStyle(
                    fontFamily: 'Laurasia',
                    fontSize: 28,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LocatorPage()),
                    );
                  },
                  child: const Text(
                    "Find More Stores",
                    style: TextStyle(
                      color: Color(0xff071a58),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: storeLocations.length,
              itemBuilder: (context, index) {
                final store = storeLocations[index];
                return _buildStoreCard(
                  store['name']!,
                  store['image']!,
                  store['borderColor']!,
                  store['mapsUrl']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(
    String name,
    String imagePath,
    Color borderColor,
    String mapsUrl,
  ) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(mapsUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          throw 'Could not launch $mapsUrl';
        }
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(left: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Black Gradient Overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xff071a58).withOpacity(0.5),  // Darker at bottom
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
