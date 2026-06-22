import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final int? age;
  final String? location;
  final double? farmSize; // in acres
  final String? farmingType; // organic, conventional, mixed
  final List<String> cropsGrown;
  final String? profileImageUrl;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.location,
    this.farmSize,
    this.farmingType,
    this.cropsGrown = const [],
    this.profileImageUrl,
    required this.createdAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      age: data['age'],
      location: data['location'],
      farmSize: (data['farmSize'] as num?)?.toDouble(),
      farmingType: data['farmingType'],
      cropsGrown: List<String>.from(data['cropsGrown'] ?? []),
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'age': age,
        'location': location,
        'farmSize': farmSize,
        'farmingType': farmingType,
        'cropsGrown': cropsGrown,
        'profileImageUrl': profileImageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserProfile copyWith({
    String? name,
    int? age,
    String? location,
    double? farmSize,
    String? farmingType,
    List<String>? cropsGrown,
    String? profileImageUrl,
  }) =>
      UserProfile(
        uid: uid,
        name: name ?? this.name,
        email: email,
        age: age ?? this.age,
        location: location ?? this.location,
        farmSize: farmSize ?? this.farmSize,
        farmingType: farmingType ?? this.farmingType,
        cropsGrown: cropsGrown ?? this.cropsGrown,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        createdAt: createdAt,
      );
}
