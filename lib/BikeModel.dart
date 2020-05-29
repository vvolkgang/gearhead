import 'dart:math';

import 'package:flutter/foundation.dart';

/// Motorbike gearing model
class BikeModel extends ChangeNotifier {
  final List<double> _gearing = [1.857, 2.785, 2.052, 1.681, 1.45, 1.304, 1.148];
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

  double getMaxSpeedForGear(int i) {
    return (_maxRpm * 2.0 * pi / 60 / (_gearing[0] * _gearing[i] * finalDrive)) *
        ((_rimSize * 0.0254 / 2) + ((_tireWidth * _tireAspectRation) / 100000)) *
        3.6;
  }

  double getSpeedForRpmAndGear(int rpm, int gear) {
    return (rpm * 2.0 * pi / 60 / (_gearing[0] * _gearing[gear] * finalDrive)) *
        ((_rimSize * 0.0254 / 2) + ((_tireWidth * _tireAspectRation) / 100000)) *
        3.6;
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
