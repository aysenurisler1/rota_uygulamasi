import 'package:flutter/material.dart';
import '../models/calendar_event.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Üst dropdown
  final List<String> addresses = const [
    'Adresler',
    'Bornova - Ev 1',
    'Karşıyaka - Ev 2',
    'Buca - Ev 3',
  ];
  String selectedAddress = 'Adresler';

  late DateTime weekStart; // Pazartesi
  late DateTime selectedDay;

  // Saat aralığı: 08:00–17:00 (10 satır)
  final List<int> hours = List<int>.generate(10, (i) => 8 + i);

  // Eventler (gün bazında)
  final Map<DateTime, List<CalendarEvent>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    weekStart = _startOfWeek(now);
    selectedDay = _dateOnly(now);
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(
      7,
      (i) => _dateOnly(weekStart.add(Duration(days: i))),
    );
    final monthLabel = '${_monthName(days[0].month)} ${days[0].year}';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ====== ÜST YEŞİL BAR ======
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: const Color(0xFF43A047),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    splashRadius: 20,
                  ),

                  // Dropdown
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedAddress,
                        items: addresses
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => selectedAddress = v ?? 'Adresler'),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ✅ DRAGGABLE CHIP (adres seçilince çıkıyor)
                  if (selectedAddress != 'Adresler')
                    Draggable<String>(
                      data: selectedAddress,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _dragChip(selectedAddress, active: true),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.5,
                        child: _dragChip(selectedAddress),
                      ),
                      child: _dragChip(selectedAddress),
                    ),

                  const Spacer(),

                  const Text(
                    'Takvim',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Takvim'),
                          content: const Text(
                            '1) Dropdown’dan bir adres seç.\n'
                            '2) Yanında çıkan chip’i sürükle.\n'
                            '3) Gün + saat hücresine bırak.\n'
                            '4) Tekrar / not / bitiş seçip kaydet.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Tamam'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline, color: Colors.white),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),

            // ====== TAKVİM ALANI ======
            Expanded(
              child: Container(
                color: const Color(0xFFF3F4F3),
                padding: const EdgeInsets.all(14),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      children: [
                        // Ay başlığı + oklar
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  monthLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _arrowBtn(Icons.chevron_left, () {
                                  setState(() {
                                    weekStart = weekStart.subtract(
                                      const Duration(days: 7),
                                    );
                                    if (!_isSameWeek(selectedDay, weekStart)) {
                                      selectedDay = _dateOnly(weekStart);
                                    }
                                  });
                                }),
                                const SizedBox(width: 6),
                                _arrowBtn(Icons.chevron_right, () {
                                  setState(() {
                                    weekStart = weekStart.add(
                                      const Duration(days: 7),
                                    );
                                    if (!_isSameWeek(selectedDay, weekStart)) {
                                      selectedDay = _dateOnly(weekStart);
                                    }
                                  });
                                }),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Gün satırı (Mon..Sun + gün numarası)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: List.generate(7, (i) {
                              final d = days[i];
                              final isSelected = _isSameDate(d, selectedDay);

                              return Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => selectedDay = d),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _weekdayShort(d.weekday),
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.75),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 26,
                                        height: 26,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFFE53935)
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${d.day}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ====== SAATLİ SCHEDULER GRID ======
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F1F1F),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                // Sol saat sütunu
                                SizedBox(
                                  width: 70,
                                  child: Column(
                                    children: hours.map((h) {
                                      return Expanded(
                                        child: Center(
                                          child: Text(
                                            '${h.toString().padLeft(2, '0')}:00',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.5,
                                              ),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),

                                // Gün kolonları (her hücre DragTarget)
                                Expanded(
                                  child: Row(
                                    children: List.generate(7, (dayIndex) {
                                      final day = days[dayIndex];

                                      return Expanded(
                                        child: Column(
                                          children: hours.map((h) {
                                            final slotStart = DateTime(
                                              day.year,
                                              day.month,
                                              day.day,
                                              h,
                                              0,
                                            );

                                            final hoveringBorder = Colors.white
                                                .withOpacity(0.14);
                                            final borderColor = Colors.white
                                                .withOpacity(0.08);

                                            final eventAtSlot =
                                                _findEventAtSlot(day, h);

                                            return Expanded(
                                              child: DragTarget<String>(
                                                onWillAcceptWithDetails: (_) =>
                                                    true,
                                                onAcceptWithDetails: (details) {
                                                  _handleDrop(
                                                    details.data,
                                                    slotStart,
                                                  );
                                                },
                                                builder: (context, candidate, rejected) {
                                                  final hovering =
                                                      candidate.isNotEmpty;

                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                          0.5,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: hovering
                                                          ? Colors.white
                                                                .withOpacity(
                                                                  0.08,
                                                                )
                                                          : Colors.transparent,
                                                      border: Border.all(
                                                        color: hovering
                                                            ? hoveringBorder
                                                            : borderColor,
                                                      ),
                                                    ),
                                                    child: eventAtSlot == null
                                                        ? null
                                                        : Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical: 4,
                                                                  ),
                                                              child: GestureDetector(
                                                                onTap: () =>
                                                                    _showEventDetail(
                                                                      day,
                                                                      eventAtSlot,
                                                                    ),
                                                                onSecondaryTapDown:
                                                                    (
                                                                      _,
                                                                    ) => _removeEvent(
                                                                      day,
                                                                      eventAtSlot,
                                                                    ),
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            5,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.12,
                                                                        ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          999,
                                                                        ),
                                                                    border: Border.all(
                                                                      color: Colors
                                                                          .white
                                                                          .withOpacity(
                                                                            0.16,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    '${_hhmm(eventAtSlot.start)}-${_hhmm(eventAtSlot.end)} • ${eventAtSlot.title}',
                                                                    style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                  );
                                                },
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            selectedAddress == 'Adresler'
                                ? 'İpucu: Dropdown’dan bir adres seç, chip çıkar; onu hücreye bırak.'
                                : 'İpucu: Chip’i istediğin gün+saat hücresine bırak. (Sağ tık: sil)',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.45),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== DROP: bitiş + tekrar + not ======
  Future<void> _handleDrop(String address, DateTime slotStart) async {
    if (address.trim().isEmpty || address == 'Adresler') return;

    final dayKey = _dateOnly(slotStart);
    setState(() => selectedDay = dayKey);

    TimeOfDay endTime = TimeOfDay(hour: slotStart.hour + 1, minute: 0);
    RepeatType repeat = RepeatType.none;
    final noteCtrl = TextEditingController();

    final created = await showModalBottomSheet<CalendarEvent>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        DateTime toDateTime(TimeOfDay t) => DateTime(
          slotStart.year,
          slotStart.month,
          slotStart.day,
          t.hour,
          t.minute,
        );

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Başlangıç: ${slotStart.hour.toString().padLeft(2, '0')}:00',
                    style: TextStyle(color: Colors.black.withOpacity(0.65)),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Bitiş',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  _timeField(
                    label: 'Bitiş Saati',
                    value: endTime.format(ctx),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: ctx,
                        initialTime: endTime,
                      );
                      if (t == null) return;
                      setModal(() => endTime = t);
                    },
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    'Tekrar',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<RepeatType>(
                        value: repeat,
                        isExpanded: true,
                        items: RepeatType.values
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(r.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setModal(() => repeat = v ?? RepeatType.none),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Text(
                    'Not',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),

                  TextField(
                    controller: noteCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Örn: Kapı kodu / Hasta onayı / vs',
                      filled: true,
                      fillColor: const Color(0xFFF6F7F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('İptal'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final s = slotStart;
                            final e = toDateTime(endTime);

                            if (!e.isAfter(s)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bitiş saati başlangıçtan sonra olmalı',
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.pop(
                              ctx,
                              CalendarEvent(
                                title: address,
                                start: s,
                                end: e,
                                repeat: repeat,
                                note: noteCtrl.text.trim().isEmpty
                                    ? null
                                    : noteCtrl.text.trim(),
                              ),
                            );
                          },
                          child: const Text('Kaydet'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (created == null) return;

    setState(() {
      _eventsByDay.putIfAbsent(dayKey, () => []);
      _eventsByDay[dayKey]!.add(created);
    });
  }

  // ====== Event bul / sil / detay ======
  CalendarEvent? _findEventAtSlot(DateTime day, int hour) {
    final list = _eventsByDay[_dateOnly(day)];
    if (list == null) return null;

    for (final e in list) {
      if (_isSameDate(e.start, day) && e.start.hour == hour) return e;
    }
    return null;
  }

  void _removeEvent(DateTime day, CalendarEvent ev) {
    final key = _dateOnly(day);
    setState(() {
      final list = _eventsByDay[key];
      if (list == null) return;
      list.remove(ev);
      if (list.isEmpty) _eventsByDay.remove(key);
    });
  }

  void _showEventDetail(DateTime day, CalendarEvent ev) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ev.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tarih: ${day.day}.${day.month}.${day.year}'),
            const SizedBox(height: 6),
            Text('Saat: ${_hhmm(ev.start)} - ${_hhmm(ev.end)}'),
            const SizedBox(height: 6),
            Text('Tekrar: ${ev.repeat.label}'),
            if (ev.note != null && ev.note!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Not:', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(ev.note!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeEvent(day, ev);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  // ====== küçük UI ======
  static Widget _dragChip(String text, {bool active = false}) {
    return Container(
      height: 34,
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE0F2E5) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.drag_indicator, size: 18, color: Colors.black54),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // ====== date helpers ======
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _startOfWeek(DateTime d) {
    final day = _dateOnly(d);
    final diff = day.weekday - DateTime.monday;
    return day.subtract(Duration(days: diff));
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameWeek(DateTime d, DateTime start) {
    final ws = _dateOnly(start);
    final we = ws.add(const Duration(days: 6));
    final x = _dateOnly(d);
    return !x.isBefore(ws) && !x.isAfter(we);
  }

  String _weekdayShort(int w) {
    switch (w) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  String _monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[m - 1];
  }

  String _hhmm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
