import '../../domain/routing/travel_time_provider.dart';

class FakeTravelTimeProvider implements TravelTimeProvider {
  @override
  Future<int> minutesBetween(String fromAddress, String toAddress) async {
    if (fromAddress == toAddress) return 0;

    // Deterministic: 6–38 dk
    int hash = 0;
    final s = '$fromAddress|$toAddress';
    for (int i = 0; i < s.length; i++) {
      hash = (hash * 31 + s.codeUnitAt(i)) & 0x7fffffff;
    }
    return 6 + (hash % 33);
  }
}
