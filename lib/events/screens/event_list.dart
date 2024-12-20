import 'dart:convert';
import 'package:beauty_from_the_seoul_mobile/events/screens/create_event.dart';
import 'package:beauty_from_the_seoul_mobile/events/screens/edit_event.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beauty_from_the_seoul_mobile/events/models/events.dart';
import 'package:beauty_from_the_seoul_mobile/events/widgets/events_card.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventPage> {
  List<Events> allEvents = []; // List to hold all events
  List<Events> events = []; // List to hold filtered events
  DateTime? _selectedDate;

  Future<List<Events>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('https://beauty-from-the-seoul.vercel.app/events/event-json/'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Events> events = data.map((data) => Events.fromJson(data)).toList();
        
        // Sorting the events based on start date
        events.sort((a, b) => a.fields.startDate.compareTo(b.fields.startDate));
        return events;

      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final response = await http.delete(Uri.parse('https://beauty-from-the-seoul.vercel.app/events/delete-event-flutter/$eventId/'));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<Events>> fetchEventsByMonth(int month, int year) async {
    String url = 'http://beauty-from-the-seoul.vercel.app/events/filter-events/?month=$month&year=$year';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Debugging: Print the entire response structure
        print('Response Data: $responseData');

        // Check if the 'events' field is a String, and if so, decode it
        var eventsData = responseData['events'];
        if (eventsData is String) {
          // If it's a string, decode it
          List<dynamic> eventsJson = jsonDecode(eventsData);
          List<Events> events = eventsJson.map((data) => Events.fromJson(data)).toList();
          return events;
        } else {
          throw Exception('The events field is not a String. Found: ${eventsData.runtimeType}');
        }
      } else {
        throw Exception('Failed to load filtered events. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      throw Exception('Error fetching events: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Initially load all events
    fetchEvents().then((fetchedEvents) {
      setState(() {
        allEvents = fetchedEvents;
        events = fetchedEvents; // Initially display all events
      });
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      // Fetch events for the selected month and year
      fetchEventsByMonth(pickedDate.month, pickedDate.year).then((fetchedEvents) {
        setState(() {
          events = fetchedEvents; // Update displayed events with filtered data
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Promotion Events',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF071a58), // Blue background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), 
              topRight: Radius.circular(8)
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          OutlinedButton(
            onPressed: () => _selectDate(context), // Open the date picker
            child: const Text('Filter by Month'),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Event',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventForm()),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Events>>(
              future: fetchEvents(),  // Load all events initially
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        name: event.fields.name,
                        description: event.fields.description,
                        startDate: event.fields.startDate,
                        endDate: event.fields.endDate,
                        promotionType: event.fields.promotionType,
                        location: event.fields.location,

                        onEdit: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditEventForm(eventId: event.pk,)),
                        );
                        },
                        onDelete: () {
                          deleteEvent(event.pk);
                        },
                        onRsvp: () {
                          print('RSVP for event ${event.pk}');
                        },
                      );
                    },
                  );
                } else {
                  return const Text(
                    'No promotion events available',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Material3BottomNav(), // Added Navbar here
    );
  }
}
