import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GyroscopeCyclingService {
  final StreamController<int> _cyclingStepsController = StreamController<int>();
  double _previousYValue = 0;
  int _cyclingSteps = 0;

  List<int> _dailyCyclingSteps = List.filled(7, 0); 
  final double rotationThreshold = 3.0;

  GyroscopeCyclingService() {
    _startGyroscopeListener();
  }

  Stream<int> get cyclingStepsStream => _cyclingStepsController.stream;

  void _startGyroscopeListener() {
    gyroscopeEvents.listen((GyroscopeEvent event) {
      _processGyroscopeData(event);
    });
  }

  void _processGyroscopeData(GyroscopeEvent event) {
    double yRotation = event.y;

    if (yRotation.abs() > rotationThreshold && _previousYValue.abs() < rotationThreshold) {
      _cyclingSteps++;
      _cyclingStepsController.add(_cyclingSteps);
    }

    _previousYValue = yRotation;
  }

  Future<int> getCyclingStepsForDay(int dayIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('cycling_day_$dayIndex') ?? 0;
  }

  Future<void> saveDailyCyclingSteps(int dayIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('cycling_day_$dayIndex', _cyclingSteps);
  }

  void dispose() {
    _cyclingStepsController.close();
  }
}




