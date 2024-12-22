import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/locator/screens/locations.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> storeLocations = [
      {
        "district": "Jung",
        "image": 'assets/images/myeongdong.png',
        "borderColor": const Color(0xff9fc6ff),
        "mapsUrl": "https://www.google.com/maps?cid=9929880658946518724",
      },
      {
        "district": "Gangnam",
        "image": 'assets/images/gangnam.png',
        "borderColor": const Color(0xffffc03e),
        "mapsUrl": "https://maps.google.com/?cid=5590760012686468635",
      },
      {
        "district": "Jongno",
        "image": 'assets/images/jongno.png',
        "borderColor": const Color(0xffccc2fe),
        "mapsUrl": "https://maps.google.com/?cid=13851289114136110333",
      },
      {
        "district": "Seocho",
        "image": 'assets/images/seocho.png',
        "borderColor": const Color(0xff9fc6ff),
        "mapsUrl": "https://maps.google.com/?cid=7114928757871534792",
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
                  "Browse Stores Near You",
                  style: TextStyle(
                    fontFamily: 'Laurasia',
                    fontSize: 28,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocatorPage(),
                        settings: const RouteSettings(name: '/locator'),
                      ),
                    );
                  },
                  child: const Text(
                    "See All",
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
                  context,
                  store['district']!,
                  store['image']!,
                  store['borderColor']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    String district,
    String imagePath,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocatorPage(initialDistrict: district),
            settings: const RouteSettings(name: '/locator'),
          ),
        );
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
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xff071a58).withOpacity(0.5),  
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ),
            
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                alignment: Alignment.center,
                child: Text(
                  district,
                  style: const TextStyle(
                    fontFamily: 'Laurasia',
                    fontSize: 18,
                    color: Colors.white,
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
