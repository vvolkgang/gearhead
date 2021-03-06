import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'Extensions.dart';

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

class AccelData {
  final double meanAccel;
  final double distance;
  final double time;
  final double timeAggregate; //aggregated time with resistance
  final double distanceAggregate; //aggregated time with resistance

  AccelData(this.meanAccel, this.time, this.distance, this.timeAggregate, this.distanceAggregate);
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
  int _launchControlRpm = 6000;

  Map<int, double> get torqueMap => _torque;
  int get launchControlRpm => _launchControlRpm;

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

  double getSpeedForRpmAndGear(int rpm, int gear) => rpm == 0
      ? 0
      : (rpm * 2.0 * pi / 60 / (_gearing[0] * _gearing[gear] * finalDrive)) *
          ((_rimSize * 0.0254 / 2) + ((_tireWidth * _tireAspectRation) / 100000)) *
          3.6;

  double getSpeedMeterPerSec(double speedInKmh) => speedInKmh * 1000 / 3600;
  double getSpeedMeterPerSecFromRpm(int rpm, int gear) => getSpeedMeterPerSec(getSpeedForRpmAndGear(rpm, gear));

  int gearChangeRpm(int fromGear, int toGear) => fromGear <= 0 ? 0 : (_maxRpm * _gearing[toGear] / _gearing[fromGear]).round();

  double getRadPerSec(int rpm) => rpm * 2 * pi / 60;
  double getTorque(int rpm) => _torque[rpm]; //TODO improve this so it interpolates between values
  double getTorqueWithLosses(int rpm) => getTorque(rpm) * (1 - _powerLossInTransmission);
  double getTorqueGainConstant(int prevRpm, int currRpm) =>
      (getTorqueWithLosses(currRpm) - getTorqueWithLosses(prevRpm)) / (getRadPerSec(currRpm) - getRadPerSec(prevRpm));

  double getTorqueIncrementConstant(int prevRpm, int currRpm) =>
      getTorqueWithLosses(currRpm) - getRadPerSec(currRpm) * getTorqueGainConstant(prevRpm, currRpm);

  double forcePerSec(double torqueGain, double torqueInc, int gear, int rpm) =>
      torqueGain * primaryGear * _gearing[gear] * finalDrive / (2 * wheelRadius) * pow(getRadPerSec(rpm), 2) +
      torqueInc * primaryGear * _gearing[gear] * finalDrive / wheelRadius * getRadPerSec(rpm) -
      0.5 *
          airDensity *
          frontArea *
          dragCoefficient *
          pow(wheelRadius, 2) /
          (pow(primaryGear * _gearing[gear] * finalDrive, 2) * 3) *
          pow(getRadPerSec(rpm), 3) -
      rollResistanceForce * getRadPerSec(rpm);

  double calcMeanAcceleration(int prevRpm, int currRpm, int gear) {
    final b = getTorqueGainConstant(prevRpm, currRpm);
    final c = getTorqueIncrementConstant(prevRpm, currRpm);

    return (1 / (totalWeight * (getRadPerSec(currRpm) - getRadPerSec(prevRpm)))) *
        (forcePerSec(b, c, gear, currRpm) - forcePerSec(b, c, gear, prevRpm));
  }

  Map<int, AccelData> createMeanAccelerationForGear(int gear) {
    final meanAccelMap = <int, AccelData>{};
    meanAccelMap[0] = AccelData(0, 0, 0, 0, 0);
    //TODO currently we're using the torque values sampling rate. After implementing torque values lerp this can be improved to configurable (thus more accurate) sampling rate

    double timeAggregate = 0;
    double distanceAggregate = 0;

    for (var i = 1; i < _torque.length; i++) {
      final prevRpm = _torque.keys.elementAt(i - 1);
      final currRpm = _torque.keys.elementAt(i);

      final macc = calcMeanAcceleration(prevRpm, currRpm, gear);
      final time = calcTimeWithResistance(prevRpm, currRpm, gear, macc);
      final dist = calcDistance(prevRpm, currRpm, gear, macc, time);

      timeAggregate += currRpm >= _launchControlRpm ? time : 0; // only count after launch
      distanceAggregate += dist;
      meanAccelMap[currRpm] = AccelData(macc, time, dist, timeAggregate, distanceAggregate);
    }

    return meanAccelMap;
  }

  double calcTimeWithResistance(int prevRpm, int currRpm, int gear, double macc) {
    final prevSpeed = currRpm == _launchControlRpm ? 0 : getSpeedMeterPerSecFromRpm(prevRpm, gear);
    final currSpeed = getSpeedMeterPerSecFromRpm(currRpm, gear);

    return (currSpeed - prevSpeed) / macc;
  }

  double calcDistance(int prevRpm, int currRpm, int gear, double macc, double time) =>
      currRpm < _launchControlRpm ? 0 : .5 * macc * pow(time, 2) + getSpeedForRpmAndGear(prevRpm, gear) * time;

  List<charts.Series<SpeedForRpm, int>> createSpeedPerRpmData() {
    final List<charts.Series<SpeedForRpm, int>> dataList2 = <charts.Series<SpeedForRpm, int>>[];

    for (var i = 0; i < _gearing.length - 1; i++) {
      dataList2.add(charts.Series<SpeedForRpm, int>(
        id: 'Speed Plot',
        domainFn: (SpeedForRpm data, _) => data.speed.toInt(),
        measureFn: (SpeedForRpm data, _) => data.rpm,
        data: [
          SpeedForRpm(getSpeedForRpmAndGear(gearChangeRpm(i, i + 1), i + 1), gearChangeRpm(i, i + 1)),
          SpeedForRpm(getMaxSpeedForGear(i + 1), _maxRpm)
        ],
      ));
    }

    return dataList2;
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

  List<Point> createSpeedTimeList() {
    final list = <Point>[];
    list.add(const Point(0, 0));
    for (var i = 1; i < _gearing.length - 1; i++) {
      final x = createMeanAccelerationForGear(i).values.last.timeAggregate.toPrecision(1);
      final y = getMaxSpeedForGear(i).toPrecision(1);

      list.add(Point(x, y));
    }

    return list;
  }

  List<Point> createDistanceTimeList() {
    final list = <Point>[];
    list.add(const Point(0, 0));
    for (var i = 1; i < _gearing.length - 1; i++) {
      final macc = createMeanAccelerationForGear(i);
      final x = macc.values.last.timeAggregate.toPrecision(1);
      final y = macc.values.last.distanceAggregate.toPrecision(1);

      list.add(Point(x, y));
    }

    return list;
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

  set launchControlRpm(int launchControlRpm) {
    _launchControlRpm = launchControlRpm;
    notifyListeners();
  }
}
