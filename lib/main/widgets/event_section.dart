import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/events/screens/event_list.dart';

class PromotionEventSection extends StatelessWidget {
  const PromotionEventSection({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> promotions = [
      {
        "title": "Olive Young Sale",
        "discount": "40%",
        "image": 'assets/images/promo1.png',
      },
      {
        "title": "Kayla's Birthday",
        "discount": "100%",
        "image": 'assets/images/promo2.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "#SpecialForYou",
                  style: TextStyle(
                    fontFamily: 'Laurasia',
                    fontSize: 28,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventPage()),
                    );
                  },
                  child: const Text(
                    "See All Promotion Events",
                    style: TextStyle(
                      fontFamily: 'TT',
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
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promo = promotions[index];
                return _buildPromoCard(context, promo);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(BuildContext context, Map<String, dynamic> promo) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EventPage(),
            settings: const RouteSettings(name: '/event')
            ),
        );
      },
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(left: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
            image: AssetImage(promo['image']),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xff071a58).withOpacity(0.7),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "Limited time!",
                  style: TextStyle(
                    fontFamily: 'TT',
                    color: Color(0xff071a58),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 40,
              child: Text(
                promo['title'],
                style: const TextStyle(
                  fontFamily: 'TT',
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 10,
              child: Row(
                children: [
                  Text(
                    "Up to ${promo['discount']}",
                    style: const TextStyle(
                      fontFamily: 'TT',
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
