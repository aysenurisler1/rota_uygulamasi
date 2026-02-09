class RouteResult {
  RouteResult({required this.path, required this.totalMinutes});

  /// Örn: START -> A -> B -> START
  final List<String> path;

  final int totalMinutes;

  String get prettyPath => path.join(' → ');
}
