import 'package:flutter/material.dart';

class MedicineContainer extends StatelessWidget {
  final bool color;
  final String name;
  final int amt;
  const MedicineContainer(
      {super.key, required this.amt, required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color
            ? Theme.of(context).colorScheme.onSecondaryContainer
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onPrimaryFixed,
            blurRadius: 4,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  AssetImage('text'), // Replace with exercise image
              radius: 24,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              name,
              style: TextStyle(fontSize: 18),
            ),
            Spacer(),
            Text(amt.toString(), style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
