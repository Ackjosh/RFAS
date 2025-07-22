class FuelAvailability {
  final String fuelType;
  final bool isAvailable;

  FuelAvailability({
    required this.fuelType,
    required this.isAvailable,
  });

  factory FuelAvailability.fromJson(Map<String, dynamic> json) {
    return FuelAvailability(
      fuelType: json['fuelType'],
      isAvailable: json['isAvailable'],
    );
  }
}
