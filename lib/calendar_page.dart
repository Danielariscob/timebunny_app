import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_bunny/meeting_detail_page.dart';
import 'package:time_bunny/widgets/meeting_card.dart';
import 'package:time_bunny/helpers/database_helper.dart';
import 'package:time_bunny/models/meeting.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Meeting> _meetingsForDay = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMeetingsForDay(_selectedDay!);
  }

  Future<void> _loadMeetingsForDay(DateTime day) async {
    final db = DatabaseHelper.instance;
    final meetings = await db.getMeetingsForDate(
      '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
    );
    setState(() {
      _meetingsForDay = meetings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFEC729C),
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _loadMeetingsForDay(selectedDay);
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF176), Color(0xFFF48FB1)],
                ),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color(0xFFEC729C),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Colors.white),
              todayTextStyle: TextStyle(color: Colors.white),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                color: Colors.white,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF48FB1), Color(0xFFFFF176)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                _meetingsForDay.isEmpty
                    ? Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 48,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 70),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFF48FB1), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'No meetings scheduled yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: _meetingsForDay.length,
                      itemBuilder: (context, index) {
                        final meeting = _meetingsForDay[index];

                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        final validEmails =
                            meeting.participants
                                .split(';')
                                .map((e) => e.trim())
                                .where(
                                  (e) => e.isNotEmpty && emailRegex.hasMatch(e),
                                )
                                .toList();

                        return MeetingCard(
                          time: meeting.startTime,
                          title: meeting.title,
                          participants: validEmails.length,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => MeetingDetailPage(meeting: meeting),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
