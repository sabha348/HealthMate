import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  static String userIdKey = "USERKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userPasswordKey = "USERPASSWORD";

  Future<bool> saveUserId(String getUserId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userIdKey, getUserId);
    } catch (e) {
      SharedPreferences.setMockInitialValues({});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userIdKey, getUserId);
    }
  }

  Future<bool> saveUserPassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userPasswordKey, password);
  }

  Future<String?> getUserPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPasswordKey);
  }

  Future<bool> saveUserEmail(String getUserEmail) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userEmailKey, getUserEmail);
    } catch (e) {
      SharedPreferences.setMockInitialValues({});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userEmailKey, getUserEmail);
    }
  }

  Future<String?> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(userIdKey);
    } catch (e) {
      SharedPreferences.setMockInitialValues({});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(userIdKey);
    }
  }

  Future<String?> getUserEmail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(userEmailKey);
    } catch (e) {
      SharedPreferences.setMockInitialValues({});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(userEmailKey);
    }
  }

  Future<bool> updateUserEmailInPrefs(String newEmail) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.setString(userEmailKey, newEmail);
    } catch (e) {
      print("Error updating email in SharedPreferences: $e");
      return false;
    }
  }

  static String userCyclingStepsKey = "USER_CYCLING_STEPS";
  static String userFootstepsKey = "USER_FOOTSTEPS";
  static String cyclingTimestampKey = "CYCLING_TIMESTAMP";
  static String footstepsTimestampKey = "FOOTSTEPS_TIMESTAMP";

  Future<void> saveCyclingSteps(int steps) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(userCyclingStepsKey, steps);
    await prefs.setInt(cyclingTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> saveFootsteps(int steps) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(userFootstepsKey, steps);
    await prefs.setInt(footstepsTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<int?> getCyclingSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedTimestamp = prefs.getInt(cyclingTimestampKey);
    if (savedTimestamp != null && _isTimestampValid(savedTimestamp)) {
      return prefs.getInt(userCyclingStepsKey);
    } else {
      return null;
    }
  }

  Future<int?> getFootsteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedTimestamp = prefs.getInt(footstepsTimestampKey);
    if (savedTimestamp != null && _isTimestampValid(savedTimestamp)) {
      return prefs.getInt(userFootstepsKey);
    } else {
      return null;
    }
  }

  bool _isTimestampValid(int timestamp) {
    int sevenDaysInMillis = 7 * 24 * 60 * 60 * 1000;
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    return (currentTime - timestamp) <= sevenDaysInMillis;
  }
}
