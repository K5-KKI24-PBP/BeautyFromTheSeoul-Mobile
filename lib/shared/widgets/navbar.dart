import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/main/screens/menu.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/screens/catalogue.dart';
import 'package:beauty_from_the_seoul_mobile/events/screens/event_list.dart';

class Material3BottomNav extends StatefulWidget {
  final bool showNavBar; // New parameter to control visibility

  const Material3BottomNav({super.key, this.showNavBar = true});

  @override
  State<Material3BottomNav> createState() => _Material3BottomNavState();
}

class _Material3BottomNavState extends State<Material3BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CustomerMenu(),
    const CataloguePage(),
    const EventPage(),
  ];

  @override
  Widget build(BuildContext context) {
    if (!widget.showNavBar) {
      return const SizedBox(); // Return empty box if navbar is not needed
    }

    return NavigationBar(
      animationDuration: const Duration(milliseconds: 500),
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => _pages[index]),
        );
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.book_outlined),
          selectedIcon: Icon(Icons.book_rounded),
          label: 'Catalogue',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          selectedIcon: Icon(Icons.event),
          label: 'Events',
        ),
      ],
      indicatorColor: Colors.blue,
    );
  }
}
