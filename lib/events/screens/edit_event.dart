import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EditEventForm extends StatefulWidget {
  final String eventId;

  const EditEventForm({super.key, required this.eventId});

  @override
  State<EditEventForm> createState() => _EditEventFormState();
}

class _EditEventFormState extends State<EditEventForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _promotionTypeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
    final url = Uri.parse('http://beauty-from-the-seoul.vercel.app/events/get-event/${widget.eventId}/');
    try {
      final response = await http.get(url);
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
          setState(() {
            _titleController.text = data['title'] ?? '';
            _descriptionController.text = data['description'] ?? '';
            _startDate = DateTime.parse(data['start_date']);
            _endDate = DateTime.parse(data['end_date']);
            _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate!);
            _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate!);
            _locationController.text = data['location'] ?? '';
            _promotionTypeController.text = data['promotion_type'] ?? '';
          });
      } else {
        throw Exception('Failed to load event data');
      }
    } catch (e) {
      print('Error fetching event data: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    try {
      final response = await http.put(
        Uri.parse('http://beauty-from-the-seoul.vercel.app/events/edit-event-flutter/${widget.eventId}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'start_date': _startDateController.text,
          'end_date': _endDateController.text,
          'location': _locationController.text,
          'promotion_type': _promotionTypeController.text,
        }),
      );

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event successfully updated!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event: ${responseBody["message"]}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context). pop(),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 26, 84),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_titleController, "Title", "Enter event title"),
              _buildTextField(_descriptionController, "Description", "Enter event description"),
              _buildDateField("Start Date", _startDateController, _startDate, true),
              _buildDateField("End Date", _endDateController, _endDate, false),
              _buildTextField(_locationController, "Location", "Enter event location"),
              _buildTextField(_promotionTypeController, "Promotion Type", "Enter promotion type"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                      const Color.fromARGB(255, 12, 26, 84)),
                  ),
                  onPressed: _submitData,
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
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

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty!';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, DateTime? date, bool isStartDate) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        onTap: () => _selectDate(context, isStartDate: isStartDate),
        readOnly: true,
      ),
    );
  }
}
