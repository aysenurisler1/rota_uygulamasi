import 'route_models.dart';
import 'travel_time_provider.dart';

class RoutePlanner {
  RoutePlanner(this._timeProvider);

  final TravelTimeProvider _timeProvider;

  /// UI burayı çağırır.
  ///
  /// - stops: gün içine seçilen adresler
  /// - startAddress: başlangıç adresi (null ise START)
  Future<RouteResult> buildBestRoute(
    List<String> stops, {
    String? startAddress,
  }) async {
    final cleanStops = stops
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    final String start =
        (startAddress != null && cleanStops.contains(startAddress))
        ? startAddress
        : 'START';

    // START sanal düğümse rota listesine dahil ederiz.
    final nodes = (start == 'START') ? ['START', ...cleanStops] : cleanStops;

    final nn = await _nearestNeighborTour(nodes, start);
    final improved = await _twoOpt(nn);

    final total = await _tourCost(improved);

    return RouteResult(path: improved, totalMinutes: total);
  }

  Future<int> _time(String a, String b) async {
    if (a == b) return 0;
    return _timeProvider.minutesBetween(a, b);
  }

  Future<int> _tourCost(List<String> path) async {
    int sum = 0;
    for (int i = 0; i < path.length - 1; i++) {
      sum += await _time(path[i], path[i + 1]);
    }
    return sum;
  }

  // ---------- Nearest Neighbor ----------
  Future<List<String>> _nearestNeighborTour(
    List<String> nodes,
    String start,
  ) async {
    final unvisited = nodes.toSet();
    unvisited.remove(start);

    final route = <String>[start];
    var current = start;

    while (unvisited.isNotEmpty) {
      String? best;
      int bestCost = 1 << 30;

      for (final cand in unvisited) {
        final c = await _time(current, cand);
        if (c < bestCost) {
          bestCost = c;
          best = cand;
        }
      }

      route.add(best!);
      unvisited.remove(best);
      current = best;
    }

    route.add(start); // geri dönüş
    return route;
  }

  // ---------- 2-opt ----------
  Future<List<String>> _twoOpt(List<String> path) async {
    if (path.length <= 4) return path;

    bool improved = true;
    var best = List<String>.from(path);
    var bestCost = await _tourCost(best);

    while (improved) {
      improved = false;

      for (int i = 1; i < best.length - 2; i++) {
        for (int k = i + 1; k < best.length - 1; k++) {
          final candidate = <String>[
            ...best.sublist(0, i),
            ...best.sublist(i, k + 1).reversed,
            ...best.sublist(k + 1),
          ];

          final candCost = await _tourCost(candidate);
          if (candCost < bestCost) {
            best = candidate;
            bestCost = candCost;
            improved = true;
          }
        }
      }
    }

    return best;
  }
}
