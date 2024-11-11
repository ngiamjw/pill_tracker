import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pill_tracker/auth/auth.dart';
import 'package:pill_tracker/auth/login_or_register.dart';
import 'package:pill_tracker/components/my_display_container.dart';
import 'package:pill_tracker/pages/home_page.dart';
import 'package:pill_tracker/pages/profile.dart';
import 'package:pill_tracker/services/firebase.dart';
import 'package:pill_tracker/services/light_storage.dart';
import 'package:pill_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  final String email;
  List<Map<String, dynamic>> medications;

  SettingsPage({super.key, required this.email, required this.medications});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController monitorcontroller = TextEditingController();
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Circle with abbreviated email
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    widget.email.substring(0, 2).toUpperCase(),
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                SizedBox(width: 45),
                // Full email
                Text(
                  widget.email,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 40),

            // Logout box

            MyDisplayContainer(
                left: Text(
                  'Logout',
                  style: TextStyle(fontSize: 16),
                ),
                right: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Placeholder for logout action
                                  FirebaseAuth.instance.signOut();
                                  clearAllData();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => AuthPage()),
                                    (route) => false,
                                  );
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(Icons.logout,
                        color: Theme.of(context).colorScheme.secondary))),

            SizedBox(
              height: 20,
            ),

            MyDisplayContainer(
              left: Text(
                'Dark Mode',
                style: TextStyle(fontSize: 16),
              ),
              right: Switch(
                value: false,
                onChanged: (value) {
                  // Placeholder for dark mode action
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
              ),
            ),

            SizedBox(
              height: 20,
            ),

            MyDisplayContainer(
                left: Text(
                  'Monitor Users',
                  style: TextStyle(fontSize: 16),
                ),
                right: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Center(
                              child: Text(
                                'User Email',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            content: TextField(
                              controller: monitorcontroller,
                              decoration: InputDecoration(
                                hintText: 'Enter email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                              ),
                            ),
                            actions: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      // Add button action here
                                      firestoreService.updateRequestedUsers(
                                          email: widget.email,
                                          request_email:
                                              monitorcontroller.text);
                                      firestoreService.updateRequest(
                                          email: monitorcontroller.text,
                                          requester_email: widget.email);
                                      addUserToRequestedUsers(
                                          monitorcontroller.text);

                                      Navigator.pop(context);
                                      monitorcontroller.clear();
                                    },
                                    child: Text('Add'),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Icon(Icons.add,
                        color: Theme.of(context).colorScheme.secondary))),

            SizedBox(
              height: 20,
            ),

            StreamBuilder<DocumentSnapshot>(
              stream: firestoreService.getUserStream(widget.email),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  var requestList = userData['request'] as List<dynamic>?;

                  if (requestList == null || requestList.isEmpty) {
                    return Container();
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "User Requests",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 250,
                          width: 400,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: requestList.length,
                            itemBuilder: (context, index) {
                              var request = requestList[index];
                              return MyDisplayContainer(
                                left: Text(request),
                                right: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 80, // Set width of Allow button
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // TODO: Add allow action here
                                          firestoreService.updatePermissions(
                                              email: widget.email,
                                              request_email: request);

                                          firestoreService.removeRequest(
                                              email: widget.email,
                                              requestEmail: request);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer, // Background color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Rounded corners
                                          ),
                                        ),
                                        child: Text(
                                          'Allow',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 8), // Spacing between buttons
                                    SizedBox(
                                      width: 80, // Set width of Reject button
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // TODO: Add reject action here
                                          firestoreService.removeRequest(
                                              email: widget.email,
                                              requestEmail: request);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .onTertiaryContainer, // Background color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Rounded corners
                                          ),
                                        ),
                                        child: Text(
                                          'Reject',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .inversePrimary),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.blue),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Highlight home
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
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          email: widget.email,
                        )),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfilePage(
                          email: widget.email,
                          medications: widget.medications,
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
