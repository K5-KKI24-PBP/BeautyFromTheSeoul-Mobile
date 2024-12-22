import 'dart:convert';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:beauty_from_the_seoul_mobile/events/screens/create_event.dart';
import 'package:beauty_from_the_seoul_mobile/events/screens/edit_event.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beauty_from_the_seoul_mobile/events/models/events.dart' as events_model;
import 'package:beauty_from_the_seoul_mobile/events/models/rsvp.dart' as rsvp_model;
import 'package:beauty_from_the_seoul_mobile/events/widgets/events_card.dart';
import 'package:beauty_from_the_seoul_mobile/shared/widgets/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventPage> {
  List<events_model.Events> events = []; // List to hold filtered events
  DateTime? _selectedDate;
  bool isStaff = false;
  Set<String> rsvpEventIds = {}; 
  List<rsvp_model.Rsvp> rsvp = [];

  Future<void> _checkUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final userRole = prefs.getString('userRole') ?? '';
    setState(() {
      isStaff = userRole == 'admin';
    });
  }
  
  Future<List<rsvp_model.Rsvp>> fetchRsvp() async {
    try {
      final response = await http.get(
          Uri.parse('https://beauty-from-the-seoul.vercel.app/events/rsvp-json/'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<rsvp_model.Rsvp> rsvp = data.map((rsvpData) => rsvp_model.Rsvp.fromJson(rsvpData)).toList();
        return rsvp;
      } else {
        throw Exception('Failed to load RSVP data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching RSVP: $e');
      throw Exception(e.toString());
    }
  }

  Future<List<events_model.Events>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('https://beauty-from-the-seoul.vercel.app/events/event-json/'));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<events_model.Events> events = data.map((data) => events_model.Events.fromJson(data)).toList();
        
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

      if (response.statusCode == 200) {
        print('Event deleted successfully');
        return;
      } else {
        print('Failed to delete event: ${response.statusCode}');
        throw Exception('Failed to delete event');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error occurred while deleting event');
    }
  }

  Future<void> confirmDelete(String eventId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await deleteEvent(eventId);

        setState(() {
          events.removeWhere((event) => event.pk == eventId); 
        });
      } catch (e) {
        print('Error deleting event: $e');
      }
    }
  }

  Future<List<events_model.Events>> fetchEventsByMonth(int month, int year) async {
    String url = 'http://beauty-from-the-seoul.vercel.app/events/filter-events/?month=$month&year=$year';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Check if the 'events' field is a String, and if so, decode it
        var eventsData = responseData['events'];
        if (eventsData is String) {
          // If it's a string, decode it
          List<dynamic> eventsJson = jsonDecode(eventsData);
          List<events_model.Events> events = eventsJson.map((data) => events_model.Events.fromJson(data)).toList();
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

  Future<void> rsvpEvent(String eventId ) async {
    final url = Uri.parse('https://beauty-from-the-seoul.vercel.app/events/rsvp-flutter/$eventId/');
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final rsvpStatus = jsonDecode(response.body)['rsvp_status'] ?? false;
        setState(() {
          rsvpEventIds.add(eventId);
        });
        print('RSVP status updated: $rsvpStatus');
      } else {
        print('Failed to RSVP: ${response.statusCode}');
      }

    } catch (e) {
      print('Error RSVPing: $e');
    }
  } 

  Future<void> cancelrsvp(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final url = Uri.parse(
      'https://beauty-from-the-seoul.vercel.app/events/cancel-rsvp-flutter/$eventId/',
    );

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          rsvpEventIds.remove(eventId);
        });
        print('RSVP cancelled successfully');
      } else {
        print('Failed to cancel RSVP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error cancelling RSVP: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    // Initially load all events
    fetchEvents().then((fetchedEvents) {
      setState(() {
        events = fetchedEvents; // Initially display all events
      });
    });
    
    // Fetch RSVP status for the user
    fetchRsvp().then((fetchedRsvp) {
      setState(() {
        rsvp = fetchedRsvp;
        rsvpEventIds = fetchedRsvp
            .where((rsvp) => rsvp.fields.rsvpStatus) // Filter by RSVP status
            .map((rsvp) => rsvp.fields.event) 
            .toSet(); // Convert to a set
      });
    });
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showMonthYearPicker(
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
            color: Color(0xFF071a58),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), 
              topRight: Radius.circular(8)
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/events2.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.3),
                width: double.infinity,
                height: 200,
              ),
              const Text(
                'Discover the latest events and promotions happening near you!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Laurasia',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.all(6)),
          OutlinedButton(
            onPressed: () => _selectDate(context), // Open the date picker
            child: const Text('Filter by Month'),
          ),

          if (isStaff) ...[IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Event',
            onPressed: () async {
              final newEvent = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventForm()),
              );

              if (newEvent != null && mounted) {
                fetchEvents().then((fetchedEvents) {
                  setState(() {
                    events = fetchedEvents; // Update displayed events with filtered data
                  });
                });
              }
            },
          )],

          const Padding(padding: EdgeInsets.all(4)),
          Expanded(
            child: FutureBuilder<List<events_model.Events>>(
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
                        isStaff: isStaff,
                        isRsvp: rsvpEventIds.contains(event.pk.toString()),

                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditEventForm(eventId: event.pk),
                            ),
                          ).then((result) {
                            if (result != null) {
                              setState(() {
                                // Update the specific event in the list
                                final updatedEventIndex = events.indexWhere((e) => e.pk == result['id']);
                                events[updatedEventIndex] = events_model.Events(
                                  model: 'events.events',
                                  pk: result['id'],
                                  fields: events_model.Fields(
                                    name: result['title'],
                                    description: result['description'],
                                    startDate: DateTime.parse(result['start_date']),
                                    endDate: DateTime.parse(result['end_date']),
                                    location: result['location'],
                                    promotionType: result['promotion_type'],
                                  ),
                                );
                              });
                            }
                          });
                        },

                        onDelete: () {
                          confirmDelete(event.pk);
                        },

                        onRsvp: () {
                          rsvpEvent(event.pk);
                        },

                        onCancelRsvp: () {
                          cancelrsvp(event.pk);
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
