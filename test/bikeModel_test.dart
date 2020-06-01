

import 'package:flutter_test/flutter_test.dart';
import 'package:gearhead/BikeModel.dart';

void main() {
  test('Counter value should be incremented', () {
    final bike = BikeModel();

    final map = bike.createMeanAccelerationForGear(1);

    expect(map.values.last, 8.5);
  });
}