import 'package:flutter/material.dart';
import 'ChangePasswordPage.dart';
import 'auth/db.dart';
import 'auth/shareddata.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController emailController = TextEditingController();
  String email = '';
  final Dbdata _dbData = Dbdata();
  final SharedPreferenceHelper _sharedPrefHelper = SharedPreferenceHelper();

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }


  Future<void> _loadUserEmail() async {
    String? userEmail = await _sharedPrefHelper.getUserEmail();
    if (userEmail != null) {
      setState(() {
        email = userEmail;
        emailController.text = userEmail;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,

        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email:',
              style: TextStyle(fontSize: 16,color: Colors.white),

            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color:Colors.white),
                prefixIcon: Icon(Icons.email,color: Colors.white),

              ),
              style: const TextStyle(color: Colors.white),

            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _updateEmail();
              },
              child: const Text('Update Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage()),
                );
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _updateEmail() async {
    String newEmail = emailController.text;
    String? userId = await _sharedPrefHelper.getUserId();

    if (userId != null) {

      bool dbUpdateSuccess = await _dbData.updateUserEmailInDb(userId, newEmail);
      bool prefsUpdateSuccess = await _sharedPrefHelper.saveUserEmail(newEmail);

      if (dbUpdateSuccess && prefsUpdateSuccess) {
        setState(() {
          email = newEmail;
        });


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email updated successfully!')),
        );
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update email!')),
        );
      }
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found!')),
      );
    }
  }
}
