import 'package:flutter/material.dart';
import 'package:time_bunny/schedule_meeting_page.dart';
import 'package:time_bunny/view_profile_page.dart';
import 'package:time_bunny/calendar_page.dart';
import 'package:time_bunny/models/meeting.dart';
import 'package:time_bunny/helpers/database_helper.dart';

void main() {
  runApp(const TimeBunnyApp());
}

class TimeBunnyApp extends StatelessWidget {
  const TimeBunnyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Bunny',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF48FB1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF48FB1)),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFF48FB1)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFEC729C),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF176), Color(0xFFF48FB1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/timebunny_logo.png'),
                height: 160,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC729C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainPage()),
                  );
                },
                child: const Text(
                  'Ingresar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFFFAF5F7),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
          children: [
            const Text(
              'Menu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined, size: 26),
              title: const Text(
                'View Profile',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 150), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewProfilePage(),
                    ),
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_camera_front_rounded, size: 26),
              title: const Text(
                'Schedule Meeting',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScheduleMeetingPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_rounded, size: 26),
              title: const Text(
                'Calendar',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 150), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarPage(),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Row(
          children: [
            Text(
              'Time Bunny',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Text('✨', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: FutureBuilder<List<Meeting>>(
        future: DatabaseHelper.instance.getAllMeetings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("❌ Error loading meetings."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No meetings scheduled yet.',
                style: TextStyle(color: Colors.grey, fontFamily: 'Poppins'),
              ),
            );
          }

          final meetings = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: meetings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final m = meetings[index];
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F6),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    m.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${m.date} at ${m.startTime}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFFFF176), Color(0xFFF48FB1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScheduleMeetingPage(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
