import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/screens/catalogue.dart';

class BrandSection extends StatelessWidget {
  const BrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> brands = [
      {
        "name": "Beauty of Joseon",
        "image": 'assets/images/joseon.png',
      },
      {
        "name": "Isntree",
        "image": 'assets/images/isntree.png',
      },
      {
        "name": "Klairs",
        "image": 'assets/images/klairs.png',
      },
      {
        "name": "Then I Met You",
        "image": 'assets/images/then.png',
      },
      {
        "name": "Benton",
        "image": 'assets/images/benton.png',
      },
      {
        "name": "Saturday Skin",
        "image": 'assets/images/saturday.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Our Selected Brands",
                  style: TextStyle(
                    fontFamily: 'Laurasia',
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                return _buildBrandCard(context, brand);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(BuildContext context, Map<String, String> brand) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CataloguePage(
              filterBrand: brand['name'],
            ),
            settings: const RouteSettings(name: '/catalogue'),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(left: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(70.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(70.0),
          child: Image.asset(
            brand['image']!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
