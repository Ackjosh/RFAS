// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import '../services/petrolpumpservice.dart';
import '../utils/distance_calculator.dart' as my_distance_calculator;
import 'fuel_history_screen.dart';
import 'favorite_pumps_screen.dart';
import 'details_screen.dart'; // Import the details screen
import '../models/pump.dart'; // Import the Pump model
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreenContent(), // Your existing HomeScreen map and pump info
    FuelHistoryScreen(),
    FavoritePumpsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Petrol Pumps', style: TextStyle(fontWeight: FontWeight.bold)),
        // You might want to add actions here if needed, like a logout button
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station),
            label: 'Pumps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  String _locationMessage = 'Fetching location...';
  List<Map<String, dynamic>> _petrolPumps = [];
  LatLng? _currentLocation;
  Map<String, dynamic>? _selectedPump;
  List<Marker> _markers = [];
  bool _isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await LocationService().getCurrentLocation();
      if (mounted) {
        setState(() {
          _locationMessage = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
      _getNearbyPumps(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getNearbyPumps(double lat, double lng) async {
    try {
      List<Map<String, dynamic>> nearbyPumps = await PetrolPumpService().getNearbyPumps(lat, lng);
      nearbyPumps.sort((a, b) => my_distance_calculator.DistanceCalculator
          .calculateDistance(lat, lng, a['latitude'], a['longitude'])
          .compareTo(
          my_distance_calculator.DistanceCalculator.calculateDistance(lat, lng, b['latitude'], b['longitude'])));

      if (mounted) {
        setState(() {
          _petrolPumps = nearbyPumps;
          _updateMarkers();
          _isLoading = false; // Set loading to false after data is fetched
        });
      }
    } catch (e) {
      print("Error fetching pumps: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateMarkers() {
    _markers = [
      Marker(
        point: _currentLocation!,
        width: 40,
        height: 40,
        child: Icon(Icons.location_on, color: Colors.red, size: 40),
      ),
      ..._petrolPumps.map((pump) => Marker(
        point: LatLng(pump['latitude'], pump['longitude']),
        width: 40,
        height: 40,
        child: IconButton(
          icon: Icon(Icons.local_gas_station, color: Colors.blue, size: 30),
          onPressed: () => _showPumpInfo(pump),
        ),
      )),
    ];
  }

  void _showPumpInfo(Map<String, dynamic> pump) {
    if (mounted) {
      setState(() {
        _selectedPump = pump;
      });
    }
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  Future<void> _addToFavorites(Map<String, dynamic> pump) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(pump['id'] ?? pump['name'])
            .set({
          'name': pump['name'],
          'address': pump['address'],
          'latitude': pump['latitude'],
          'longitude': pump['longitude'],
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${pump['name']} added to favorites.')),
        );
        setState(() {
          if (_selectedPump != null) {
            _selectedPump = {..._selectedPump!, 'isFavorite': true};
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to favorites.')),
        );
        print("Error adding to favorites: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _currentLocation == null
            ? Center(child: CircularProgressIndicator())
            : FlutterMap(
          options: MapOptions(
            initialCenter: _currentLocation!,
            initialZoom: 13.0,
            onTap: (_, __) => _showPumpInfo({}),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(markers: _markers),
          ],
        ),
        if (_selectedPump != null && _selectedPump!.isNotEmpty)
          Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedPump!['name'] ?? 'Unknown',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Address: ${_selectedPump!['address'] ?? 'Unknown'}'),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.directions),
                            label: Text("Directions"),
                            onPressed: () => _openGoogleMaps(_selectedPump!['latitude'], _selectedPump!['longitude']),
                          ),
                          IconButton(
                            icon: Icon(
                              _selectedPump?['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () => _addToFavorites(_selectedPump!),
                          ),
                          ElevatedButton.icon(
                            icon: Icon(Icons.info_outline),
                            label: Text("Details"),
                            onPressed: () {
                              // Find the corresponding Pump object from _petrolPumps
                              final pumpData = _petrolPumps.firstWhere(
                                    (p) => p['latitude'] == _selectedPump!['latitude'] && p['longitude'] == _selectedPump!['longitude'],
                                orElse: () => <String, dynamic>{}, // Return an empty map as default
                              );
                              if (pumpData != null && pumpData.isNotEmpty) {
                                final pump = Pump(
                                  id: pumpData['id'] ?? pumpData['name'] ?? UniqueKey().toString(), // Ensure an ID
                                  name: pumpData['name'] ?? 'Unknown',
                                  address: pumpData['address'] ?? 'Unknown',
                                  latitude: pumpData['latitude'],
                                  longitude: pumpData['longitude'],
                                  fuelAvailability: Map<String, bool>.from(pumpData['fuelAvailability'] ?? {}), // Assuming fuelAvailability is added later
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(pump: pump),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Could not load pump details.')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
             ),
              if (_isLoading)
        Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
// lib/screens/home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../services/location_service.dart';
// import '../services/petrolpumpservice.dart';
// import '../utils/distance_calculator.dart' as my_distance_calculator;
// import 'fuel_history_screen.dart';
// import 'favorite_pumps_screen.dart';
// import 'details_screen.dart';
// import '../models/pump.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//
//   static List<Widget> _widgetOptions = <Widget>[
//     HomeScreenContent(), // This will now be the map content
//     FuelHistoryScreen(),
//     FavoritePumpsScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Nearby Petrol Pumps', style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//       body: Center(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.local_gas_station),
//             label: 'Pumps',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.history),
//             label: 'History',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite_border),
//             label: 'Favorites',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
//
// class HomeScreenContent extends StatefulWidget {
//   @override
//   _HomeScreenContentState createState() => _HomeScreenContentState();
// }
//
// class _HomeScreenContentState extends State<HomeScreenContent> {
//   String _locationMessage = 'Fetching location...';
//   List<Map<String, dynamic>> _petrolPumps = [];
//   LatLng? _currentLocation;
//   Map<String, dynamic>? _selectedPump;
//   List<Marker> _markers = [];
//   bool _isLoading = true;
//   final PetrolPumpService _petrolPumpService = PetrolPumpService();
//   static const double _locationTolerance = 0.0001;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       Position position = await LocationService().getCurrentLocation();
//       if (mounted) {
//         setState(() {
//           _locationMessage = 'Lat: ${position.latitude}, Lng: ${position.longitude}';
//           _currentLocation = LatLng(position.latitude, position.longitude);
//         });
//       }
//       _getNearbyPumps(position.latitude, position.longitude);
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _locationMessage = 'Error: $e';
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _getNearbyPumps(double lat, double lng) async {
//     try {
//       List<Map<String, dynamic>> nearbyPumps = await PetrolPumpService().getNearbyPumps(lat, lng);
//       nearbyPumps.sort((a, b) => my_distance_calculator.DistanceCalculator
//           .calculateDistance(lat, lng, a['latitude'], a['longitude'])
//           .compareTo(
//           my_distance_calculator.DistanceCalculator.calculateDistance(lat, lng, b['latitude'], b['longitude'])));
//
//       if (mounted) {
//         setState(() {
//           _petrolPumps = nearbyPumps;
//           _updateMarkers();
//           _isLoading = false; // Set loading to false after data is fetched
//         });
//       }
//     } catch (e) {
//       print("Error fetching pumps: $e");
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   void _updateMarkers() {
//     _markers = [
//       Marker(
//         point: _currentLocation!,
//         width: 40,
//         height: 40,
//         child: Icon(Icons.location_on, color: Colors.red, size: 40),
//       ),
//       ..._petrolPumps.map((pump) {
//         Color markerColor = Colors.blue;
//         if (pump['fuelAvailability'] != null && pump['fuelAvailability'].isNotEmpty) {
//           if (pump['fuelAvailability'].values.any((available) => available == true)) {
//             markerColor = Colors.green;
//           } else {
//             markerColor = Colors.orange;
//           }
//         }
//         return Marker(
//           point: LatLng(pump['latitude'], pump['longitude']),
//           width: 40,
//           height: 40,
//           child: IconButton(
//             icon: Icon(Icons.local_gas_station, color: markerColor, size: 30),
//             onPressed: () => _showPumpInfo(pump),
//           ),
//         );
//       }),
//     ];
//   }
//
//   void _showPumpInfo(Map<String, dynamic> pump) {
//     if (mounted) {
//       setState(() {
//         _selectedPump = pump;
//       });
//     }
//   }
//
//   Future<void> _openGoogleMaps(double latitude, double longitude) async {
//     final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not open Google Maps';
//     }
//   }
//
//   Future<void> _addToFavorites(Map<String, dynamic> pump) async {
//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user != null && pump['id'] != null) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .collection('favorites')
//             .doc(pump['id'])
//             .set({
//           'name': pump['name'],
//           'address': pump['address'],
//           'latitude': pump['latitude'],
//           'longitude': pump['longitude'],
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('${pump['name']} added to favorites.')),
//         );
//         setState(() {
//           if (_selectedPump != null && _selectedPump!['id'] == pump['id']) {
//             _selectedPump = {..._selectedPump!, 'isFavorite': true};
//           }
//         });
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to add to favorites.')),
//         );
//         print("Error adding to favorites: $e");
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not add to favorites (missing pump ID).')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         _currentLocation == null
//             ? Center(child: CircularProgressIndicator())
//             : FlutterMap(
//           options: MapOptions(
//             initialCenter: _currentLocation!,
//             initialZoom: 13.0,
//             onTap: (_, __) => _showPumpInfo({}),
//           ),
//           children: [
//             TileLayer(
//               urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//               userAgentPackageName: 'com.example.app',
//             ),
//             MarkerLayer(markers: _markers),
//           ],
//         ),
//         if (_selectedPump != null && _selectedPump!.isNotEmpty)
//           Positioned(
//             bottom: 10,
//             left: 10,
//             right: 10,
//             child: Card(
//               elevation: 5,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               child: Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(_selectedPump!['name'] ?? 'Unknown',
//                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                     Text('Address: ${_selectedPump!['address'] ?? 'Unknown'}'),
//                     SizedBox(height: 8),
//                     if (_selectedPump!['fuelAvailability'] != null &&
//                         _selectedPump!['fuelAvailability'].isNotEmpty)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Fuel Availability:', style: TextStyle(fontWeight: FontWeight.bold)),
//                           ...(_selectedPump!['fuelAvailability'] as Map<String, bool>).entries.map((entry) {
//                             return Text('${entry.key}: ${entry.value ? "Available" : "Out of Stock"}');
//                           }).toList(),
//                         ],
//                       ),
//                     SizedBox(height: 8),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         ElevatedButton.icon(
//                           icon: Icon(Icons.directions),
//                           label: Text("Directions"),
//                           onPressed: () => _openGoogleMaps(_selectedPump!['latitude'], _selectedPump!['longitude']),
//                         ),
//                         IconButton(
//                           icon: Icon(
//                             _selectedPump?['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
//                             color: Colors.red,
//                           ),
//                           onPressed: () => _addToFavorites(_selectedPump!),
//                         ),
//                         ElevatedButton.icon(
//                           icon: Icon(Icons.info_outline),
//                           label: Text("Details"),
//                           onPressed: () {
//                             final pumpData = _petrolPumps.firstWhere(
//                                   (p) => p['latitude'] == _selectedPump!['latitude'] && p['longitude'] == _selectedPump!['longitude'],
//                               orElse: () => <String, dynamic>{},
//                             );
//                             if (pumpData != null && pumpData.isNotEmpty) {
//                               final pump = Pump(
//                                 id: pumpData['id'] ?? pumpData['name'] ?? UniqueKey().toString(),
//                                 name: pumpData['name'] ?? 'Unknown',
//                                 address: pumpData['address'] ?? 'Unknown',
//                                 latitude: pumpData['latitude'],
//                                 longitude: pumpData['longitude'],
//                                 fuelAvailability: Map<String, bool>.from(pumpData['fuelAvailability'] ?? {}),
//                               );
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => DetailsScreen(pump: pump),
//                                 ),
//                               );
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Could not load pump details.')),
//                               );
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         if (_isLoading)
//           Center(child: CircularProgressIndicator()),
//       ],
//     );
//   }
// }