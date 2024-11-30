import 'package:flutter/material.dart';
import 'auth/db.dart';
import 'auth/shareddata.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  final Dbdata _dbData = Dbdata();
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper(); 

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    String oldPassword = oldPasswordController.text;
    String newPassword = newPasswordController.text;
    String? userId = await _sharedPrefHelper.getUserId();
    String? storedPassword = await _sharedPrefHelper.getUserPassword();


    if (oldPassword == storedPassword && newPassword.isNotEmpty && userId != null) {

      bool dbUpdateSuccess = await _dbData.updateUserPasswordInDb(userId, newPassword);


      bool prefsUpdateSuccess = await _sharedPrefHelper.saveUserPassword(newPassword);

      if (dbUpdateSuccess && prefsUpdateSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to change password!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Old password is incorrect or new password is invalid!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password',
          style: TextStyle(color: Colors.white)
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Old Password:',
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),

            const SizedBox(height: 10),
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color:Colors.white),

              ),
              style: const TextStyle(color: Colors.white),

            ),
            const SizedBox(height: 20),
            const Text(
              'New Password:',
              style: TextStyle(fontSize: 16,color: Colors.white),

            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),

              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Update Password',),
            ),
          ],
        ),
      ),
    );
  }
}
