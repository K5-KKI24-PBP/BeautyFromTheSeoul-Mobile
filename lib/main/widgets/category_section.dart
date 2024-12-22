import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/screens/catalogue.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categories = [
      {"title": "Cleanser", "color": const Color(0xffffc03e), "image": 'assets/images/cleanser.png'},
      {"title": "Moisturizer", "color": const Color(0xff9fc6ff), "image": 'assets/images/moisturizer.png'},
      {"title": "Serum", "color": const Color(0xffccc2fe), "image": 'assets/images/serum.png'},
      {"title": "Essence", "color": const Color(0xffe1dcca), "image": 'assets/images/essence.png'},
    ];

    double screenHeight = MediaQuery.of(context).size.height;
    double cardHeight = screenHeight * 0.4;  
    double cardWidth = cardHeight * 0.6;  

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                "I'M LOOKING FOR A...",
                style: TextStyle(
                  fontFamily: 'Laurasia',
                  fontSize: 30,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CataloguePage(
                          filterProductType: category['title'],  
                        ),
                        settings: const RouteSettings(name: '/catalogue')
                      ),
                    );
                  },
                  child: _buildCategoryCard(
                    category['title']!,
                    category['image']!,
                    category['color']!,
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

  Widget _buildCategoryCard(String title, String imagePath, Color color, double width, double height) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: height * 0.20,
            alignment: Alignment.center,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Laurasia',
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16.0)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
