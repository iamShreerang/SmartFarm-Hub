import 'package:cloud_firestore/cloud_firestore.dart';

class DiseaseResult {
  final String diseaseName;
  final double confidence; // 0.0 - 1.0
  final String description;
  final List<String> causes;
  final List<String> prevention;
  final List<String> treatments;

  DiseaseResult({
    required this.diseaseName,
    required this.confidence,
    required this.description,
    this.causes = const [],
    this.prevention = const [],
    this.treatments = const [],
  });

  bool get isHealthy => diseaseName.toLowerCase().contains('healthy');
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}

class DiseaseHistory {
  final String id;
  final String userId;
  final String imageUrl;
  final DiseaseResult result;
  final DateTime detectedAt;

  DiseaseHistory({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.result,
    required this.detectedAt,
  });

  factory DiseaseHistory.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final r = d['result'] as Map<String, dynamic>;
    return DiseaseHistory(
      id: doc.id,
      userId: d['userId'],
      imageUrl: d['imageUrl'],
      result: DiseaseResult(
        diseaseName: r['diseaseName'],
        confidence: (r['confidence'] as num).toDouble(),
        description: r['description'] ?? '',
        causes: List<String>.from(r['causes'] ?? []),
        prevention: List<String>.from(r['prevention'] ?? []),
        treatments: List<String>.from(r['treatments'] ?? []),
      ),
      detectedAt: (d['detectedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'imageUrl': imageUrl,
        'result': {
          'diseaseName': result.diseaseName,
          'confidence': result.confidence,
          'description': result.description,
          'causes': result.causes,
          'prevention': result.prevention,
          'treatments': result.treatments,
        },
        'detectedAt': Timestamp.fromDate(detectedAt),
      };
}
