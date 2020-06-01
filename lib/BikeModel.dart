import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class SpeedForRpm {
  final double speed;
  final int rpm;

  SpeedForRpm(this.speed, this.rpm);
}

class TorqueForRpm {
  final double torque;
  final int rpm;

  TorqueForRpm(this.rpm, this.torque);
}

/// Motorbike gearing model
class BikeModel extends ChangeNotifier {
  final List<double> _gearing = [1.857, 2.785, 2.052, 1.681, 1.45, 1.304, 1.148];
  final Map<int, double> _torque = <int, double>{
    0: 1,
    1000: 34,
    2000: 41,
    3000: 51,
    4000: 64,
    5000: 65,
    6000: 64,
    7000: 67,
    8000: 73,
    9000: 74,
    10000: 71,
    11000: 65, //made up
    11400: 61,
  };

  int _frontSprocketTeeth = 17;
  int _rearSprocketTeeth = 43;

  int _rimSize = 17;
  int _tireWidth = 180;
  int _tireAspectRation = 55;

  int _maxRpm = 11400;
  int _maxTorque = 81;
  double _powerLossInTransmission = 0.1;

  double _frontArea = 0.6;
  double _airDensity = 1.2;
  double _dragCoefficient = 0.65;
  double _wetWeight = 213;
  double _riderWeight = 72;
  double _rollResistance = 0.006;
  double _gravity = 9.81;

  int get frontSprocketTeeth => _frontSprocketTeeth;
  int get rearSprocketTeeth => _rearSprocketTeeth;
  double get primaryGear => _gearing[0];

  /// Calculates the final drive based on the front and rear sprocket
  double get finalDrive => _rearSprocketTeeth / _frontSprocketTeeth;

  int get rimSize => _rimSize;
  int get tireWidth => _tireWidth;
  int get tireAspectRation => _tireAspectRation;
  double get wheelRadius => _rimSize * 0.0254 / 2 + (_tireWidth * _tireAspectRation) / 100000;

  int get maxRpm => _maxRpm;
  int get maxTorque => _maxTorque;
  double get powerLossInTransmission => _powerLossInTransmission;

  double get frontArea => _frontArea;
  double get airDensity => _airDensity;
  double get dragCoefficient => _dragCoefficient;
  double get wetWeight => _wetWeight;
  double get riderWeight => _riderWeight;
  double get gravity => _gravity;
  double get rollResistanceCoeff => _rollResistance;
  double get totalWeight => _wetWeight + _riderWeight;
  double get rollResistanceForce => totalWeight * _rollResistance * _gravity;
  double get maxAcceleration =>
      ((_maxTorque * (1 - _powerLossInTransmission) * _gearing[0] * _gearing[1] * finalDrive / wheelRadius) -
          0.5 * _airDensity * pow(wheelRadius, 2) * _dragCoefficient * _frontArea /** pow(i11,2)*/ / pow(_gearing[0] * _gearing[1] * finalDrive, 2) -
          rollResistanceForce) /
      totalWeight;

  double get maxSpeedTransLimited => getMaxSpeedForGear(_gearing.length - 1);

  double getMaxSpeedForGear(int i) =>
      (_maxRpm * 2.0 * pi / 60 / (_gearing[0] * _gearing[i] * finalDrive)) *
      ((_rimSize * 0.0254 / 2) + ((_tireWidth * _tireAspectRation) / 100000)) *
      3.6;

  double getSpeedForRpmAndGear(int rpm, int gear) =>
      (rpm * 2.0 * pi / 60 / (_gearing[0] * _gearing[gear] * finalDrive)) *
      ((_rimSize * 0.0254 / 2) + ((_tireWidth * _tireAspectRation) / 100000)) *
      3.6;

  double getSpeedMeterPerSec(int speedInKmh) => speedInKmh * 1000 / 3600;

  int gearChangeRpm(int fromGear, int toGear) => fromGear <= 0 ? 0 : (_maxRpm * _gearing[toGear] / _gearing[fromGear]).round();

  double getRadPerSec(int rpm) => rpm * 2 * pi / 60;
  double getTorque(int rpm) => _torque[rpm]; //TODO improve this so it interpolates between values
  double getTorqueWithLosses(int rpm) => getTorque(rpm) * (1 - _powerLossInTransmission);
  double getTorqueGainConstant(int prevRpm, int currRpm) =>
      (getTorqueWithLosses(currRpm) - getTorqueWithLosses(prevRpm)) / (getRadPerSec(currRpm) - getRadPerSec(prevRpm));

  double getTorqueIncrementConstant(int prevRpm, int currRpm) =>
      getTorqueWithLosses(currRpm) - getRadPerSec(currRpm) * getTorqueGainConstant(prevRpm, currRpm);

  double w(int prevRpm, int currRpm, int gear, int rpm) =>
      getTorqueGainConstant(prevRpm, currRpm) * primaryGear * _gearing[gear] * finalDrive / (2 * wheelRadius) * pow(getRadPerSec(rpm), 2) +
      getTorqueIncrementConstant(prevRpm, currRpm) * primaryGear * _gearing[gear] * finalDrive / wheelRadius * getRadPerSec(rpm) -
      0.5 *
          airDensity *
          frontArea *
          dragCoefficient *
          pow(wheelRadius, 2) /
          (pow(primaryGear * _gearing[gear] * finalDrive, 2) * 3) *
          pow(getRadPerSec(rpm), 3) -
      rollResistanceForce * getRadPerSec(rpm);

