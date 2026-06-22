import 'package:cloud_firestore/cloud_firestore.dart';

enum GrowthStage { seedling, vegetative, flowering, fruiting, harvesting, dormant }

class Crop {
  final String id;
  final String userId;
  final String name;
  final DateTime plantingDate;
  final DateTime expectedHarvestDate;
  final GrowthStage growthStage;
  final String? notes;
  final List<String> imageUrls;
  final String? location;
  final double? areaSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  Crop({
    required this.id,
    required this.userId,
    required this.name,
    required this.plantingDate,
    required this.expectedHarvestDate,
    this.growthStage = GrowthStage.seedling,
    this.notes,
    this.imageUrls = const [],
    this.location,
    this.areaSize,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Crop.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Crop(
      id: doc.id,
      userId: d['userId'] ?? '',
      name: d['name'] ?? '',
      plantingDate: (d['plantingDate'] as Timestamp).toDate(),
      expectedHarvestDate: (d['expectedHarvestDate'] as Timestamp).toDate(),
      growthStage: GrowthStage.values.firstWhere(
        (e) => e.name == d['growthStage'],
        orElse: () => GrowthStage.seedling,
      ),
      notes: d['notes'],
      imageUrls: List<String>.from(d['imageUrls'] ?? []),
      location: d['location'],
      areaSize: (d['areaSize'] as num?)?.toDouble(),
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      updatedAt: (d['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'name': name,
        'plantingDate': Timestamp.fromDate(plantingDate),
        'expectedHarvestDate': Timestamp.fromDate(expectedHarvestDate),
        'growthStage': growthStage.name,
        'notes': notes,
        'imageUrls': imageUrls,
        'location': location,
        'areaSize': areaSize,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  int get daysToHarvest =>
      expectedHarvestDate.difference(DateTime.now()).inDays;

  int get daysSincePlanting =>
      DateTime.now().difference(plantingDate).inDays;

  double get growthProgress {
    final total = expectedHarvestDate.difference(plantingDate).inDays;
    if (total <= 0) return 1.0;
    return (daysSincePlanting / total).clamp(0.0, 1.0);
  }

  Crop copyWith({
    String? name,
    DateTime? plantingDate,
    DateTime? expectedHarvestDate,
    GrowthStage? growthStage,
    String? notes,
    List<String>? imageUrls,
    String? location,
    double? areaSize,
  }) =>
      Crop(
        id: id,
        userId: userId,
        name: name ?? this.name,
        plantingDate: plantingDate ?? this.plantingDate,
        expectedHarvestDate: expectedHarvestDate ?? this.expectedHarvestDate,
        growthStage: growthStage ?? this.growthStage,
        notes: notes ?? this.notes,
        imageUrls: imageUrls ?? this.imageUrls,
        location: location ?? this.location,
        areaSize: areaSize ?? this.areaSize,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}
