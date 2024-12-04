import 'package:beauty_from_the_seoul_mobile/shared/widgets/persistent_bottom_bar_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/persistent_bottom_bar_scaffold.dart';
import 'package:beauty_from_the_seoul_mobile/main/screens/menu.dart'; 
import 'package:beauty_from_the_seoul_mobile/catalogue/screens/catalogue.dart'; 
import 'package:beauty_from_the_seoul_mobile/events/screens/event_list.dart'; 

class HomePage extends StatelessWidget {
  final _tab1navigatorKey = GlobalKey<NavigatorState>();
  final _tab2navigatorKey = GlobalKey<NavigatorState>();
  final _tab3navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PersistentBottomBarScaffold(
      items: [
        PersistentTabItem(
          tab: const CustomerMenu(), // Home page
          icon: Icons.home,
          title: 'Home',
          navigatorkey: _tab1navigatorKey,
        ),
        PersistentTabItem(
          tab: const CataloguePage(), // Product list page
          icon: Icons.shopping_cart,
          title: 'Catalogue',
          navigatorkey: _tab2navigatorKey,
        ),
        PersistentTabItem(
          tab: const EventList(), // Events page
          icon: Icons.event,
          title: 'Events',
          navigatorkey: _tab3navigatorKey,
        ),
      ],
    );
  }
}

class CustomerMenu extends StatelessWidget {
  const CustomerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Home Page!'),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Page1('Home')));
                },
                child: const Text('Go to Page1'))
          ],
        ),
      ),
    );
  }
}

class CataloguePage extends StatelessWidget {
  const CataloguePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catalogue')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Catalogue Page!'),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Page2('Catalogue')));
                },
                child: const Text('Go to Page2'))
          ],
        ),
      ),
    );
  }
}

class EventList extends StatelessWidget {
  const EventList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the Events Page!'),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const Page2('Events')));
                },
                child: const Text('Go to Page2'))
          ],
        ),
      ),
    );
  }
}

class Page1 extends StatelessWidget {
  final String inTab;
  const Page1(this.inTab);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 1')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('In $inTab - Page 1'),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Page2(inTab)));
                },
                child: const Text('Go to Page2'))
          ],
        ),
      ),
    );
  }
}


class Page2 extends StatelessWidget {
  final String inTab;

  const Page2(this.inTab);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 2')),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('in $inTab Page 2'),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Page3(inTab)));
                },
                child: Text('Go to page3'))
          ],
        ),
      ),
    );
  }
}

class Page3 extends StatelessWidget {
  final String inTab;

  const Page3(this.inTab);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page 3')),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('in $inTab Page 3'),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Go back'))
          ],
        ),
      ),
    );
  }
}