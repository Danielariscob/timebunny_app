import 'package:flutter/material.dart';
import 'package:time_bunny/models/meeting.dart';

class MeetingDetailPage extends StatelessWidget {
  final Meeting meeting;

  const MeetingDetailPage({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEC729C),
        title: const Text(
          'Meeting Details',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailItem('Title', meeting.title),
            _detailItem('Date', meeting.date),
            _detailItem('Time', meeting.startTime),
            _detailItem('Time Zone', meeting.timezone),
            _detailItem(
              'Participants',
              meeting.participants.replaceAll(';', '\n'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontFamily: 'Poppins'),
          ),
        ],
      ),
    );
  }
}
