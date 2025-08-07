// lib/screens/favorite_pumps_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritePumpsScreen extends StatefulWidget {
  @override
  _FavoritePumpsScreenState createState() => _FavoritePumpsScreenState();
}

class _FavoritePumpsScreenState extends State<FavoritePumpsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _removeFavorite(String pumpId) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(pumpId)
          .delete()
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from favorites.')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing from favorites.')),
        );
        print("Error removing favorite: $error");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Petrol Pumps'),
      ),
      body: user == null
          ? Center(child: Text('Not logged in'))
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No favorite pumps saved yet.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(data['name'] ?? 'Unknown'),
                  subtitle: Text(data['address'] ?? 'No address'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () => _removeFavorite(document.id),
                  ),
                  onTap: () {
                    // You can navigate to the details screen of this pump if needed
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailsScreen(pump: ...)));
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}