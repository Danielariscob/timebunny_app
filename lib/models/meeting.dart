class Meeting {
  final String title;
  final String date;
  final String startTime;
  final String participants;
  final String timezone;
  final String utcDateTime;

  Meeting({
    required this.title,
    required this.date,
    required this.startTime,
    required this.participants,
    required this.timezone,
    required this.utcDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'startTime': startTime,
      'participants': participants,
      'timezone': timezone,
      'utcDateTime': utcDateTime,
    };
  }

  factory Meeting.fromMap(Map<String, dynamic> map) {
    return Meeting(
      title: map['title'],
      date: map['date'],
      startTime: map['startTime'],
      participants: map['participants'],
      timezone: map['timezone'],
      utcDateTime: map['utcDateTime'],
    );
  }
}
