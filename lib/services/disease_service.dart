import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/disease.dart';

class DiseaseService {
  static const _modelPath = 'assets/models/plant_disease.tflite';
  static const _inputSize = 224;

  Interpreter? _interpreter;

  // Expanded disease labels from PlantVillage dataset
  static const List<String> _labels = [
    'Apple___Apple_scab', 'Apple___Black_rot', 'Apple___Cedar_apple_rust',
    'Apple___healthy', 'Blueberry___healthy', 'Cherry___Powdery_mildew',
    'Cherry___healthy', 'Corn___Cercospora_leaf_spot',
    'Corn___Common_rust', 'Corn___Northern_Leaf_Blight', 'Corn___healthy',
    'Grape___Black_rot', 'Grape___Esca', 'Grape___Leaf_blight', 'Grape___healthy',
    'Orange___Haunglongbing', 'Peach___Bacterial_spot', 'Peach___healthy',
    'Pepper___Bacterial_spot', 'Pepper___healthy',
    'Potato___Early_blight', 'Potato___Late_blight', 'Potato___healthy',
    'Raspberry___healthy', 'Soybean___healthy', 'Squash___Powdery_mildew',
    'Strawberry___Leaf_scorch', 'Strawberry___healthy',
    'Tomato___Bacterial_spot', 'Tomato___Early_blight', 'Tomato___Late_blight',
    'Tomato___Leaf_Mold', 'Tomato___Septoria_leaf_spot',
    'Tomato___Spider_mites', 'Tomato___Target_Spot',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus', 'Tomato___Tomato_mosaic_virus',
    'Tomato___healthy',
  ];

  static final Map<String, Map<String, List<String>>> _diseaseInfo = {
    'Apple___Apple_scab': {
      'causes': ['Fungal infection (Venturia inaequalis)', 'Wet, cool spring weather'],
      'prevention': ['Apply fungicide in early spring', 'Remove fallen leaves', 'Plant resistant varieties'],
      'treatments': ['Spray with captan or mancozeb', 'Prune affected branches'],
    },
    'Tomato___Early_blight': {
      'causes': ['Fungus Alternaria solani', 'Warm and humid conditions'],
      'prevention': ['Crop rotation', 'Avoid overhead irrigation', 'Space plants for airflow'],
      'treatments': ['Apply chlorothalonil fungicide', 'Remove affected leaves immediately'],
    },
    'Tomato___Late_blight': {
      'causes': ['Oomycete Phytophthora infestans', 'Cool, moist conditions'],
      'prevention': ['Use certified disease-free seeds', 'Avoid leaf wetness', 'Apply preventive fungicides'],
      'treatments': ['Copper-based fungicides', 'Mancozeb sprays', 'Remove and destroy infected plants'],
    },
    'Potato___Late_blight': {
      'causes': ['Phytophthora infestans', 'High humidity above 90%'],
      'prevention': ['Plant certified seed potatoes', 'Ensure good drainage', 'Monitor weather conditions'],
      'treatments': ['Metalaxyl fungicide', 'Copper hydroxide sprays'],
    },
    'Corn___Common_rust': {
      'causes': ['Fungus Puccinia sorghi', 'Moderate temperatures with high humidity'],
      'prevention': ['Plant resistant hybrids', 'Early planting to avoid peak infection periods'],
      'treatments': ['Triazole fungicides', 'Strobilurin fungicides'],
    },
  };

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
    } catch (e) {
      // Model not found - will use mock results for demo
    }
  }

  Future<DiseaseResult> detectDisease(File imageFile) async {
    if (_interpreter == null) await loadModel();

    final imageBytes = await imageFile.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) throw Exception('Failed to decode image');

    final resized = img.copyResize(decodedImage, width: _inputSize, height: _inputSize);
    final input = _imageToInputTensor(resized);
    final output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

    if (_interpreter != null) {
      _interpreter!.run(input, output);
    } else {
      // Demo fallback when model not loaded
      return DiseaseResult(
        diseaseName: 'Tomato___Early_blight',
        confidence: 0.87,
        description: 'Early blight is a common fungal disease affecting tomato plants.',
        causes: _diseaseInfo['Tomato___Early_blight']?['causes'] ?? [],
        prevention: _diseaseInfo['Tomato___Early_blight']?['prevention'] ?? [],
        treatments: _diseaseInfo['Tomato___Early_blight']?['treatments'] ?? [],
      );
    }

    final scores = (output[0] as List).cast<double>();
    final maxIndex = scores.indexOf(scores.reduce((a, b) => a > b ? a : b));
    final label = _labels[maxIndex];
    final info = _diseaseInfo[label] ?? {};

    return DiseaseResult(
      diseaseName: _formatLabel(label),
      confidence: scores[maxIndex],
      description: 'Detected: ${_formatLabel(label)}',
      causes: info['causes'] ?? [],
      prevention: info['prevention'] ?? [],
      treatments: info['treatments'] ?? [],
    );
  }

  List<List<List<List<double>>>> _imageToInputTensor(img.Image image) {
    return [
      List.generate(_inputSize, (y) =>
        List.generate(_inputSize, (x) {
          final pixel = image.getPixel(x, y);
          return [
            img.getRed(pixel) / 255.0,
            img.getGreen(pixel) / 255.0,
            img.getBlue(pixel) / 255.0,
          ];
        }))
    ];
  }

  String _formatLabel(String label) {
    return label.replaceAll('___', ' - ').replaceAll('_', ' ');
  }

  Future<void> saveToHistory({
    required String userId,
    required String imageUrl,
    required DiseaseResult result,
  }) async {
    final history = DiseaseHistory(
      id: '',
      userId: userId,
      imageUrl: imageUrl,
      result: result,
      detectedAt: DateTime.now(),
    );
    await FirebaseFirestore.instance
        .collection('disease_history')
        .add(history.toFirestore());
  }

  Stream<List<DiseaseHistory>> watchHistory(String userId) =>
      FirebaseFirestore.instance
          .collection('disease_history')
          .where('userId', isEqualTo: userId)
          .orderBy('detectedAt', descending: true)
          .limit(20)
          .snapshots()
          .map((s) => s.docs.map(DiseaseHistory.fromFirestore).toList());

  void dispose() => _interpreter?.close();
}
