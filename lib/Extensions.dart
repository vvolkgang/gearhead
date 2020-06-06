import 'dart:math';

extension Precision on double {
  double toPrecision(int fractionDigits) {
    final mod = pow(10.0, fractionDigits.toDouble());
    return (this * mod).round().toDouble() / mod;
  }
}
