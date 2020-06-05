import 'package:flutter_test/flutter_test.dart';
import 'package:gearhead/BikeModel.dart';

void main() {
  test('Mean Acceleration map last value should be whats expected', () {
    final bike = BikeModel();

    const prevRpm = 0;
    const currRpm = 1000;

    final rad = bike.getRadPerSec(currRpm);
    final torquePrev = bike.getTorqueWithLosses(prevRpm);
    final torqueCurrent = bike.getTorqueWithLosses(currRpm);
    final finalDrive = bike.finalDrive;

    final b = bike.getTorqueGainConstant(prevRpm, currRpm);
    final c = bike.getTorqueIncrementConstant(prevRpm, currRpm);

    final w2 = bike.forcePerSec(b, c, 1, currRpm);
    final w1 = bike.forcePerSec(b, c, 1, prevRpm);

    final map = bike.createMeanAccelerationForGear(1);

    expect(map.values.last.meanAccel.toStringAsFixed(2), '7.55');
  });
}