import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/screens/catalogue.dart';

class BrandSection extends StatelessWidget {
  const BrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> brands = [
      {
        "name": "Beauty of Joseon",
        "image": 'images/joseon.png',
      },
      {
        "name": "Isntree",
        "image": 'images/isntree.png',
      },
      {
        "name": "Klairs",
        "image": 'images/klairs.png',
      },
      {
        "name": "Then I Met You",
        "image": 'images/then.png',
      },
      {
        "name": "Benton",
        "image": 'images/benton.png',
      },
      {
        "name": "Saturday Skin",
        "image": 'images/saturday.png',
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
          // border: Border.all(color: const Color(0xff071a58), width: 4),
          image: DecorationImage(
            image: AssetImage(brand['image']!),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
