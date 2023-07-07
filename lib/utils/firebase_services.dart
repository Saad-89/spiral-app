import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // late SharedPreferences _prefs;

  // to store user info on firebase.
  Future<void> userInfo(String firstName, String lastName, String email) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser!.uid)
          .set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      });
      print('User information stored successfully!');
    } catch (e) {
      print('Error storing user information: $e');
    }
  }

  // fetch first name of the user.
  Future<String?> getUserFirstName() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          final firstName = data['firstName'] as String?;
          return firstName;
        } else {
          print('User document does not exist');
          return null;
        }
      } else {
        print('No user is currently logged in');
        return null;
      }
    } catch (e) {
      print('Error retrieving user information: $e');
      return null;
    }
  }

  // Future<void> initSharedPreferences() async {
  //   _prefs = await SharedPreferences.getInstance();
  // }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserLoginState();
      return userCredential.user;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserLoginState();
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
      await _clearUserLoginState();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _saveUserLoginState() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('isLoggedIn', true);
  }

  Future<void> _clearUserLoginState() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('isLoggedIn', false);
  }

  Future<bool> getUserLoginState() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.getBool('isLoggedIn') ?? false;
  }
}
