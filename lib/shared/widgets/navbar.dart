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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndexBasedOnCurrentRoute();
    });
  }

  void _updateIndexBasedOnCurrentRoute() {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != null) {
      if (currentRoute.contains('catalogue')) {
        setState(() => _selectedIndex = 1);
      } else if (currentRoute.contains('event')) {
        setState(() => _selectedIndex = 2);
      } else {
        setState(() => _selectedIndex = 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showNavBar) {
      return const SizedBox(); // Return empty box if navbar is not needed
    }

    return NavigationBar(
      animationDuration: const Duration(milliseconds: 500),
      selectedIndex: _selectedIndex,
      backgroundColor: const Color(0xFF071a58),
      indicatorColor: Colors.white,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => _pages[index],
            settings: RouteSettings(
              name: index == 1 
                ? '/catalogue' 
                : index == 2 
                  ? '/events' 
                  : '/home'
            ),
          ),
        );
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: Colors.white),
          selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF071a58)),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.book_outlined, color: Colors.white),
          selectedIcon: Icon(Icons.book_rounded, color: Color(0xFF071a58)),
          label: 'Catalogue',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined, color: Colors.white),
          selectedIcon: Icon(Icons.event, color: Color(0xFF071a58)),
          label: 'Events',
        ),
      ],
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      height: 65,
      elevation: 0,
    );
  }
}
