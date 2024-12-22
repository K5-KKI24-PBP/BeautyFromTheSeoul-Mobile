import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/main/screens/menu.dart';
import 'package:beauty_from_the_seoul_mobile/catalogue/screens/catalogue.dart';
import 'package:beauty_from_the_seoul_mobile/events/screens/event_list.dart';
import 'package:beauty_from_the_seoul_mobile/favorites/screens/favorites.dart';
import 'package:beauty_from_the_seoul_mobile/locator/screens/locations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Material3BottomNav extends StatefulWidget {
  final bool showNavBar; // New parameter to control visibility

  const Material3BottomNav({super.key, this.showNavBar = true});

  @override
  State<Material3BottomNav> createState() => _Material3BottomNavState();
}

class _Material3BottomNavState extends State<Material3BottomNav> {
  int _selectedIndex = 0;
  bool isStaff = false;  

  List<Widget> _pages = []; 

  @override
  void initState() {
    super.initState();
    _initializeUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndexBasedOnCurrentRoute();
    });
  }

  Future<void> _initializeUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isStaff = prefs.getBool('isStaff') ?? false;
      _pages = [
        isStaff ? const AdminMenu() : const CustomerMenu(), 
        const CataloguePage(),
        const EventPage(),
        const LocatorPage(),
        const FavoritePage(),
      ];
    });
  }

  void _updateIndexBasedOnCurrentRoute() {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != null) {
      if (currentRoute.contains('catalogue')) {
        setState(() => _selectedIndex = 1);
      } else if (currentRoute.contains('event')) {
        setState(() => _selectedIndex = 2);
      } else if (currentRoute.contains('locator')) {
        setState(() => _selectedIndex = 3);
      } else if (currentRoute.contains('favorites')) {
        setState(() => _selectedIndex = 4);
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return NavigationBar(
      animationDuration: const Duration(milliseconds: 500),
      selectedIndex: _selectedIndex,
      backgroundColor: const Color(0xFF071a58),
      indicatorColor: Colors.white,
      labelBehavior: isSmallScreen 
          ? NavigationDestinationLabelBehavior.onlyShowSelected 
          : NavigationDestinationLabelBehavior.alwaysShow,
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
                  : index == 3
                    ? '/locator'
                    : index == 4
                      ? '/favorites'
                      : '/home',
            ),
          ),
        );
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, 
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
          selectedIcon: Icon(Icons.home_rounded, 
            color: const Color(0xFF071a58),
            size: isSmallScreen ? 20 : 24,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined, 
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
          selectedIcon: Icon(Icons.shopping_bag, 
            color: const Color(0xFF071a58),
            size: isSmallScreen ? 20 : 24,
          ),
          label: 'Catalogue',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_outlined, 
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
          selectedIcon: Icon(Icons.event, 
            color: const Color(0xFF071a58),
            size: isSmallScreen ? 20 : 24,
          ),
          label: 'Events',
        ),
        NavigationDestination(
          icon: Icon(Icons.map, 
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
          selectedIcon: Icon(Icons.map, 
            color: const Color(0xFF071a58),
            size: isSmallScreen ? 20 : 24,
          ),
          label: 'Locator',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border, 
            color: Colors.white,
            size: isSmallScreen ? 20 : 24,
          ),
          selectedIcon: Icon(Icons.favorite, 
            color: const Color(0xFF071a58),
            size: isSmallScreen ? 20 : 24,
          ),
          label: 'Favorites',
        ),
      ],
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      height: isSmallScreen ? 55 : 65,
      elevation: 0,
    );
  }
}