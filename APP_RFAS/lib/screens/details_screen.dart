// lib/screens/details_screen.dart
import 'package:flutter/material.dart';
import '../models/pump.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsScreen extends StatefulWidget {
  final Pump pump;

  DetailsScreen({required this.pump});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  String? _selectedFuelType;

  Future<void> _recordFuelPurchase() async {
    if (_formKey.currentState!.validate() && _selectedFuelType != null) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('fuel_history')
              .add({
            'date': Timestamp.now(),
            'pumpName': widget.pump.name,
            'fuelType': _selectedFuelType,
            'quantity': double.parse(_quantityController.text),
            'cost': _costController.text.isNotEmpty ? double.tryParse(_costController.text) : null,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fuel purchase recorded.')),
          );
          Navigator.pop(context); // Go back to the previous screen
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to record fuel purchase.')),
          );
          print("Error recording fuel purchase: $e");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Not logged in. Please log in to record fuel purchase.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all the details.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pump.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${widget.pump.address}', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              Text('Fuel Availability:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...widget.pump.fuelAvailability.entries.map((entry) {
                return Text('${entry.key}: ${entry.value ? "Available" : "Out of Stock"}');
              }).toList(),
              SizedBox(height: 30),
              Text('Record Fuel Purchase', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Fuel Type'),
                      value: _selectedFuelType,
                      items: widget.pump.fuelAvailability.keys.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select fuel type';
                        }
                        return null;
                      },
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFuelType = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Quantity (liters)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _costController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: 'Cost (optional)'),
                      validator: (value) {
                        if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _recordFuelPurchase,
                      child: Text('Record Purchase'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}