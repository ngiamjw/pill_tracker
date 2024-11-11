// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pill_tracker/components/error_display.dart';
import 'package:pill_tracker/components/my_button.dart';
import 'package:pill_tracker/components/my_textfield.dart';
import 'package:pill_tracker/pages/home_page.dart';
import 'package:pill_tracker/services/firebase.dart';
import 'package:pill_tracker/services/light_storage.dart';

class MonitorEmailPage extends StatefulWidget {
  final String email;

  MonitorEmailPage({super.key, required this.email});

  @override
  State<MonitorEmailPage> createState() => _MonitorEmailPageState();
}

class _MonitorEmailPageState extends State<MonitorEmailPage> {
  TextEditingController emailcontroller = TextEditingController();

  FirestoreService firestoreService = FirestoreService();

  void send() {
    try {
      firestoreService.updateRequest(
          email: emailcontroller.text, requester_email: widget.email);
      firestoreService.addUser(email: widget.email, medications: []);

      addUserToRequestedUsers(emailcontroller.text);

      firestoreService.updateRequestedUsers(
          email: widget.email, request_email: emailcontroller.text);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(email: widget.email)),
      );
    } catch (e) {
      displayErrorMessage(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //logo
              Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(
                height: 25,
              ),

              Text(
                "P E W  T R A C K E R",
                style: TextStyle(fontSize: 20),
              ),

              const SizedBox(
                height: 25,
              ),

              MyTextfield(
                  hintText: "Email to Monitor",
                  obscureText: false,
                  controller: emailcontroller),

              const SizedBox(
                height: 25,
              ),

              MyButton(onTap: send, text: "Apply to Monitor"),

              const SizedBox(
                height: 25,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("More accounts can be added later"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
