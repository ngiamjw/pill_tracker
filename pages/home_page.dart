import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pill_tracker/classes/global_variables.dart';
import 'package:pill_tracker/components/first_box.dart';
import 'package:pill_tracker/components/medicine_container.dart';
import 'package:pill_tracker/components/my_display_container.dart';
import 'package:pill_tracker/pages/profile.dart';
import 'package:pill_tracker/pages/settings.dart';
import 'package:pill_tracker/services/firebase.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String email;
  HomePage({
    super.key,
    required this.email,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Assuming you pass the user's email to this widget
  final FirestoreService firestoreService = FirestoreService();

  String getTiming() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) {
      return "Morning";
    } else if (hour >= 10 && hour < 16) {
      return "Afternoon";
    } else if (hour >= 16 && hour < 18) {
      return "Evening";
    } else {
      return "Night";
    }
  }

  int calculateDoses(List<dynamic> medications) {
    // Sum of doses where time matches getTiming() and taken['value'] is true
    int sum = medications
        .where((medication) =>
            medication['taken']['value'] == true &&
            medication['time'].contains(getTiming()))
        .fold(0, (total, medication) => total + (medication['doses'] as int));
    return sum;
  }

  int currentIndex = 1;

  List<Map<String, dynamic>> medications = [];

  int x = 0;

  List<Color> _containerColors = [];
  List<int> x_list = [];
  void _changeColor(int index, bool value, String email) {
    if (email == widget.email) {
      firestoreService.updateMedicationTaken(
          email: widget.email,
          index: index,
          value: !value,
          time: DateTime.now());
    }
  }

  void resetMedicationStatus(
      List<Map<String, dynamic>> medications, String email) {
    DateTime today = DateTime.now();

    for (var medication in medications) {
      Map<String, dynamic> taken = medication['taken'];
      Timestamp time = taken['date'];

      DateTime date = time.toDate(); // Convert Timestamp to DateTime

      // Check if the date does not match today's date
      if (date.year != today.year ||
          date.month != today.month ||
          date.day != today.day) {
        if (taken['value'] == true) {
          taken['value'] = false;
        }
      }
    }
    firestoreService.updateAllMedicationTaken(
        email: email, medications: medications);
  }

  String? selectedEmail;
  @override
  Widget build(BuildContext context) {
    CounterModel counterModel = Provider.of<CounterModel>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(48, 224, 232, 255),
        actions: [
          Container(
            child: CircleAvatar(
              radius: 30,
              child: Text(
                widget.email.substring(0, 2).toUpperCase(),
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          SizedBox(
            width: 16,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(47, 230, 236, 255), // Start color
              Colors.grey.shade100, // End color
            ],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getUserStream(widget.email),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> requested_users = [widget.email];
                requested_users.addAll(userData['requested_users']);

                selectedEmail ??=
                    requested_users.isNotEmpty ? requested_users[0] : null;

                return ListView(
                  // Use a Stack here
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Center(
                      child: Text(
                        "Good ${getTiming()}", // Call a function to get the current timing
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    if (requested_users.isNotEmpty)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("currently viewing"),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButton<String>(
                                value: selectedEmail,
                                items: requested_users
                                    .map<DropdownMenuItem<String>>((userEmail) {
                                  return DropdownMenuItem<String>(
                                    value: userEmail,
                                    child: Text(userEmail),
                                  );
                                }).toList(),
                                onChanged: (newEmail) {
                                  setState(() {
                                    selectedEmail = newEmail;
                                    print(selectedEmail);
                                  });
                                },
                              ),
                            ),
                          ]),
                    if (selectedEmail != null)
                      StreamBuilder<DocumentSnapshot>(
                        stream: firestoreService.getUserStream(selectedEmail!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            medications = (userData['medications'] as List)
                                .map((item) => item as Map<String, dynamic>)
                                .toList();

                            resetMedicationStatus(medications, selectedEmail!);

                            if (counterModel.containerColors.length !=
                                medications.length) {
                              _containerColors = List<Color>.filled(
                                medications.length,
                                Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              );
                              counterModel.containerColors = _containerColors;
                            }

                            var permissions =
                                userData['permissions'] as List<dynamic>;

                            int y = medications.fold<int>(
                              0,
                              (sum, med) =>
                                  sum +
                                  ((med['time'] == getTiming())
                                      ? (med['doses'] as int)
                                      : 0),
                            );

                            int x = calculateDoses(medications);

                            if ((permissions.contains(widget.email) ||
                                    widget.email == selectedEmail) &&
                                medications.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    FirstBox(x: x, y: y),
                                    const SizedBox(height: 25),
                                    SizedBox(
                                      height: 200,
                                      width: 400,
                                      child: Expanded(
                                        child: ListView.builder(
                                          itemCount: medications.length,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            var med = medications[index];
                                            return med['time'].contains(
                                                    getTiming()) // Filter by timing
                                                ? GestureDetector(
                                                    onTap: () => _changeColor(
                                                        index,
                                                        medications[index]
                                                            ['taken']['value'],
                                                        selectedEmail!),
                                                    child: MedicineContainer(
                                                        amt: med['doses'],
                                                        color:
                                                            medications[index]
                                                                    ['taken']
                                                                ['value'],
                                                        name: med['medicine']))
                                                : SizedBox
                                                    .shrink(); // Hide if timing doesn't match
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else if (medications.isEmpty) {
                              return Center(child: Text("No medication data"));
                            } else {
                              return Center(
                                  child: Text(
                                      "Please wait for user to allow request"));
                            }
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                  ],
                );
              }
            }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.secondary,
              size: 30,
            ),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              color: Colors.blue,
              size: 30,
            ), // Highlight home
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              color: Theme.of(context).colorScheme.secondary,
              size: 30,
            ),
            label: 'Profile',
          ),
        ], // Set to the index of the home icon
        onTap: (index) {
          // Handle navigation based on the selected index
          setState(() {
            currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(
                          email: widget.email,
                          medications: medications,
                        )),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          email: widget.email,
                          medications: medications,
                        )),
              );
              break;
            // No action needed for Home (current index)
          }
        },
      ),
    );
  }
}
