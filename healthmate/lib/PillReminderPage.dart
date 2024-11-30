import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'shared_data.dart';
import 'package:provider/provider.dart';

class PillReminderPage extends StatefulWidget {
  const PillReminderPage({super.key});

  @override
  _PillReminderPageState createState() => _PillReminderPageState();
}

class _PillReminderPageState extends State<PillReminderPage> {
  List<Map<String, dynamic>> medicineList = []; 
  String selectedFoodOption = 'Before';



  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadMedicineList();
    _initializeNotifications();
    _requestPermissions();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print("Notification response received: ${response.actionId}, Payload: ${response.payload}");
        if (response.actionId == 'accept' && response.payload != null) {
          int medicineIndex = int.parse(response.payload!);  
        }
      },
    );

  }




  void _scheduleNotification(String time, String medicineName, int index) async {
    final notificationTime = _parseTime(time);
    if (notificationTime != null) {
      final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

      final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'pill_reminder_channel',
        'Pill Reminder',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      tz.initializeTimeZones();

      await flutterLocalNotificationsPlugin.zonedSchedule(
        index,
        'Time to take your medicine',
        'Medicine: $medicineName',
        tzNotificationTime,
        platformChannelSpecifics,
        payload: index.toString(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

     
    }
  }

  void _requestPermissions() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  void _loadMedicineList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? medicineData = prefs.getString('medicineList');
    if (medicineData != null) {
      List<dynamic> jsonData = jsonDecode(medicineData);
      setState(() {
        medicineList = jsonData.map((item) => Map<String, dynamic>.from(item)).toList();
      });
    }
  }

  void _saveMedicineList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('medicineList', jsonEncode(medicineList));
  }

  DateTime? _parseTime(String time) {
    int hour;
    int minute;
    final now = DateTime.now();

    
    if (time.contains('AM') || time.contains('PM')) {
      final timeParts = time.split(' ');
      final isPM = timeParts[1].toLowerCase() == 'pm';
      List<String> timeComponents = timeParts[0].split(':');
      hour = int.parse(timeComponents[0]);
      minute = int.parse(timeComponents[1]);
      if (isPM && hour != 12) hour += 12;
      else if (!isPM && hour == 12) hour = 0;
    } else {
      List<String> timeComponents = time.split(':');
      hour = int.parse(timeComponents[0]);
      minute = int.parse(timeComponents[1]);
    }

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void _addMedicine(String time, String name, String description, String foodOption) {
    final medicineTime = _parseTime(time);
    if (medicineTime != null) {
      setState(() {
        medicineList.add({
          'time': time,
          'name': name,
          'description': description,
          'foodOption': foodOption,
        });
        _saveMedicineList();

        if (medicineTime.isAfter(DateTime.now())) {
          _scheduleNotification(time, name, medicineList.length - 1);
        }
      });
    }
  }

  void _editMedicine(int index, String time, String name, String description, String foodOption) {
    final medicineTime = _parseTime(time);
    if (medicineTime != null) {
      setState(() {
        medicineList[index] = {
          'time': time,
          'name': name,
          'description': description,
          'foodOption': foodOption,
        };
        _saveMedicineList();
        _scheduleNotification(time, name, index);
      });
    }
  }



  void _deleteMedicine(int index) {
    setState(() {
      medicineList.removeAt(index);
      _saveMedicineList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: const Text(
          'Pill Reminder',
          style: TextStyle(color: Colors.white), 
        ),
        centerTitle: true,
        backgroundColor: Colors.black, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: medicineList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.access_time, color: Colors.white), 
            title: Text(
              medicineList[index]['name']!,
              style: const TextStyle(color: Colors.white), 
            ),
            subtitle: Text(
              '${medicineList[index]['time']} - ${medicineList[index]['description']} (${medicineList[index]['foodOption']})',
              style: const TextStyle(color: Colors.white70), 
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white), 
                  onPressed: () {
                    _showAddMedicineDialog(
                      context,
                      index: index,
                      existingTime: medicineList[index]['time'],
                      existingName: medicineList[index]['name'],
                      existingDescription: medicineList[index]['description'],
                      existingFoodOption: medicineList[index]['foodOption'],
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    _deleteMedicine(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          _showAddMedicineDialog(context);
        },
        child: const Icon(Icons.add, color: Colors.black), 
      ),
    );
  }

  void _showAddMedicineDialog(BuildContext context,
      {int? index, String? existingTime, String? existingName, String? existingDescription, String? existingFoodOption}) {
    String time = existingTime ?? '';
    String name = existingName ?? '';
    String description = existingDescription ?? '';
    String foodOption = existingFoodOption ?? 'Before';

    TextEditingController nameController = TextEditingController(text: existingName);
    TextEditingController descriptionController = TextEditingController(text: existingDescription);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              title: Text(
                index == null ? 'Add Medicine' : 'Edit Medicine',
                style: const TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              time = pickedTime.format(context);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            controller: TextEditingController(text: time),
                          ),
                        ),
                      ),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Medicine Name',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        controller: nameController,
                        onChanged: (value) {
                          name = value;
                        },
                      ),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        controller: descriptionController,
                        onChanged: (value) {
                          description = value;
                        },
                      ),
                      const SizedBox(height: 12.0),
                      const Text('Food Option', style: TextStyle(color: Colors.white)),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Before', style: TextStyle(color: Colors.white)),
                              value: 'Before',
                              groupValue: foodOption,
                              onChanged: (value) {
                                setState(() {
                                  foodOption = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('After', style: TextStyle(color: Colors.white)),
                              value: 'After',
                              groupValue: foodOption,
                              onChanged: (value) {
                                setState(() {
                                  foodOption = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () {
                    if (time.isNotEmpty && name.isNotEmpty && description.isNotEmpty) {
                      if (index == null) {
                        _addMedicine(time, name, description, foodOption);
                      } else {
                        _editMedicine(index, time, name, description, foodOption);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(index == null ? 'Add' : 'Update', style: const TextStyle(color: Colors.white)), // White button text
                ),
              ],
            );
          },
        );
      },
    );
  }
}


