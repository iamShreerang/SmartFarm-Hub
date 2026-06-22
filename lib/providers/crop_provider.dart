import 'dart:io';
import 'package:flutter/material.dart';
import '../models/crop.dart';
import '../services/crop_service.dart';
import 'package:uuid/uuid.dart';

class CropProvider extends ChangeNotifier {
  final _cropService = CropService();
  final _uuid = const Uuid();

  List<Crop> _crops = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Crop> get crops => _crops;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Crop> get upcomingHarvests => _crops
      .where((c) => c.daysToHarvest >= 0 && c.daysToHarvest <= 14)
      .toList()
    ..sort((a, b) => a.daysToHarvest.compareTo(b.daysToHarvest));

  void watchCrops(String userId) {
    _cropService.watchCrops(userId).listen((crops) {
      _crops = crops;
      notifyListeners();
    });
  }

  Future<bool> addCrop({
    required String userId,
    required String name,
    required DateTime plantingDate,
    required DateTime expectedHarvestDate,
    GrowthStage growthStage = GrowthStage.seedling,
    String? notes,
    List<File> imageFiles = const [],
    String? location,
    double? areaSize,
  }) async {
    _setLoading(true);
    try {
      final imageUrls = <String>[];
      for (final file in imageFiles) {
        final url = await _cropService.uploadCropImage(userId, file);
        imageUrls.add(url);
      }
      final now = DateTime.now();
      final crop = Crop(
        id: _uuid.v4(),
        userId: userId,
        name: name,
        plantingDate: plantingDate,
        expectedHarvestDate: expectedHarvestDate,
        growthStage: growthStage,
        notes: notes,
        imageUrls: imageUrls,
        location: location,
        areaSize: areaSize,
        createdAt: now,
        updatedAt: now,
      );
      await _cropService.addCrop(crop);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCrop(Crop crop) async {
    _setLoading(true);
    try {
      await _cropService.updateCrop(crop);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCrop(Crop crop) async {
    try {
      await _cropService.deleteCrop(crop.id, crop.imageUrls);
      _clearError();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() => _errorMessage = null;
}
