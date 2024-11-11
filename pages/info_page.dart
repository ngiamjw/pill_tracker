import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pill_tracker/components/error_display.dart';
import 'package:pill_tracker/pages/home_page.dart';
import 'package:pill_tracker/services/firebase.dart';

class InfoPage extends StatefulWidget {
  final String email;
  InfoPage({super.key, required this.email});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List<Map<String, dynamic>> medications = [
    {
      'time': null,
      'doses': null,
      'medicine': '',
      'taken': {'value': false, 'date': DateTime.now()}
    }
  ];
  String? emergencyContactName;
  String? emergencyContactPhone;

  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Center(child: Text("Information")),
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
                  if (medications.isNotEmpty)
                    Text("Daily Medication",
                        style: TextStyle(fontWeight: FontWeight.bold)),

                  // List of Medication Boxes
                  ...medications.map((med) => MedicationBox(
                        medication: med,
                        onRemove: () {
                          setState(() {
                            medications.remove(med);
                          });
                        },
                      )),

                  // Add new medication box button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        medications.add({
                          'time': null,
                          'doses': null,
                          'medicine': '',
                          'taken': {'value': false, 'date': DateTime.now()}
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
                bool areMedicationsValid = medications.isNotEmpty &&
                    medications.every((med) =>
                        med['time'] != null &&
                        med['doses'] != null &&
                        med['medicine'] != '');

                // Final validation
                if (areMedicationsValid) {
                  firestoreService.addUser(
                      email: widget.email, medications: medications);

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => HomePage(email: widget.email)),
                  );
                } else {
                  displayErrorMessage("missing information", context);
                }
              },
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ],
        ),
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
                          color: Colors.white, fontWeight: FontWeight.bold),
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
