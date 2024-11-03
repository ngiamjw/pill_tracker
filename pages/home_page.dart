import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pill_tracker/classes/global_variables.dart';
import 'package:pill_tracker/components/my_display_container.dart';
import 'package:pill_tracker/pages/profile.dart';
import 'package:pill_tracker/pages/settings.dart';
import 'package:pill_tracker/services/firebase.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String email;
  HomePage({super.key, required this.email});

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

  Future<void> _openCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  int currentIndex = 1;

  List<Map<String, dynamic>> medications = [];
  String emergencyContactName = "";
  String emergencyContactPhone = "";
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final model =
      FirebaseVertexAI.instance.generativeModel(model: 'gemini-1.5-flash');

  int x = 0;

  List<Color> _containerColors = [];
  List<int> x_list = [];
  void _changeColor(int index, CounterModel counterModel) {
    setState(() {
      // Toggle the color at the specified index
      counterModel.containerColors[index] =
          counterModel.containerColors[index] ==
                  Theme.of(context).colorScheme.onPrimaryContainer
              ? Theme.of(context).colorScheme.onSecondaryContainer
              : Theme.of(context).colorScheme.onPrimaryContainer;

      if (counterModel.containerColors[index] ==
          Theme.of(context).colorScheme.onPrimaryContainer) {
        counterModel.x -= x_list[index];
      } else {
        counterModel.x += x_list[index];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CounterModel counterModel = Provider.of<CounterModel>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: Stack(
        // Use a Stack here
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: firestoreService.getUserStream(widget.email),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                medications = (userData['medications'] as List)
                    .map((item) => item as Map<String, dynamic>)
                    .toList();

                if (counterModel.containerColors.length != medications.length) {
                  _containerColors = List<Color>.filled(
                    medications.length,
                    Theme.of(context).colorScheme.onPrimaryContainer,
                  );
                  counterModel.containerColors = _containerColors;
                }

                if (x_list.length != medications.length) {
                  x_list =
                      medications.map((med) => med['doses'] as int).toList();
                }
                int y = medications.fold<int>(
                  0,
                  (sum, med) =>
                      sum +
                      ((med['time'] == getTiming())
                          ? (med['doses'] as int)
                          : 0),
                );

                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20), // Add some space
                      Text(
                        getTiming(), // Call a function to get the current timing
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        "Doses",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 25),
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 4,
                              offset:
                                  Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Doses Taken", style: TextStyle(fontSize: 18)),
                            Text("${counterModel.x}/${y}",
                                style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Expanded(
                        child: ListView.builder(
                          itemCount: medications.length,
                          itemBuilder: (context, index) {
                            var med = medications[index];
                            return med['time']
                                    .contains(getTiming()) // Filter by timing
                                ? GestureDetector(
                                    onTap: () =>
                                        _changeColor(index, counterModel),
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color:
                                            counterModel.containerColors[index],
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryFixed,
                                            blurRadius: 4,
                                            offset: Offset(0,
                                                2), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            med['medicine'],
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          Text(med['doses'].toString(),
                                              style: TextStyle(fontSize: 18)),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox
                                    .shrink(); // Hide if timing doesn't match
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            bottom: 70, // Adjust based on your layout
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                // Define your action here
                _openCamera();
                // Provide a prompt that contains text
                // Provide a text prompt to include with the image
                final prompt = TextPart(
                    "Can you identify any small round objects in the picture? The response must only return an integer and nothing else, there must also only be 1 response. There must strictly be no more than 1 response.");
                // Prepare images for input
                print('work lah nigga');
                print(_image);
                if (_image != null) {
                  final image = await _image!.readAsBytes();
                  final imagePart = InlineDataPart('image/jpeg', image);
                  print('pls work');
                  final response = await model.generateContentStream([
                    Content.multi([prompt, imagePart])
                  ]);
                  print("testtt");
                  await for (final chunk in response) {
                    print(chunk.text);
                    print("hiiiiii");
                  }
                  print('test overrr');
                }
              },
              child: Icon(Icons.camera),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue), // Highlight home
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
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
                          emergencyContactName: emergencyContactName,
                          emergencyContactPhone: emergencyContactPhone,
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
                          emergencyContactName: emergencyContactName,
                          emergencyContactPhone: emergencyContactPhone,
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
