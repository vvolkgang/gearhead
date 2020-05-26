import 'package:flutter/cupertino.dart';

/// Motorbike gearing model
class BikeModel extends ChangeNotifier {

  final List<double> _gearing = [1.857, 2.785, 2.052, 1.681, 1.45, 1.304, 1.148];
  int _frontSprocketTeeth = 17;
  int _rearSprocketTeeth = 47;

  int get frontSprocketTeeth => _frontSprocketTeeth;
  int get rearSprocketTeeth => _rearSprocketTeeth;
  
  /// Calculates the final drive based on the front and rear sprocket
  double get finalDrive => _rearSprocketTeeth / _frontSprocketTeeth;

  /// Gearing setter
  void setGearing(int gear, String gearing){
    //TODO check params limits
    _gearing[gear] = double.tryParse(gearing) ?? 0.0;
    notifyListeners();
  }

  /// Front Sprocket Teeth setter
  void setFrontSprocketTeeth(String frontSprocket){
    //TODO check params limits
    _frontSprocketTeeth = int.tryParse(frontSprocket) ?? 0;
    notifyListeners();
  }

  /// Rear Sprocket Teeth setter
  void setRearSprocketTeeth(String rearSprocket){
    //TODO check params limits
    _rearSprocketTeeth = int.tryParse(rearSprocket) ?? 0;
    notifyListeners();
  }

  double getGearing(int i) {
    return _gearing[i];
  }
}
