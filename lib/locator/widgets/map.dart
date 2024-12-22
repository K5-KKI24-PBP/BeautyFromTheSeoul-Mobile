import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MapSection extends StatefulWidget {
  const MapSection({super.key});

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse('https://www.google.com/maps/d/u/0/embed?mid=1eUKaCIKE-XTVcOgbm4WPCkHSnibBGQ4&ehbc=2E312F&noprof=1'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
