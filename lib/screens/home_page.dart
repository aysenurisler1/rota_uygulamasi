import 'package:flutter/material.dart';

import '../data/address_store.dart';
import '../models/calendar_event.dart';
import '../widgets/center_drop_card.dart';
import '../widgets/top_action_bar.dart';
import 'calendar_page.dart';
import '../domain/routing/route_models.dart';
import '../domain/routing/route_planner.dart';
import '../data/routing/fake_travel_time_provider.dart';
import '../data/routing/recorded_travel_time_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const int maxDaily = 20;
  late final RecordedTravelTimeProvider _timeProvider;
  late RoutePlanner _planner;

  // Üstte görünen draggable kartlar
  final List<String> addressCards = [];

  // Dropdown havuzu (dinamik)
  final List<String> filterItems = ['Adresler'];
  String selectedFilter = 'Adresler';

  // Günlük plan (drop alanı)
  final List<String> dropped = [];
  final Map<String, RepeatType> repeatByAddress = {};

  String syncStatus = 'Senkronlandı';

  // Search (CenterDropCard için)
  final TextEditingController searchCtrl = TextEditingController();
  bool isSearching = false;
  List<String> suggestions = [];

  // ✅ Yeni: başlangıç adresi seçimi (null => START / cihaz konumu)
  String? selectedStartAddress;

  @override
  void initState() {
    super.initState();
    _timeProvider = RecordedTravelTimeProvider();

    _timeProvider.loadFromAsset('test_data/travel_times.json').then((_) {
      setState(() {
        _planner = RoutePlanner(_timeProvider);

        // JSON’daki adresleri havuza bas
        for (final a in _timeProvider.addresses) {
          AddressStore.add(a);
          if (!filterItems.contains(a)) filterItems.add(a);
          if (!addressCards.contains(a)) addressCards.add(a);
        }
      });
    });

    // Store’daki adresleri dropdown’a çek
    for (final a in AddressStore.items) {
      if (!filterItems.contains(a)) filterItems.add(a);
    }

    searchCtrl.addListener(() {
      final q = searchCtrl.text.trim();
      if (q.isEmpty) {
        setState(() => suggestions = []);
        return;
      }

      setState(() => isSearching = true);

      // UI-only suggestion
      Future.delayed(const Duration(milliseconds: 220), () {
        if (!mounted) return;

        final query = searchCtrl.text.trim();
        if (query.isEmpty) {
          setState(() {
            suggestions = [];
            isSearching = false;
          });
          return;
        }

        setState(() {
          suggestions = [
            '$query, İzmir',
            '$query Mah., İzmir',
            '$query Cad., Bornova/İzmir',
            '$query Sok., Karşıyaka/İzmir',
            '$query No:12, Konak/İzmir',
          ];
          isSearching = false;
        });
      });
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // Tek yerden ekleme: store + dropdown + kartlar
  void _addAddressToPoolAndCards(String address) {
    final a = address.trim();
    if (a.isEmpty) return;

    setState(() {
      AddressStore.add(a);

      if (!filterItems.contains(a)) {
        filterItems.add(a);
      }

      if (!addressCards.contains(a)) {
        addressCards.insert(0, a);
      }

      if (!filterItems.contains(selectedFilter)) {
        selectedFilter = 'Adresler';
      }

      syncStatus = 'Senkronlandı';
    });
  }

  void _dropAddress(String value) {
    if (dropped.length >= maxDaily) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Günlük limit dolu (20).')));
      return;
    }

    if (!dropped.contains(value)) {
      setState(() {
        dropped.add(value);

        // Başlangıç daha önce seçildiyse ama listeden silindiyse reset (safety)
        if (selectedStartAddress != null &&
            !dropped.contains(selectedStartAddress)) {
          selectedStartAddress = null;
        }
      });
    }
  }

  void _showAppInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 8),
                    Text(
                      'Uygulama Bilgisi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 10),
                    _InfoSection(
                      title: 'Genel',
                      body:
                          'Uygulama, masaüstü + mobil olmak üzere iki parçadan oluşan bir rota planlama ve navigasyon sistemidir.',
                    ),
                    _InfoSection(
                      title: 'Adres Havuzu',
                      body:
                          'Adresler veritabanında tutulur ve gerektiğinde Excel ile toplu içeri alınabilir. Toplam adres sayısı 5000+ olabilir; ancak günlük rota pratikte ~20 adres ile sınırlıdır.',
                    ),
                    _InfoSection(
                      title: 'Optimizasyon Hedefi',
                      body:
                          '“En kısa rota” toplam süre minimizasyonudur (mesafe değil). Başlangıç/bitiş kullanıcıdan sabit alınmaz: mobilde cihaz konumu başlangıç kabul edilir ve rota başlangıca geri döner.',
                    ),
                    _InfoSection(
                      title: 'Masaüstü vs Mobil',
                      body:
                          'Masaüstü planlar (takvim + havuz) → mobil navigasyon yapar (uygulama içi). Aynı hesapla senkron çalışır.',
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _runDemoRoute() {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return FutureBuilder<RouteResult>(
              future: _planner.buildBestRoute(
                dropped,
                startAddress: selectedStartAddress,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const AlertDialog(
                    title: Text('Örnek Rota (Süre Minimizasyonu)'),
                    content: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: SizedBox(
                        height: 40,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  );
                }

                final result = snapshot.data!;

                return AlertDialog(
                  title: const Text('Örnek Rota (Süre Minimizasyonu)'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Başlangıç Adresi',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F7F6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: selectedStartAddress,
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('START (Cihaz konumu)'),
                                ),
                                ...dropped.map(
                                  (a) => DropdownMenuItem<String?>(
                                    value: a,
                                    child: Text(
                                      a,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                setLocal(() => selectedStartAddress = v);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('Toplam süre: ${result.totalMinutes} dk'),
                        const SizedBox(height: 10),
                        Text(result.prettyPath),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Kapat'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!filterItems.contains(selectedFilter)) {
      selectedFilter = 'Adresler';
    }

    // Başlangıç adresi seçilmiş ama artık dropped içinde değilse reset (safety)
    if (selectedStartAddress != null &&
        !dropped.contains(selectedStartAddress)) {
      selectedStartAddress = null;
    }

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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: TopActionBar(
                  filterValue: selectedFilter,
                  filterItems: filterItems,
                  onFilterChanged: (v) {
                    setState(() => selectedFilter = v);
                    if (v != 'Adresler') {
                      _addAddressToPoolAndCards(v);
                    }
                  },
                  primaryColor: cs.primary,
                  selectedCount: dropped.length,
                  maxCount: maxDaily,
                  syncStatus: syncStatus,
                  onInfoPressed: () => _showAppInfo(context),
                  onUploadPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Excel import ekranı (sonra).'),
                      ),
                    );
                  },
                  onCalendarPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CalendarPage()),
                    ).then((_) {
                      setState(() {
                        for (final a in AddressStore.items) {
                          if (!filterItems.contains(a)) filterItems.add(a);
                        }
                      });
                    });
                  },
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: addressCards.map((a) {
                    return Draggable<String>(
                      data: a,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _AddressChip(text: a, ghost: true),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.35,
                        child: _AddressChip(text: a),
                      ),
                      child: _AddressChip(
                        text: a,
                        onRemove: () {
                          setState(() {
                            addressCards.remove(a);
                            AddressStore.remove(a);
                            filterItems.remove(a);

                            // Eğer başlangıç olarak seçiliyse resetle
                            if (selectedStartAddress == a) {
                              selectedStartAddress = null;
                            }

                            if (!filterItems.contains(selectedFilter)) {
                              selectedFilter = 'Adresler';
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: CenterDropCard(
                          title: 'Günlük Plan',
                          droppedAddresses: dropped,
                          onDropAddress: _dropAddress,
                          maxCount: maxDaily,
                          repeatByAddress: repeatByAddress,
                          searchController: searchCtrl,
                          suggestions: suggestions,
                          isSearching: isSearching,
                          onSuggestionTap: (s) {
                            _addAddressToPoolAndCards(s);
                            setState(() {
                              searchCtrl.clear();
                              suggestions = [];
                            });
                          },
                          helperText:
                              'Kartları buraya sürükle. (Hedef: süre minimizasyonu)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: dropped.isEmpty
                                  ? null
                                  : () => setState(() {
                                      dropped.clear();
                                      repeatByAddress.clear();
                                      selectedStartAddress = null;
                                    }),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Temizle'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: dropped.isEmpty ? null : _runDemoRoute,
                              icon: const Icon(Icons.route),
                              label: const Text('Rota Oluştur'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
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

class _AddressChip extends StatelessWidget {
  const _AddressChip({required this.text, this.onRemove, this.ghost = false});

  final String text;
  final VoidCallback? onRemove;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(ghost ? 0.9 : 1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 6),
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_outlined, color: cs.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Sil',
              onPressed: onRemove,
              icon: const Icon(Icons.close),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(color: Colors.black87, height: 1.35),
          ),
        ],
      ),
    );
  }
}
