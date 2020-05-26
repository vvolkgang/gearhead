import 'package:flutter/cupertino.dart';
import 'dart:math';

/// Motorbike gearing model
class BikeModel extends ChangeNotifier {
  final List<double> _gearing = [1.857, 2.785, 2.052, 1.681, 1.45, 1.304, 1.148];
  int _frontSprocketTeeth = 17;
  int _rearSprocketTeeth = 47;

  int _rimSize = 17;
  int _tireWidth = 180;
  int _tireAspectRation = 55;

  int _maxRpm = 12500;
  int _maxTorque = 81;
  double _powerLossInTransmission = 0.1;

  double _frontArea = 0.4;
  double _airDensity = 1.2;
  double _dragCoefficient = 0.6;
  double _wetWeight = 190;
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
  double get rollResistance => _rollResistance;
  double get gravity => _gravity;
  double get totalWeight => _wetWeight + _riderWeight;
  double get rollResistanceForce => totalWeight * _rollResistance * _gravity;

  /// Gearing setter
  void setGearing(int gear, String gearing) {
    //TODO check params limits
    _gearing[gear] = double.tryParse(gearing) ?? 0.0;
    notifyListeners();
  }

  /// Front Sprocket Teeth setter
  void setFrontSprocketTeeth(String frontSprocket) {
    //TODO check params limits
    _frontSprocketTeeth = int.tryParse(frontSprocket) ?? 0;
    notifyListeners();
  }

  /// Rear Sprocket Teeth setter
  void setRearSprocketTeeth(String rearSprocket) {
    //TODO check params limits
    _rearSprocketTeeth = int.tryParse(rearSprocket) ?? 0;
    notifyListeners();
  }

  double getGearing(int i) {
    return _gearing[i];
  }

  double getMaxSpeedForGear(int i) {
    return (_maxRpm * 2.0 * pi / 60 / (_gearing[0] * _gearing[i] * finalDrive)) *
        ((_rimSize * 0.0254 / 2) + ((_tireWidth * _tireAspectRation) / 100000)) *
        3.6;
  }

  set rimSize(String rimSize) {
    _rimSize = int.tryParse(rimSize) ?? 0;
    notifyListeners();
  }

  set tireWidth(String tireWidth) {
    _tireWidth = int.tryParse(tireWidth) ?? 0;
    notifyListeners();
  }

  set tireAspectRation(String tireAspectRation) {
    _tireAspectRation = int.tryParse(tireAspectRation) ?? 0;
  }

  set maxRpm(String maxRpm) {
    _maxRpm = int.tryParse(maxRpm) ?? 0;
    notifyListeners();
  }

  set maxTorque(String maxTorque) {
    _maxTorque = int.tryParse(maxTorque) ?? 0;
    notifyListeners();
  }

  set powerLossInTransmission(String powerLossInTransmission) {
    _powerLossInTransmission = double.tryParse(powerLossInTransmission) ?? 0;
    notifyListeners();
  }

  set frontArea(String frontArea) {
    _frontArea = double.tryParse(frontArea) ?? 0;
    notifyListeners();
  }

  set airDensity(String airDensity) {
    _airDensity = double.tryParse(airDensity) ?? 0;
    notifyListeners();
  }

  set dragCoefficient(String dragCoefficient) {
    _dragCoefficient = double.tryParse(dragCoefficient) ?? 0;
    notifyListeners();
  }

  set wetWeight(String wetWeight) {
    _wetWeight = double.tryParse(wetWeight) ?? 0;
    notifyListeners();
  }

  set riderWeight(String riderWeight) {
    _riderWeight = double.tryParse(riderWeight) ?? 0;
    notifyListeners();
  }

  set rollResistance(String rollResistance) {
    _rollResistance = double.tryParse(rollResistance) ?? 0;
    notifyListeners();
  }

  set gravity(String gravity) {
    _gravity = double.tryParse(gravity) ?? 0;
    notifyListeners();
  }
}
