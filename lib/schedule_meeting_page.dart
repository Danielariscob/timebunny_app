import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_bunny/calendar_page.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:time_bunny/helpers/database_helper.dart';
import 'package:time_bunny/models/meeting.dart';

class ScheduleMeetingPage extends StatefulWidget {
  const ScheduleMeetingPage({super.key});

  @override
  State<ScheduleMeetingPage> createState() => _ScheduleMeetingPageState();
}

class _ScheduleMeetingPageState extends State<ScheduleMeetingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _participantsController = TextEditingController();
  String _selectedTimezone = 'GMT-05:00 — Lima, Bogotá, Quito';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _timezones = [
    'GMT-08:00 — Los Angeles, San Francisco',
    'GMT-07:00 — Denver, Phoenix',
    'GMT-06:00 — Chicago, Mexico City',
    'GMT-05:00 — Lima, Bogotá, Quito',
    'GMT-04:00 — Caracas, La Paz',
    'GMT-03:00 — Buenos Aires, Montevideo',
    'GMT+00:00 — London, Lisbon',
    'GMT+01:00 — Berlin, Paris, Rome',
    'GMT+02:00 — Athens, Cape Town',
    'GMT+03:00 — Istanbul, Nairobi, Moscow',
    'GMT+05:30 — Mumbai, New Delhi',
    'GMT+08:00 — Beijing, Singapore',
    'GMT+10:00 — Sydney, Melbourne',
  ];

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFF48FB1),
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFF48FB1),
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formattedDate() =>
      _selectedDate == null
          ? 'Select date'
          : DateFormat('yyyy-MM-dd').format(_selectedDate!);

  String _formattedTime() => _selectedTime?.format(context) ?? 'Select time';

  bool _validateEmails(String input) {
    final emails = input.split(';').map((e) => e.trim());
    final regex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z]{2,})+$",
    );
    return emails.every((email) => regex.hasMatch(email));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final offsetStr = _selectedTimezone.split('—')[0].trim();
    final offsetH = int.parse(offsetStr.substring(4, 6));
    final sign = offsetStr.contains('-') ? -1 : 1;
    final totalMinutes = sign * offsetH * 60;
    final date = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final local = tz.TZDateTime.from(
      date,
      tz.getLocation('UTC'),
    ).add(Duration(minutes: totalMinutes));
    final utc = local.toUtc();

    final meeting = Meeting(
      title: _titleController.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      startTime: _formattedTime(),
      participants: _participantsController.text.trim(),
      timezone: _selectedTimezone,
      utcDateTime: utc.toIso8601String(),
    );

    await DatabaseHelper.instance.insertMeeting(meeting);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Meeting scheduled!'),
        backgroundColor: Color(0xFFEC729C),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CalendarPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Schedule Meeting',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEC729C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Title',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_formattedDate()),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _selectTime,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(_formattedTime()),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTimezone,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Time Zone',
                  border: OutlineInputBorder(),
                ),
                items:
                    _timezones
                        .map(
                          (tz) => DropdownMenuItem(
                            value: tz,
                            child: Text(
                              tz,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _selectedTimezone = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _participantsController,
                decoration: const InputDecoration(
                  labelText: 'Participants (use ";" to separate)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Enter participants';
                  } else if (!_validateEmails(val)) {
                    return 'Use valid emails separated by ";"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.schedule, color: Colors.white),
                  label: const Text(
                    'Schedule',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC729C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
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
}
