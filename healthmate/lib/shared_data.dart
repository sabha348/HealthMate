import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:convert';


class SharedData with ChangeNotifier {
  List<String> pickedFiles = [];
  List<Map<String, dynamic>> medicineList = []; 

  SharedData() {
    loadPickedFiles();
  }

  Future<void> loadPickedFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    pickedFiles = prefs.getStringList('pickedFiles') ?? [];
    notifyListeners(); 
  }

  Future<void> pickFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'mp4', 'mp3'],
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          pickedFiles.add(file.path!);
        }
      }
      await saveFilesToPrefs(); 
      notifyListeners(); 
    } else {
      print('No files picked');
    }
  }

  Future<void> pickImageFromCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    try {
      
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      
      if (image != null) {
        
        await addPickedImage(image.path); 
        print('Image picked: ${image.path}'); 
      } else {
        print('No image picked'); 
      }
    } catch (e) {
      
      print('Error picking image: $e');
    }
  }

  
  Future<void> addPickedImage(String imagePath) async {
    pickedFiles.add(imagePath); 
    await saveFilesToPrefs(); 
    notifyListeners(); 
  }

  Future<void> saveFilesToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pickedFiles', pickedFiles);
  }

  
  Future<void> deleteFile(String filePath) async {
    pickedFiles.remove(filePath);
    await saveFilesToPrefs();
    notifyListeners(); 
  }



}
