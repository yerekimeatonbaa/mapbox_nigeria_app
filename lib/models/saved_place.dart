class SavedPlace {
  final int? id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String category;
  final DateTime createdAt;

  SavedPlace({
    this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedPlace.fromMap(Map<String, dynamic> map) {
    return SavedPlace(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
