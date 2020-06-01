

import 'package:flutter_test/flutter_test.dart';
import 'package:gearhead/BikeModel.dart';

void main() {
  test('Counter value should be incremented', () {
    final bike = BikeModel();

    final prevRpm = 1000;
    final currRpm = 2000;

    final rad = bike.getRadPerSec(currRpm);
    final torquePrev = bike.getTorqueWithLosses(prevRpm);
    final torqueCurrent = bike.getTorqueWithLosses(currRpm);
    final finalDrive = bike.finalDrive;
    
    final b = bike.getTorqueGainConstant(prevRpm, currRpm);
    final c = bike.getTorqueIncrementConstant(prevRpm, currRpm);

    final map = bike.createMeanAccelerationForGear(1);

    expect(map.values.last, 8.5);
  });
}