// lib/screens/fuel_history_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FuelHistoryScreen extends StatefulWidget {
  @override
  _FuelHistoryScreenState createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Usage History'),
      ),
      body: user == null
          ? Center(child: Text('Not logged in'))
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('fuel_history')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No fuel history yet.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              DateTime date = (data['date'] as Timestamp).toDate();
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${date.toLocal().toString().split(' ')[0]}', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Pump Name: ${data['pumpName'] ?? 'Unknown'}'),
                      Text('Fuel Type: ${data['fuelType'] ?? 'N/A'}'),
                      Text('Quantity: ${data['quantity'] ?? 'N/A'} liters'),
                      Text('Cost: ${data['cost'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}