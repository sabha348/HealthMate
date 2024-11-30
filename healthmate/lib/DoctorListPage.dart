import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class DoctorListPage extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;

  const DoctorListPage({super.key, required this.userLatitude, required this.userLongitude});

  @override
  _DoctorListPageState createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  String _selectedSpecialty = 'All';
  final List<String> _specialties = [
    'All',
    'Cardiologist',
    'Dermatologist',
    'General Practitioner',
    'ENT Specialist',
    'Neurologist',
    'Pediatrician',
    'Orthopedic Surgeon',
    'Gynecologist',
    'Urologist',
    'Psychiatrist',
    'General Surgeon',
    'Oncologist',
    'Neurosurgeon',
    'Endocrinologist',
    'Pulmonologist',
    'Rheumatologist',
    'Ophthalmologist',
    'Dentist',
    'Gastroenterologist',
  ];

  Future<List<Map<String, dynamic>>> _loadDoctors() async {
    try {
      final String response = await DefaultAssetBundle.of(context).loadString('assets/doctors.json');
      final List<dynamic> data = json.decode(response);

      if (data.isEmpty) {
        throw Exception('Empty or invalid JSON data');
      }

      List<Map<String, dynamic>> filteredDoctors = data.map<Map<String, dynamic>>((doctor) {
        double doctorLat = doctor['address']['latitude'];
        double doctorLon = doctor['address']['longitude'];

        double distance = Geolocator.distanceBetween(
          widget.userLatitude,
          widget.userLongitude,
          doctorLat,
          doctorLon,
        );

        return {
          'name': doctor['name'],
          'location': doctor['location'],
          'specialty': doctor['specialty'],
          'distance': distance,
        };
      }).toList();

      if (_selectedSpecialty != 'All') {
        filteredDoctors = filteredDoctors
            .where((doctor) =>
        doctor['specialty'].toString().toLowerCase().trim() ==
            _selectedSpecialty.toLowerCase().trim())
            .toList();
      }

      filteredDoctors.sort((a, b) => a['distance'].compareTo(b['distance']));

      return filteredDoctors.take(7).toList();
    } catch (e) {
      throw Exception('Failed to load doctors');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctors Near You',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Specialty',
                labelStyle: const TextStyle(color: Colors.white),
                fillColor: Colors.black, 
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.white, width: 1.5), 
                ),
              ),
              dropdownColor: Colors.black, /
              style: const TextStyle(color: Colors.white, fontSize: 16), 
              iconEnabledColor: Colors.white, 
              value: _selectedSpecialty,
              items: _specialties.map((String specialty) {
                return DropdownMenuItem<String>(
                  value: specialty,
                  child: Text(
                    specialty,
                    style: const TextStyle(color: Colors.white), 
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedSpecialty = newValue!;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading data: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No doctors found near you.'));
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final doctor = snapshot.data![index];
                      return ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: Text(
                          doctor['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Location: ${doctor['location']}\nSpecialty: ${doctor['specialty']}\nDistance: ${doctor['distance'].toStringAsFixed(2)} meters',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.black, 
    );
  }
}
