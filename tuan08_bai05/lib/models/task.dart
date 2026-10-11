class Task {
  int id;
  String title;
  int hour;
  int minute;
  bool done;

  Task({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    this.done = false,
  });

  String get timeText =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  String toFileString() => '$id|$title|$timeText|${done ? 1 : 0}';

  static Task fromString(String line) {
    final p = line.split('|');
    final hm = p[2].split(':');
    return Task(
      id: int.parse(p[0]),
      title: p[1],
      hour: int.parse(hm[0]),
      minute: int.parse(hm[1]),
      done: p.length > 3 && p[3] == '1',
    );
  }

  DateTime nextReminder() {
    final now = DateTime.now();
    var t = DateTime(now.year, now.month, now.day, hour, minute);
    if (!t.isAfter(now)) t = t.add(const Duration(days: 1));
    return t;
  }
}
