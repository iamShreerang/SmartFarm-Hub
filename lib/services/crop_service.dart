import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/crop.dart';

class CropService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  CollectionReference get _crops => _firestore.collection('crops');

  Stream<List<Crop>> watchCrops(String userId) => _crops
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Crop.fromFirestore).toList());

  Future<Crop> addCrop(Crop crop) async {
    final docRef = await _crops.add(crop.toFirestore());
    return crop.copyWith();
  }

  Future<void> updateCrop(Crop crop) =>
      _crops.doc(crop.id).update(crop.toFirestore());

  Future<void> deleteCrop(String cropId, List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await _storage.refFromURL(url).delete();
      } catch (_) {}
    }
    await _crops.doc(cropId).delete();
  }

  Future<String> uploadCropImage(String userId, File imageFile) async {
    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage.ref('crop_images/$userId/$fileName');
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }
}
