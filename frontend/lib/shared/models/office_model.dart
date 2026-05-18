class OfficeModel {
  const OfficeModel({
    required this.id,
    required this.name,
    required this.type,
    required this.distance,
    required this.workingHours,
    required this.isOpen,
    required this.address,
    this.lat,
    this.lng,
  });

  final String id;
  final String name;
  final String type;
  final String distance;
  final String workingHours;
  final bool isOpen;
  final String address;
  final double? lat;
  final double? lng;

  factory OfficeModel.fromJson(Map<String, dynamic> json) {
    return OfficeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      distance: json['distance'] as String,
      workingHours: json['workingHours'] as String,
      isOpen: json['isOpen'] as bool,
      address: json['address'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }
}
