import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:beauty_from_the_seoul_mobile/authentication/screens/welcome.dart';

final pages = [
  const PageData(
    icon: null,  
    title: null,
    bgColor: Color(0xff071a58), 
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.shopping_bag_rounded,
    title: "Browse Our Curated K-Skincare Products",
    bgColor: Colors.white, 
    textColor: Color(0xff071a58)
  ),
  const PageData(
    icon: Icons.store_mall_directory_rounded,
    title: "Find A Store Near You",
    bgColor: Color(0xff071a58),  
    textColor: Color(0xffffc03e),
  ),
  const PageData(
    icon: Icons.favorite_rounded,
    title: "Favorite Your Wishlist",
    bgColor: Color(0xffffc03e),  
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.event_rounded,
    title: "Book A Promo Event",
    bgColor: Colors.white, 
    textColor: Color(0xff071a58),
  ),
];

class ConcentricAnimationOnboarding extends StatelessWidget {
  const ConcentricAnimationOnboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.08,
        nextButtonBuilder: (context) => Padding(
          padding: const EdgeInsets.only(left: 3), 
          child: Icon(
            Icons.navigate_next,
            size: screenWidth * 0.08,
            
          ),
        ),
        itemCount: pages.length,  
        onFinish: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const WelcomePage(),  
            ),
          );
        },
        itemBuilder: (index) {
          final page = pages[index];

          if (index == 0) {
            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'images/logo2.png',
                    height: 175,
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: _Page(page: page),
          );
        },
      ),
    );
  }
}

class PageData {
  final String? title;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    this.title,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (page.icon != null)  
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.textColor,
            ),
            child: Icon(
              page.icon,
              size: screenHeight * 0.1,
              color: page.bgColor,
            ),
          ),
        if (page.title != null)
          Text(
            page.title ?? "",
            style: TextStyle(
              fontFamily: 'Laurasia',
              color: page.textColor,
              fontSize: screenHeight * 0.035,

            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
