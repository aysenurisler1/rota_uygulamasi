enum RepeatType { none, daily, weekly, monthly }

extension RepeatTypeLabel on RepeatType {
  String get label {
    switch (this) {
      case RepeatType.none:
        return 'Tek Sefer';
      case RepeatType.daily:
        return 'Günlük';
      case RepeatType.weekly:
        return 'Haftalık';
      case RepeatType.monthly:
        return 'Aylık';
    }
  }
}

class CalendarEvent {
  final String title;
  final DateTime start;
  final DateTime end;
  final RepeatType repeat;

  // opsiyonel not
  final String? note;

  CalendarEvent({
    required this.title,
    required this.start,
    required this.end,
    this.repeat = RepeatType.none,
    this.note,
  });
}
