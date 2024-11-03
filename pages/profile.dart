import 'package:flutter/material.dart';
import 'package:pill_tracker/components/error_display.dart';
import 'package:pill_tracker/pages/home_page.dart';
import 'package:pill_tracker/pages/settings.dart';
import 'package:pill_tracker/services/firebase.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  List<Map<String, dynamic>> medications;
  String emergencyContactName;
  String emergencyContactPhone;

  ProfilePage(
      {super.key,
      required this.email,
      required this.medications,
      required this.emergencyContactName,
      required this.emergencyContactPhone});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int currentIndex = 2;

  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: Text("Settings")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  // Daily Medication Section Title (only once)
                  if (widget.medications.isNotEmpty)
                    Text("Daily Medication",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                  // List of Medication Boxes
                  ...widget.medications.map((med) => MedicationBox(
                        medication: med,
                        onRemove: () {
                          setState(() {
                            widget.medications.remove(med);
                          });
                        },
                      )),

                  // Add new medication box button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.medications.add({
                          'time': null,
                          'doses': null,
                          'medicine': '',
                          'taken': false
                        });
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Center(child: Text("+ Add Medication")),
                    ),
                  ),
                ],
              ),
            ),
            // Submit Button
            ElevatedButton(
              onPressed: () {
                // Check if medications is not empty and does not contain null values
                bool areMedicationsValid = widget.medications.isNotEmpty &&
                    widget.medications.every((med) =>
                        med['time'] != null &&
                        med['doses'] != null &&
                        med['medicine'] != '');

                // Check if emergency contact name and phone are not null or empty
                bool isEmergencyContactValid =
                    widget.emergencyContactName != "" &&
                        widget.emergencyContactPhone != "";

                // Final validation
                if (areMedicationsValid && isEmergencyContactValid) {
                  firestoreService.updateUser(
                    email: widget.email,
                    medications: widget.medications,
                  );
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(
                                email: widget.email,
                              )));
                } else {
                  displayErrorMessage("field cannot be empty", context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              child: Text("Apply Changes"),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ), // Highlight home
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: Colors.blue,
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
                          emergencyContactName: widget.emergencyContactName,
                          emergencyContactPhone: widget.emergencyContactPhone,
                          medications: widget.medications,
                        )),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(email: widget.email)),
              );
              break;
          }
        },
      ),
    );
  }
}

class MedicationBox extends StatefulWidget {
  final Map<String, dynamic> medication;
  final VoidCallback onRemove;

  const MedicationBox({
    required this.medication,
    required this.onRemove,
  });

  @override
  _MedicationBoxState createState() => _MedicationBoxState();
}

class _MedicationBoxState extends State<MedicationBox> {
  final List<String> times = ["Morning", "Afternoon", "Evening", "Night"];
  final List<int> doses = List.generate(10, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Medicine Name Text Input
          TextFormField(
            decoration: InputDecoration(labelText: "Medicine Name"),
            initialValue: widget.medication['medicine'],
            onChanged: (value) {
              widget.medication['medicine'] = value;
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              // Doses Dropdown
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: "Doses"),
                  value: widget.medication['doses'],
                  items: doses
                      .map((dose) => DropdownMenuItem<int>(
                            value: dose,
                            child: Text(dose.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.medication['doses'] = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 16),
              // Time Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Time"),
                  value: widget.medication['time'],
                  items: times
                      .map((time) => DropdownMenuItem<String>(
                            value: time,
                            child: Text(time),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.medication['time'] = value;
                    });
                  },
                ),
              ),
            ],
          ),
          // Remove Medication Box Button
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: Text(
                      "Remove",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
