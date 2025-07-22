import 'package:flutter/material.dart';
import '../models/pump.dart';
import '../screens/details_screen.dart';

class PumpCard extends StatelessWidget {
  final Pump pump;

  PumpCard({required this.pump});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(pump.name),
        subtitle: Text(pump.address),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            // Navigate to details screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreen(pump: pump),
              ),
            );
          },
        ),
      ),
    );
  }
}
