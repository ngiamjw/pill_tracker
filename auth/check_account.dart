import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pill_tracker/pages/home_page.dart';
import 'package:pill_tracker/pages/opening_screen.dart';
import 'package:pill_tracker/services/light_storage.dart';
// Import MonitorPage

class CheckAccount extends StatelessWidget {
  final String email;

  CheckAccount({super.key, required this.email});

  Future<void> checkAccountAndNavigate(BuildContext context) async {
    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

      if (docSnapshot.exists) {
        // Navigate to HomePage if medicines array is not empty
        List<String> requestedUsers =
            List<String>.from(docSnapshot.data()?['requested_users'] ?? []);
        saveRequestedUsers(requestedUsers);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              email: email,
            ),
          ),
        );
      } else {
        // Navigate to OpeningScreen if the document does not exist
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OpeningScreen(email: email),
          ),
        );
      }
    } catch (e) {
      print('Error checking account: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a FutureBuilder to run the account check when the widget builds
    return FutureBuilder<void>(
      future: checkAccountAndNavigate(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return Container(); // Return an empty container since navigation will handle the transition
      },
    );
  }
}
