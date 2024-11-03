import 'package:flutter/material.dart';
import 'package:pill_tracker/pages/info_page.dart';
import 'package:pill_tracker/pages/monitor_email.dart';

class ChoicePage extends StatefulWidget {
  final String email;
  ChoicePage({super.key, required this.email});

  @override
  _ChoicePageState createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  bool isFirstBoxSelected = false;
  bool isSecondBoxSelected = false;

  void selectBox(int box) {
    setState(() {
      if (box == 1) {
        isFirstBoxSelected = true;
        isSecondBoxSelected = false;
      } else {
        isFirstBoxSelected = false;
        isSecondBoxSelected = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 70),
            Text(
              'What do you want?',
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: () => selectBox(1),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isFirstBoxSelected
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onPrimaryFixed,
                      blurRadius: 4,
                      offset: Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                width: double.infinity,
                height: MediaQuery.of(context).size.height *
                    0.25, // 25% of screen height
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Track Medicine',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Set up monitoring inside the app',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16), // Space between boxes
            GestureDetector(
              onTap: () => selectBox(2),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isSecondBoxSelected
                      ? Theme.of(context).colorScheme.onSecondaryContainer
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onPrimaryFixed,
                      blurRadius: 4,
                      offset: Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                width: double.infinity,
                height: MediaQuery.of(context).size.height *
                    0.25, // 25% of screen height
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Monitor Medicine',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Set up medication inside the app',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(), // Push the button to the bottom

            SizedBox(
              width: double.infinity, // Make the button stretch
              child: ElevatedButton(
                onPressed: () {
                  // Handle the Next button press
                  if (isFirstBoxSelected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InfoPage(email: widget.email)),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MonitorEmailPage(
                                email: widget.email,
                              )),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                  padding:
                      EdgeInsets.symmetric(vertical: 16), // Adjust the height
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Match the box shape
                  ),
                ),
                child: Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
