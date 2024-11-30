import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PedometerService {
  late Stream<StepCount> _stepCountStream;
  int _currentDayStepCount = 0;
  List<int> _dailyStepCounts = List.filled(7, 0); // Storing last 7 days steps

  Future<void> initPedometer(Function(int) onStepCountUpdate) async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      onStepCountUpdate(-1); // Permission not granted
      return;
    }

    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen((StepCount event) {
        _currentDayStepCount = event.steps;
        onStepCountUpdate(_currentDayStepCount);
      }).onError((error) {
        onStepCountUpdate(-1);
      });
    } catch (error) {
      onStepCountUpdate(-1);
    }
  }

  Future<int> getStepsForDay(int dayIndex) async {
    // Use SharedPreferences or another method to store day-wise steps
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('day_$dayIndex') ?? 0; // Return steps for a particular day
  }

  Future<void> saveDailyStepCount(int dayIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('day_$dayIndex', _currentDayStepCount);
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    return await Permission.activityRecognition.request() == PermissionStatus.granted;
  }

  Future<bool> _isStepCountingAvailable() async {
    try {
      await Pedometer.stepCountStream.first;
      return true;
    } catch (e) {
      return false;
    }
  }
}