  double m(int prevRpm, int currRpm) => totalWeight * (getRadPerSec(currRpm) - getRadPerSec(prevRpm));
  double meanAcceleration(int prevRpm, int currRpm, int gear) =>
      (1 / m(prevRpm, currRpm)) * (w(prevRpm, currRpm, gear, currRpm) - w(prevRpm, currRpm, gear, prevRpm));

  Map<int, double> createMeanAccelerationForGear(int gear) {
    final meanAccelMap = Map<int, double>.from(_torque);
    meanAccelMap[0] = 0;
    //TODO currently we're using the torque values sampling rate. After implementing torque values lerp this can be improved to configurable (thus more accurate) sampling rate

    for (var i = 1; i < _torque.length; i++) {
      final prevRpm = _torque.keys.elementAt(i - 1);
      final currRpm = _torque.keys.elementAt(i);

      final macc = meanAcceleration(prevRpm, currRpm, gear);

      meanAccelMap[currRpm] = macc;
    }

    return meanAccelMap;
  }

  List<charts.Series<SpeedForRpm, int>> createSpeedPerRpmData() {
    //TODO put it in different series so there's cuts between gears and create a cycle for this.
    final List<SpeedForRpm> dataList = <SpeedForRpm>[];
    dataList.add(SpeedForRpm(0, 0));
    dataList.add(SpeedForRpm(getMaxSpeedForGear(1), _maxRpm));

    dataList.add(SpeedForRpm(getSpeedForRpmAndGear(gearChangeRpm(1, 2), 2), gearChangeRpm(1, 2)));
    dataList.add(SpeedForRpm(getMaxSpeedForGear(2), _maxRpm));

    dataList.add(SpeedForRpm(getSpeedForRpmAndGear(gearChangeRpm(2, 3), 3), gearChangeRpm(2, 3)));
    dataList.add(SpeedForRpm(getMaxSpeedForGear(3), _maxRpm));

    dataList.add(SpeedForRpm(getSpeedForRpmAndGear(gearChangeRpm(3, 4), 4), gearChangeRpm(3, 4)));
    dataList.add(SpeedForRpm(getMaxSpeedForGear(4), _maxRpm));

    dataList.add(SpeedForRpm(getSpeedForRpmAndGear(gearChangeRpm(4, 5), 5), gearChangeRpm(4, 5)));
    dataList.add(SpeedForRpm(getMaxSpeedForGear(5), _maxRpm));

    dataList.add(SpeedForRpm(getSpeedForRpmAndGear(gearChangeRpm(5, 6), 6), gearChangeRpm(5, 6)));
    dataList.add(SpeedForRpm(getMaxSpeedForGear(6), _maxRpm));
    // for (var i = 1; i > _gearing.length; i++) {
    //   dataList.add(SpeedForRpm(getMaxSpeedForGear(i), gearChangeRpm(i - 1, i)));
    // }

    return [
      charts.Series<SpeedForRpm, int>(
        id: 'Speed Plot',
        domainFn: (SpeedForRpm data, _) => data.speed.toInt(),
        measureFn: (SpeedForRpm data, _) => data.rpm,
        data: dataList,
      )
    ];
  }

  List<charts.Series<TorqueForRpm, int>> createTorquePerRpmData() {
    final List<TorqueForRpm> dataList = <TorqueForRpm>[];
    _torque.forEach((key, value) => dataList.add(TorqueForRpm(key, value)));

    return [
      charts.Series<TorqueForRpm, int>(
        id: 'Troque Plot',
        domainFn: (TorqueForRpm data, _) => data.rpm,
        measureFn: (TorqueForRpm data, _) => data.torque.toInt(),
        data: dataList,
      )
    ];
  }

  void setGearing(int gear, double gearing) {
    _gearing[gear] = gearing;
    notifyListeners();
  }

  set frontSprocketTeeth(int frontSprocket) {
    _frontSprocketTeeth = frontSprocket;
    notifyListeners();
  }

  set rearSprocketTeeth(int rearSprocket) {
    _rearSprocketTeeth = rearSprocket;
    notifyListeners();
  }

  double getGearing(int i) {
    return _gearing[i];
  }

  set rimSize(int rimSize) {
    _rimSize = rimSize;
    notifyListeners();
  }

  set tireWidth(int tireWidth) {
    _tireWidth = tireWidth;
    notifyListeners();
  }

  set tireAspectRation(int tireAspectRation) {
    _tireAspectRation = tireAspectRation;
    notifyListeners();
  }

  set maxRpm(int maxRpm) {
    _maxRpm = maxRpm;
    notifyListeners();
  }

  set maxTorque(int maxTorque) {
    _maxTorque = maxTorque;
    notifyListeners();
  }

  set powerLossInTransmission(double powerLossInTransmission) {
    _powerLossInTransmission = powerLossInTransmission;
    notifyListeners();
  }

  set frontArea(double frontArea) {
    _frontArea = frontArea;
    notifyListeners();
  }

  set airDensity(double airDensity) {
    _airDensity = airDensity;
    notifyListeners();
  }

  set dragCoefficient(double dragCoefficient) {
    _dragCoefficient = dragCoefficient;
    notifyListeners();
  }

  set wetWeight(double wetWeight) {
    _wetWeight = wetWeight;
    notifyListeners();
  }

  set riderWeight(double riderWeight) {
    _riderWeight = riderWeight;
    notifyListeners();
  }

  set rollResistanceCoeff(double rollResistance) {
    _rollResistance = rollResistance;
    notifyListeners();
  }

  set gravity(double gravity) {
    _gravity = gravity;
    notifyListeners();
  }
}
