import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:beauty_from_the_seoul_mobile/main/models/ad_entry.dart';
import 'package:beauty_from_the_seoul_mobile/authentication/screens/login.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:beauty_from_the_seoul_mobile/main/widgets/category_section.dart';
import 'package:beauty_from_the_seoul_mobile/main/widgets/event_section.dart';
import 'package:beauty_from_the_seoul_mobile/main/widgets/concern_section.dart';
import 'package:beauty_from_the_seoul_mobile/main/widgets/location_section.dart';
import 'package:beauty_from_the_seoul_mobile/main/widgets/adsubmit_section.dart';
import 'package:beauty_from_the_seoul_mobile/main/widgets/brand_section.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class BaseMenuState<T extends StatefulWidget> extends State<T> {
  List<AdEntry> ads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAds();
  }

  Future<void> fetchAds() async {
    try {
      final response = await http.get(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/ads/'),
      );

      print(response.body);

      if (response.statusCode == 200) {
        setState(() {
          ads = adEntryFromJson(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load ads');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitAd(String brandName, String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/ads/submit/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'brand_name': brandName,
          'image': imageUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad submitted successfully')),
        );
        fetchAds();
      } else {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'] ?? 'Failed to submit ad')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    final request = context.read<CookieRequest>();
    final response = await request.logout(
      "https://beauty-from-the-seoul.vercel.app/auth/logout-flutter/",
    );

    if (response['status']) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logout failed!")),
      );
    }
  }
}

class AdCarousel extends StatelessWidget {
  final List<AdEntry> ads;
  final double screenWidth;
  final bool isAdmin;
  final Function(AdEntry)? onLongPress;

  const AdCarousel({
    required this.ads,
    required this.screenWidth,
    this.isAdmin = false,
    this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        _buildImageSlide('assets/images/logo.png', screenWidth),  
        ...ads.map(
          (ad) => GestureDetector(
            onLongPress: isAdmin ? () => onLongPress!(ad) : null,
            child: _buildImageSlide(ad.fields.image, screenWidth),
          ),
        ),
      ],
      options: CarouselOptions(
        height: 300,
        viewportFraction: 1.0,
        autoPlay: true,
        enlargeCenterPage: false,
      ),
    );
  }

  Widget _buildImageSlide(String imageUrl, double width) {
    return Container(
      width: width,
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageUrl.startsWith('http')
              ? NetworkImage(imageUrl)
              : AssetImage(imageUrl) as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

void showAdSubmissionDialog(BuildContext context, Function(String, String) onSubmit) {
  final brandNameController = TextEditingController();
  final imageUrlController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Submit an Ad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: brandNameController,
              decoration: const InputDecoration(labelText: 'Brand Name'),
            ),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSubmit(brandNameController.text, imageUrlController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}


class CustomerMenu extends StatefulWidget {
  const CustomerMenu({super.key});

  @override
  _CustomerMenuState createState() => _CustomerMenuState();
}

class _CustomerMenuState extends BaseMenuState<CustomerMenu> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beauty From The Seoul - Customer',
          style: TextStyle(
            fontFamily: 'Laurasia',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF071a58), 
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),  
          child: Container(
            color: const Color(0xFFfcfaf3),  
            height: 1.0,          
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
            color: Colors.white,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  AdCarousel(
                    ads: ads.where((ad) => ad.fields.isApproved).toList(),
                    screenWidth: screenWidth,
                  ),
                
                  const CategorySection(), 
                  const BrandSection(),
                  const PromotionEventSection(),
                  const SkinConcernSection(),
                  const LocationSection(),
                  AdSubmissionSection(onAdSubmit: (context) {
                    showAdSubmissionDialog(context, submitAd);
                  }),
                ],
              ),
            ),
      bottomNavigationBar: const Material3BottomNav(),
    );
  }
}

class AdminMenu extends StatefulWidget {
  const AdminMenu({super.key});

  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends BaseMenuState<AdminMenu> {
    Future<void> approveAd(String adId) async {
    final response = await http.post(
      Uri.parse('https://beauty-from-the-seoul.vercel.app/ads/approve/$adId/'),
    );

    if (response.statusCode == 200) {
      fetchAds();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to approve ad')),
      );
    }
  }

  Future<void> deleteAd(String adId) async {
    final response = await http.delete(
      Uri.parse('https://beauty-from-the-seoul.vercel.app/ads/delete/$adId/'),
    );

    if (response.statusCode == 200) {
      fetchAds();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete ad')),
      );
    }
  }

  Future<void> editAd(String adId, String brandName, String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse('https://beauty-from-the-seoul.vercel.app/ads/edit-ad/$adId/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'brand_name': brandName,
          'image': imageUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad updated successfully')),
        );
        fetchAds(); 
      } else {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'] ?? 'Failed to update ad')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showEditAdDialog(BuildContext context, AdEntry ad) {
    final brandNameController = TextEditingController(text: ad.fields.brandName);
    final imageUrlController = TextEditingController(text: ad.fields.image);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Ad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: brandNameController,
                decoration: const InputDecoration(labelText: 'Brand Name'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (brandNameController.text.isEmpty || imageUrlController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                } else {
                  editAd(ad.pk, brandNameController.text, imageUrlController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void showAdminActionsDialog(AdEntry ad) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Actions for ${ad.fields.brandName}'),
          actions: [
            TextButton(
              onPressed: () => approveAd(ad.pk),
              child: const Text('Approve'),
            ),
            TextButton(
              onPressed: () => deleteAd(ad.pk),
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () => showEditAdDialog(context, ad),
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Beauty From The Seoul - Admin',
          style: TextStyle(
            fontFamily: 'Laurasia',
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF071a58),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),  
          child: Container(
            color: const Color(0xFFfcfaf3),  
            height: 1.0,          
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
            color: Colors.white,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  AdCarousel(
                    ads: ads,
                    screenWidth: screenWidth,
                    isAdmin: true,
                    onLongPress: showAdminActionsDialog,
                  ),
                  const BrandSection(),
                  const CategorySection(), 
                  const PromotionEventSection(),
                  const SkinConcernSection(),
                  const LocationSection(),
                  AdSubmissionSection(onAdSubmit: (context) {
                    showAdSubmissionDialog(context, submitAd);
                  }),
                ],
              ),
            ),
      bottomNavigationBar: const Material3BottomNav(),
    );
  }
}
