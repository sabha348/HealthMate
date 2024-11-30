import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthmate/PillReminderPage.dart';
import 'package:open_file/open_file.dart';
import 'ActivityPage.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'package:path/path.dart';
import 'shared_data.dart';
import 'package:provider/provider.dart';



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String _searchQuery = '';


  Future<void> _logout(BuildContext context) async {
    try {

      Fluttertoast.showToast(msg: "Logging out...");
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.clear();


      await FirebaseAuth.instance.signOut();


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {

      Fluttertoast.showToast(msg: "Error logging out: $e");
    }
  }


  Future<void> pickFiles(BuildContext context) async {
    if (!mounted) return;
    final sharedData = Provider.of<SharedData>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a Picture'),
              onTap: () {
                sharedData.pickImageFromCamera(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Pick a File'),
              onTap: () {
                sharedData.pickFiles(context);  
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static final List<Widget> _widgetOptions = <Widget>[
     HomePage(),
    const Text('Your Docs', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
   const PillReminderPage(),
    const ActivityPage(),
  ];


  void _onItemTapped(int index) {
    setState(() {
      if (index != 1) {
        _searchQuery = ''; 
      }
      _selectedIndex = index;
    });
  }


  void _addDoc(BuildContext context) {
    pickFiles(context);
     
  }


  Widget returnLogo(String file) {
    var ex = extension(file);
    if (ex == '.jpg') {
      return const Icon(
        Icons.image,
        color: Colors.green,
      );
    } else if (ex == '.pdf') {
      return const Icon(
        Icons.picture_as_pdf,
        color: Colors.orange,
      );
    } else if (ex == '.mp4') {
      return const Icon(
        Icons.my_library_music_rounded,
        color: Colors.red,
      );
    } else {
      return const Icon(
        Icons.question_mark_outlined,
        color: Colors.grey,
      );
    }
  }


  openFile(String filePath) {
    File file = File(filePath);
    OpenFile.open(file.path);
  }

  
  Future<void> deleteFile(BuildContext context, String filePath) async {
    final sharedData = Provider.of<SharedData>(context, listen: false);
    await sharedData.deleteFile(filePath); 
  }

  Future<void> renameFile(BuildContext context, String filePath) async {
    TextEditingController controller = TextEditingController();

    
    controller.text = basename(filePath);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Rename File"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Rename"),
              onPressed: () {
                
                _updateFileName(context, filePath, controller.text); 
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateFileName(BuildContext context, String oldFilePath, String newFileName) {
    final sharedData = Provider.of<SharedData>(context, listen: false);
    String directory = dirname(oldFilePath);
    String newFilePath = '$directory/$newFileName';

    
    if (sharedData.pickedFiles.contains(oldFilePath)) {
      
      File(oldFilePath).renameSync(newFilePath);

      int index = sharedData.pickedFiles.indexOf(oldFilePath);
      if (index != -1) {
        sharedData.pickedFiles[index] = newFilePath; 
        sharedData.saveFilesToPrefs(); 
        sharedData.notifyListeners();
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final sharedData = Provider.of<SharedData>(context);

    List<String> filteredFiles = sharedData.pickedFiles.where((file) {
      return basename(file).toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
              ),
            ),
            const Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(Icons.health_and_safety_rounded),
                  SizedBox(width: 8.0),
                  Text('Health-Mate'),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _selectedIndex == 1
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color:Colors.white),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),

            ),

          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: ()=> _addDoc(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: const Text('Add Doc / Take Picture'),
            ),
          ),
          filteredFiles.isNotEmpty 
              ? Expanded(
            child: ListView.builder(
              itemCount: filteredFiles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => openFile(filteredFiles[index]),
                  child: Card(
                    child: ListTile(
                      leading: returnLogo(filteredFiles[index]),
                      title: Row(
                        children: [
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              basename(filteredFiles[index]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue), 
                            onPressed: () {
                              renameFile(context, filteredFiles[index]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteFile(context, filteredFiles[index]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
              : Container(child: const Text('No files Selected')),
        ],
      )
          : Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Your Docs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm),
            label: 'Reminder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Activity',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.pink,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

