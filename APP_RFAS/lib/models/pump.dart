class Pump {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final Map<String, bool> fuelAvailability; // Key: Fuel Type, Value: Available or Not

  Pump({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.fuelAvailability,
  });

  // You can also add methods for JSON serialization if you're fetching this data from an API.
  factory Pump.fromJson(Map<String, dynamic> json) {
    return Pump(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      fuelAvailability: Map<String, bool>.from(json['fuelAvailability']),
    );
  }
}
