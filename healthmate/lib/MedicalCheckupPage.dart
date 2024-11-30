import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'DoctorListPage.dart';

class MedicalCheckupPage extends StatefulWidget {
  const MedicalCheckupPage({super.key});

  @override
  _MedicalCheckupPageState createState() => _MedicalCheckupPageState();
}

class _MedicalCheckupPageState extends State<MedicalCheckupPage> {
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); 
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _userPosition = position;
    });

    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorListPage(
          userLatitude: _userPosition!.latitude,
          userLongitude: _userPosition!.longitude,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Checkup',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: const CircularProgressIndicator(), 
      ),
    );
  }
}



