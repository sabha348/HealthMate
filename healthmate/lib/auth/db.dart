import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthmate/auth/shareddata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dbdata {
  Future<bool> updateUserPasswordInDb(String userId, String newPassword) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .update({'password': newPassword});
      print("User password updated in Firestore.");
      return true;
    } catch (e) {
      print("Error updating user password in Firestore: $e");
      return false;
    }
  }

  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('user')
        .doc(id)
        .set(userInfoMap);
  }

  Future<String?> getUserPassword(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(SharedPreferenceHelper.userPasswordKey);
    } catch (e) {
      print('Error getting user password: $e');
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      print(prefs.getString(SharedPreferenceHelper.userIdKey));
      return prefs.getString(SharedPreferenceHelper.userIdKey);
    } catch (e) {
      print('Error getting user id: $e');
      return null;
    }
  }

  Future<Map<String, String>?> getUserInfoFromMail(String? mail) async {
    try {
      if (mail == null) return null;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: mail)
          .limit(1)
          .get();

      print("Query :  ${querySnapshot.docs.first}");

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        String userId = doc.id;
        String userPassword = doc.get('password');

        return {'id': userId, 'password': userPassword};
      } else {
        print('No user found with email: $mail');
        return null;
      }
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  Future<bool> updateUserEmailInDb(String userId, String newEmail) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .update({'email': newEmail});
      print("User email updated in Firestore.");
      return true;
    } catch (e) {
      print("Error updating user email in Firestore: $e");
      return false;
    }
  }
}
