import 'package:flutter/material.dart';
import '../widgets/top_action_bar.dart';
import '../widgets/center_drop_card.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> addresses = const [
    'Adresler',
    'Bornova - Ev 1',
    'Karşıyaka - Ev 2',
    'Buca - Ev 3',
  ];

  String selectedFilter = 'Adresler';
  String selectedAddress = 'Adres Seç';

  // Drop edilen adresleri tutar
  final List<String> dropped = [];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEAF6EC), Color(0xFFDDEEE0)],
            ),
          ),
          child: Column(
            children: [
              // ÜST BAR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: TopActionBar(
                  filterValue: selectedFilter,
                  filterItems: addresses,
                  onFilterChanged: (v) => setState(() => selectedFilter = v),
                  primaryColor: cs.primary,
                  onUploadPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UPLOAD TIKLANDI')),
                    );
                  },
                  onCalendarPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CalendarPage()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // SÜRÜKLENEBİLİR ADRES KARTLARI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _DraggableAddressCard(text: 'Bornova - Ev 1'),
                    _DraggableAddressCard(text: 'Karşıyaka - Ev 2'),
                    _DraggableAddressCard(text: 'Buca - Ev 3'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ORTA DROP ALANI
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CenterDropCard(
                        title: 'Adres Sürükle',
                        dropdownValue: selectedAddress,
                        dropdownItems: const [
                          'Adres Seç',
                          'Bornova - Ev 1',
                          'Karşıyaka - Ev 2',
                          'Buca - Ev 3',
                        ],
                        onDropdownChanged: (v) =>
                            setState(() => selectedAddress = v),
                        helperText:
                            'Adresleri yukarıdan sürükleyip buraya bırak.',
                        onDropAddress: (v) {
                          setState(() {
                            if (!dropped.contains(v)) dropped.add(v);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Eklendi: $v')),
                          );
                        },
                        droppedAddresses: dropped,
                      ),
                    ),
                  ),
                ),
              ),

              // SEÇİLENLER (ALTTA GÖSTERİM)
              if (dropped.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Seçilenler: ${dropped.join(" • ")}',
                      style: TextStyle(color: Colors.grey.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

// SÜRÜKLENEBİLİR KART
class _DraggableAddressCard extends StatelessWidget {
  final String text;

  const _DraggableAddressCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: text,
      feedback: Material(color: Colors.transparent, child: _card(active: true)),
      childWhenDragging: Opacity(opacity: 0.4, child: _card()),
      child: _card(),
    );
  }

  Widget _card({bool active = false}) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE0F2E5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(blurRadius: 6, offset: Offset(0, 4), color: Colors.black12),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
