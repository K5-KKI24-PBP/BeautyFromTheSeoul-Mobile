import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/screens/catalogue.dart';

class SkinConcernSection extends StatelessWidget {
  const SkinConcernSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> concerns = [
      {
        "title": "Dark Circles",
        "type": "Eye Treatment",
        "description": "Brighten your under-eye area with our targeted treatments.",
        "color": const Color(0xff9fc6ff),
        "image": 'images/dark_circles.png',
      },
      {
        "title": "Acne",
        "type": "Other Spot Treatments",
        "description": "Fight breakouts effectively with our specially formulated solutions for clearer skin.",
        "color": const Color(0xffffc03e),
        "image": 'images/acne.png',
      },
      {
        "title": "Dry Lips",
        "type": "Lip Treatment",
        "description": "Deeply nourish and hydrate your lips to restore its natural moisture balance.",
        "color": const Color(0xffccc2fe),
        "image": 'images/dry_lips.png',
      },
    ];

    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = screenHeight * 0.4;
    double cardWidth = cardHeight * 1.2;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                "I'M STRUGGLING WITH...",
                style: TextStyle(
                  fontFamily: 'Laurasia',
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                "We understand the struggles. Discover effective solutions for your skin concerns!",
                style: TextStyle(
                  fontFamily: 'TT',
                  fontSize: 16,
                  color: Color(0xff071a58),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: concerns.map((concern) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CataloguePage(
                          filterProductType: concern['type'], 
                        ),
                      ),
                    );
                  },
                  child: _buildConcernCard(
                    concern['title']!,
                    concern['type']!,
                    concern['description']!,
                    concern['color']!,
                    concern['image']!,
                    cardWidth,
                    cardHeight,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConcernCard(String title, String type, String description, Color color, String imagePath, double width, double height) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            child: Image.asset(
              imagePath,
              height: height * 0.6,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Laurasia',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'TT',
                    fontSize: 14,
                    color: Color(0xff071a58),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
