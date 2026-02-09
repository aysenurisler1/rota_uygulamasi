import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../../domain/routing/travel_time_provider.dart';

class RecordedTravelTimeProvider implements TravelTimeProvider {
  final Map<String, Map<String, int>> _minutes = {};
  final List<String> _addresses = [];
  List<String> get addresses => List.unmodifiable(_addresses);

  /// JSON dosyasını belleğe alır
  Future<void> loadFromAsset(String assetPath) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
    _addresses
      ..clear()
      ..addAll(
        (decoded['addresses'] as List<dynamic>).map((e) => e.toString()),
      );
    final minutes = decoded['minutes'] as Map<String, dynamic>;

    for (final from in minutes.keys) {
      final targets = minutes[from] as Map<String, dynamic>;
      _minutes[from] = {};

      for (final to in targets.keys) {
        _minutes[from]![to] = targets[to] as int;
      }
    }
  }

  @override
  Future<int> minutesBetween(String from, String to) async {
    if (from == to) return 0;

    final row = _minutes[from];
    if (row == null) {
      throw Exception('No travel time data for "$from"');
    }

    final value = row[to];
    if (value == null) {
      throw Exception('No travel time from "$from" to "$to"');
    }

    return value;
  }
}
