/// Rota algoritmasının ihtiyaç duyduğu tek şey:
/// "A -> B arası kaç dakika sürer?" bilgisidir.
abstract class TravelTimeProvider {
  Future<int> minutesBetween(String fromAddress, String toAddress);
}
