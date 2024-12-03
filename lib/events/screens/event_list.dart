import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beauty_from_the_seoul_mobile/events/models/events.dart';
import 'package:beauty_from_the_seoul_mobile/events/widgets/events_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventPage> {
  Future<List<Events>> fetchEvents(CookieRequest request) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/events/event-json/'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Response JSON: $jsonData'); // To inspect the raw JSON data
        return eventsFromJson(response.body);
      } else {
        throw Exception('Failed to load events: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to parse data: $e');
      throw Exception('Data parsing failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotion Events',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Events>>(
        future: fetchEvents(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                final event = snapshot.data![index];
                return EventCard(
                  name: event.fields.name,
                  description: event.fields.description,
                  startDate: event.fields.startDate,
                  endDate: event.fields.endDate,
                  promotionType: event.fields.promotionType,
                  location: event.fields.location,
                  onEdit: () {
                    // Navigation logic for editing this event
                  },
                  onDelete: () {
                    // Logic for deleting this event
                  },
                );
              },
            );
          } else {
            return const Text('No promotion events available',
              style: TextStyle(fontSize: 20, color: Colors.black),
            );
          }
        },
      ),
    );
  }
}
