import 'dart:math';

import 'package:http/http.dart' as http;
import 'dart:convert';
/*
class PetrolPumpService {
  // Fetch nearby petrol stations using OpenStreetMap Nominatim API
  Future<List<Map<String, dynamic>>> getNearbyPumps(double latitude, double longitude) async {
    // Radius of search in meters
    const radius = 5000;

    // Calculate bounding box based on radius
    double latMin = latitude - (radius / 111320);  // 1 degree latitude = ~111.32 km
    double latMax = latitude + (radius / 111320);
    double lonMin = longitude - (radius / (111320 * cos(latitude * pi / 180))); // Longitude varies with latitude
    double lonMax = longitude + (radius / (111320 * cos(latitude * pi / 180)));

    final url =
        'https://nominatim.openstreetmap.org/search?format=json&q=petrol+station&lat=18.4560817&lon=73.85134&bounded=1&viewbox=73.84606081280555,18.461543444890284,73.85661918719445,18.450620095773655&addressdetails=1';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        // Map the response data to a list of petrol stations
        return List<Map<String, dynamic>>.from(data.map((pump) {
          return {
            'name': pump['display_name'],
            'address': pump['display_name'], // OpenStreetMap doesn't provide a separate address field
            'latitude': double.parse(pump['lat']),
            'longitude': double.parse(pump['lon']),
          };
        }));
      } else {
        throw Exception('Failed to fetch nearby petrol stations');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}*/
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:math';
//
// class PetrolPumpService {
//   // Fetch nearby petrol stations using Overpass API
//   Future<List<Map<String, dynamic>>> getNearbyPumps(double latitude, double longitude) async {
//     const radius = 10000; // 10 km radius
//
//     // Use Overpass API to search for petrol stations
//     final query = '''
//       [out:json];
//       node["amenity"="fuel"](around:$radius,$latitude,$longitude);
//       out;
//     ''';
//
//     final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         List<Map<String, dynamic>> stations = [];
//
//         for (var element in data['elements']) {
//           if (element['lat'] != null && element['lon'] != null) {
//             // Fetch address using reverse geocoding
//             String address = await _getAddressFromCoordinates(element['lat'], element['lon']);
//
//             stations.add({
//               'name': element['tags']?['name'] ?? 'Unknown',
//               'latitude': element['lat'],
//               'longitude': element['lon'],
//               'address': address,
//             });
//           }
//         }
//
//         // Sort by distance from user location
//         stations.sort((a, b) => _calculateDistance(latitude, longitude, a['latitude'], a['longitude'])
//             .compareTo(_calculateDistance(latitude, longitude, b['latitude'], b['longitude'])));
//
//         return stations;
//       } else {
//         throw Exception('Failed to fetch petrol stations');
//       }
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }
//
//   // Fetch address using Nominatim API (reverse geocoding)
//   Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
//     final url =
//         'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';
//
//     try {
//       final response = await http.get(Uri.parse(url));
//
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         return data['display_name'] ?? 'No address available';
//       } else {
//         return 'No address available';
//       }
//     } catch (e) {
//       return 'No address available';
//     }
//   }
//
//   // Function to calculate distance using Haversine formula
//   double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//     const double earthRadius = 6371; // Earth's radius in km
//     double dLat = _toRadians(lat2 - lat1);
//     double dLon = _toRadians(lon2 - lon1);
//     double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
//             sin(dLon / 2) * sin(dLon / 2);
//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return earthRadius * c;
//   }
//
//   double _toRadians(double degree) {
//     return degree * pi / 180.0;
//   }
// }
 /*
import 'package:http/http.dart' as http;
import 'dart:convert';

class PetrolPumpService {
  final String apiKey = 'YOUR_GOOGLE_API_KEY'; // Replace with your Google API key

  // Fetch nearby petrol stations using Google Maps Places API
  Future<List<Map<String, dynamic>>> getNearbyPumps(double latitude, double longitude) async {
    const radius = 5000; // 5 km radius

    // Build the Google Places API URL for nearby search
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=gas_station&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Check if there are results
        if (data['results'].isEmpty) {
          throw Exception('No petrol stations found within 5 km.');
        }

        // Map the response data to a list of petrol stations
        List<Map<String, dynamic>> stations = List<Map<String, dynamic>>.from(data['results'].map((station) {
          return {
            'name': station['name'] ?? 'No name available',
            'address': station['vicinity'] ?? 'Address not available',
            'latitude': station['geometry']['location']['lat'],
            'longitude': station['geometry']['location']['lng'],
          };
        }));

        // Sort by distance to the current user location (optional)
        stations.sort((a, b) {
          double distanceA = _calculateDistance(latitude, longitude, a['latitude'], a['longitude']);
          double distanceB = _calculateDistance(latitude, longitude, b['latitude'], b['longitude']);
          return distanceA.compareTo(distanceB); // Sort ascending by distance (nearest first)
        });

        return stations;
      } else {
        throw Exception('Failed to fetch nearby petrol stations');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Function to calculate distance between two latitude-longitude points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the Earth in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance in km
  }

  double _toRadians(double degree) {
    return degree * pi / 180.0;
  }
}
*/



// lib/services/petrolpumpservice.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PetrolPumpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getNearbyPumpsFromFirestore() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('petrol_pumps').get(); // Replace 'petrol_pumps' with your actual collection name
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] ?? 'Unknown',
          'latitude': doc.data()['latitude'],
          'longitude': doc.data()['longitude'],
          'address': doc.data()['address'] ?? 'No address',
          'fuelAvailability': doc.data()['fuelAvailability'] as Map<String, bool>? ?? {},
        };
      }).toList();
    } catch (e) {
      print("Error fetching pumps from Firestore: $e");
      return [];
    }
  }

  // Fetch nearby petrol stations using Overpass API
  Future<List<Map<String, dynamic>>> getNearbyPumps(double latitude, double longitude) async {
    const radius = 10000; // 10 km radius

    // Use Overpass API to search for petrol stations
    final query = '''
      [out:json];
      node["amenity"="fuel"](around:$radius,$latitude,$longitude);
      out;
    ''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Map<String, dynamic>> stations = [];

        for (var element in data['elements']) {
          if (element['lat'] != null && element['lon'] != null) {
            // Fetch address using reverse geocoding
            String address = await _getAddressFromCoordinates(element['lat'], element['lon']);

            stations.add({
              'name': element['tags']?['name'] ?? 'Unknown',
              'latitude': element['lat'],
              'longitude': element['lon'],
              'address': address,
            });
          }
        }

        // Sort by distance from user location
        stations.sort((a, b) => _calculateDistance(latitude, longitude, a['latitude'], a['longitude'])
            .compareTo(_calculateDistance(latitude, longitude, b['latitude'], b['longitude'])));

        return stations;
      } else {
        throw Exception('Failed to fetch petrol stations');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fetch address using Nominatim API (reverse geocoding)
  Future<String> _getAddressFromCoordinates(double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['display_name'] ?? 'No address available';
      } else {
        return 'No address available';
      }
    } catch (e) {
      return 'No address available';
    }
  }

  // Function to calculate distance using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180.0;
  }
}