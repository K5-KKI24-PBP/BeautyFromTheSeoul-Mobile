import 'dart:convert';
import 'package:beauty_from_the_seoul_mobile/events/screens/create_event.dart';
import 'package:beauty_from_the_seoul_mobile/events/screens/edit_event.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beauty_from_the_seoul_mobile/events/models/events.dart';
import 'package:beauty_from_the_seoul_mobile/events/widgets/events_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventPage> {
  List<Events> allEvents = []; // List to hold all events
  List<dynamic> events = []; // List to hold filtered events
  int selectedYear = 2024; // Default to current year
  int selectedMonth = DateTime.now().month; // Default to current month

  Future<List<Events>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('http://beauty-from-the-seoul.vercel.app/events/event-json/'));
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
      final response = await http.delete(Uri.parse('http://beauty-from-the-seoul.vercel.app/events/delete-event-flutter/$eventId/'));

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFilteredEvents(selectedYear, selectedMonth); // Initial fetch with current date
  }

  Future<void> fetchFilteredEvents(int year, int month) async {
    String url = 'http://beauty-from-the-seoul.vercel.app/events/filter-events/?month=$month&year=$year';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String eventsString = responseData['events'];
        List<dynamic> eventsJson = jsonDecode(eventsString); 
        List<Events> events = eventsJson.map((data) => Events.fromJson(data)).toList();
        setState(() {
          allEvents = events;  // Update the state with the newly fetched events
        });
      } else {
        throw Exception('Failed to load filtered events');
      }
    } catch (e) {
      print('Error fetching filtered events: $e');
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(7, (index) {
                  int year = 2024 + index; 
                  return DropdownMenuItem(value: year, child: Text(year.toString()));
                }),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedYear = newValue;
                      fetchFilteredEvents(selectedYear, selectedMonth);
                    });
                  }
                },
              ),
              DropdownButton<int>(
                value: selectedMonth,
                items: List.generate(12, (index) {
                  return DropdownMenuItem(value: index + 1, child: Text((index + 1).toString()));
                }),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedMonth = newValue;
                      fetchFilteredEvents(selectedYear, selectedMonth);
                    });
                  }
                },
              ),
            ],
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
              future: fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: allEvents.length,
                    itemBuilder: (context, index) {
                      final event = allEvents[index];
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
