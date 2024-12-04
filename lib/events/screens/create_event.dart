import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beauty_from_the_seoul_mobile/events/screens/event_list.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventForm extends StatefulWidget {
  const EventForm({Key? key}) : super(key: key);

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _location = '';
  String _promotionType = '';
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2200),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 26, 84),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: "Title",
                hint: "Enter event title",
                onChanged: (value) => _title = value,
                validator: (value) => value?.isEmpty ?? true ? "Title cannot be empty!" : null,
              ),
              _buildTextField(
                label: "Description",
                hint: "Enter event description",
                onChanged: (value) => _description = value,
                validator: (value) => value?.isEmpty ?? true ? "Description cannot be empty!" : null,
              ),
              _buildDateField(
                label: "Start Date",
                selectedDate: _startDate,
                selectDate: (context) => _selectDate(context, isStartDate: true),
              ),
              _buildDateField(
                label: "End Date",
                selectedDate: _endDate,
                selectDate: (context) => _selectDate(context, isStartDate: false),
              ),
              _buildTextField(
                label: "Location",
                hint: "Enter event location",
                onChanged: (value) => _location = value,
                validator: (value) => value?.isEmpty ?? true ? "Location cannot be empty!" : null,
              ),
              _buildTextField(
                label: "Promotion Type",
                hint: "Enter promotion type",
                onChanged: (value) => _promotionType = value,
                validator: (value) => value?.isEmpty ?? true ? "Promotion type cannot be empty!" : null,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 12, 26, 84)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final response = await http.post(
                            Uri.parse('http://beauty-from-the-seoul.vercel.app/events/create-event-flutter/'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode({
                              'title': _title,
                              'description': _description,
                              'start_date': formatDate(_startDate),
                              'end_date': formatDate(_endDate),
                              'location': _location,
                              'promotion_type': _promotionType,
                            }),
                          );
                          final responseBody = jsonDecode(response.body);
                          print(responseBody);
                          if (responseBody['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("New event has saved successfully!"),
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const EventPage()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Something went wrong, please try again."),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required Function(BuildContext) selectDate,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: TextEditingController(text: selectedDate != null ? "${selectedDate.toIso8601String().substring(0, 10)}" : ""),
        decoration: InputDecoration(
          hintText: label,
          labelText: label,
          suffixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        onTap: () => selectDate(context),
        readOnly: true, // to prevent keyboard from appearing
      ),
    );
  }
}
