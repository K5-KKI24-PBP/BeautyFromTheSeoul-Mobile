import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:beauty_from_the_seoul_mobile/authentication/screens/login.dart';

class UnauthenticatedMenu extends StatelessWidget {
  const UnauthenticatedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beauty from the Seoul - Guest'),
      ),
      body: const Center(
        child: Text(
          'Welcome, Guest! Please log in to access more features.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class CustomerMenu extends StatelessWidget {
  const CustomerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beauty from the Seoul - Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final request = context.read<CookieRequest>();
              final response = await request.logout(
                "http://localhost:8000/auth/logout-flutter/",
              );

              if (response['status']) {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome, Customer! Enjoy our services.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class AdminMenu extends StatelessWidget {
  const AdminMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beauty from the Seoul - Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final request = context.read<CookieRequest>();
              final response = await request.logout(
                "http://localhost:8000/auth/logout-flutter/",
              );

              if (response['status']) {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome, Admin! Manage the app here.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}