import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'PedometerService.dart'; 
import 'GyroscopeCyclingService.dart'; 
import 'DoctorListPage.dart'; 
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> medicineList = [];
  Map<String, dynamic>? upcomingReminder;
  bool _isLoading = false; 
  Timer? _reminderCheckTimer; 


  String _currentSteps = '0';
  int _currentCyclingSteps = 0;

  final PedometerService _pedometerService = PedometerService();
  final GyroscopeCyclingService _gyroscopeCyclingService = GyroscopeCyclingService();

  @override
  void initState() {
    super.initState();
    _loadMedicineList();
    _initPedometer(); 
    _initCyclingService();
    _startReminderCheck(); 
  }

  @override
  void dispose() {
    _reminderCheckTimer?.cancel(); 
    super.dispose();
  }

  void _startReminderCheck() {
    _reminderCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        upcomingReminder = _getUpcomingReminder(); 
      });
    });
  }

  void _loadMedicineList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? medicineData = prefs.getString('medicineList');
    if (medicineData != null) {
      List<dynamic> jsonData = jsonDecode(medicineData);
      setState(() {
        medicineList = jsonData.map((item) => Map<String, dynamic>.from(item)).toList();
        upcomingReminder = _getUpcomingReminder(); 
      });
    }
  }

  Future<void> _initPedometer() async {
    _pedometerService.initPedometer((newStepCount) {
      setState(() {
        _currentSteps = newStepCount.toString();
      });
    });
  }

  Future<void> _initCyclingService() async {
    _gyroscopeCyclingService.cyclingStepsStream.listen((newCyclingSteps) {
      setState(() {
        _currentCyclingSteps = newCyclingSteps;
      });
    });
  }

  Future<void> _fetchUserLocation() async {
    setState(() {
      _isLoading = true; 
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      setState(() {
        _isLoading = false; 
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        setState(() {
          _isLoading = false; 
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied')),
      );
      setState(() {
        _isLoading = false; 
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorListPage(
          userLatitude: position.latitude,
          userLongitude: position.longitude,
        ),
      ),
    );

    setState(() {
      _isLoading = false; 
    });
  }


  Map<String, dynamic>? _getUpcomingReminder() {
    final now = DateTime.now();
    List<Map<String, dynamic>> upcoming = [];

    for (var medicine in medicineList) {
      DateTime? reminderTime = _parseTime(medicine['time']);
      if (reminderTime != null && reminderTime.isAfter(now)) {
        upcoming.add(medicine);
      }
    }

    if (upcoming.isNotEmpty) {
      upcoming.sort((a, b) {
        DateTime? timeA = _parseTime(a['time']);
        DateTime? timeB = _parseTime(b['time']);
        return timeA!.compareTo(timeB!);
      });
      return upcoming.first; 
    }

    return null; 
  }

  DateTime? _parseTime(String time) {
    final now = DateTime.now();

    bool is24HourFormat = !time.toLowerCase().contains('am') && !time.toLowerCase().contains('pm');

    List<String> timeComponents;
    int hour;
    int minute;

    if (is24HourFormat) {
      timeComponents = time.split(':');
      hour = int.parse(timeComponents[0]);
      minute = int.parse(timeComponents[1]);
    } else {
      timeComponents = time.split(' ')[0].split(':');
      hour = int.parse(timeComponents[0]);
      minute = int.parse(timeComponents[1]);

      bool isPM = time.toLowerCase().contains('pm');
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0; 
      }
    }

    return DateTime(now.year, now.month, now.day, hour, minute);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Upcoming Pill Reminder',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
   children: [
            upcomingReminder != null
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[900],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3), 
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.access_time_filled, size: 60, color: Colors.orangeAccent),
                    const SizedBox(width: 20),
                    Expanded( child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medicine: ${upcomingReminder!['name']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Time: ${upcomingReminder!['time']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Description: ${upcomingReminder!['description']}',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Food Option: ${upcomingReminder!['foodOption']}',
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueGrey[800]!, Colors.blueGrey[900]!], 
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(0, 5), 
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sentiment_satisfied_alt,
                      size: 70, 
                      color: Colors.orangeAccent, 
                    ),
                    const SizedBox(width: 15), 
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "You're all caught up!",
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'No upcoming pill reminders.',
                            style: TextStyle(
                              fontSize: 20, 
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20), 

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Current Activity',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3), 
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, size: 30, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded( 
                          child: Text(
                            'Walking: $_currentSteps steps',
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                            overflow: TextOverflow.ellipsis, 
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), 
                    Row(
                      children: [
                        const Icon(Icons.pedal_bike, size: 30, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded( 
                          child: Text(
                            'Cycling: $_currentCyclingSteps pedal rotations',
                            style: const TextStyle(fontSize: 18, color: Colors.white),
                            overflow: TextOverflow.ellipsis, 
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30), 

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? CircularProgressIndicator() 
                  : ElevatedButton(
                onPressed: () {
                  _fetchUserLocation(); 
                },
                child: const Text('Doctor Nearby'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[800], 
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), 
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}







