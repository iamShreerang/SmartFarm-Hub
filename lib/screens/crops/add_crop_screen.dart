import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../providers/crop_provider.dart';
import '../../models/crop.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddCropScreen extends StatefulWidget {
  final Crop? crop; // if editing
  const AddCropScreen({super.key, this.crop});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();

  DateTime _plantingDate = DateTime.now();
  DateTime _harvestDate = DateTime.now().add(const Duration(days: 90));
  GrowthStage _growthStage = GrowthStage.seedling;
  List<File> _newImages = [];

  bool get _isEditing => widget.crop != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.crop!;
      _nameCtrl.text = c.name;
      _notesCtrl.text = c.notes ?? '';
      _locationCtrl.text = c.location ?? '';
      _areaCtrl.text = c.areaSize?.toString() ?? '';
      _plantingDate = c.plantingDate;
      _harvestDate = c.expectedHarvestDate;
      _growthStage = c.growthStage;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _locationCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (result != null) {
      setState(() => _newImages.add(File(result.path)));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<ap.AuthProvider>().profile!.uid;
    final cropProvider = context.read<CropProvider>();

    bool success;
    if (_isEditing) {
      final updated = widget.crop!.copyWith(
        name: _nameCtrl.text.trim(),
        plantingDate: _plantingDate,
        expectedHarvestDate: _harvestDate,
        growthStage: _growthStage,
        notes: _notesCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        areaSize: double.tryParse(_areaCtrl.text),
      );
      success = await cropProvider.updateCrop(updated);
    } else {
      success = await cropProvider.addCrop(
        userId: userId,
        name: _nameCtrl.text.trim(),
        plantingDate: _plantingDate,
        expectedHarvestDate: _harvestDate,
        growthStage: _growthStage,
        notes: _notesCtrl.text.trim(),
        imageFiles: _newImages,
        location: _locationCtrl.text.trim(),
        areaSize: double.tryParse(_areaCtrl.text),
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Crop updated successfully!'
              : 'Crop added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cropProvider.errorMessage ?? 'Failed to save crop'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _selectDate(bool isPlanting) async {
    final initial = isPlanting ? _plantingDate : _harvestDate;
    final first = isPlanting ? DateTime(2000) : _plantingDate;
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() {
        if (isPlanting) {
          _plantingDate = result;
          if (_harvestDate.isBefore(_plantingDate)) {
            _harvestDate = _plantingDate.add(const Duration(days: 90));
          }
        } else {
          _harvestDate = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final crops = context.watch<CropProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Crop' : 'Add Crop'),
      ),
      body: LoadingOverlay(
        isLoading: crops.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  hintText: 'e.g. Tomatoes, Wheat, Corn',
                  labelText: 'Crop Name *',
                  controller: _nameCtrl,
                  prefixIcon: Icons.grass,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Crop name is required' : null,
                ),
                const SizedBox(height: 16),
                _DateField(
                  label: 'Planting Date',
                  date: _plantingDate,
                  onTap: () => _selectDate(true),
                ),
                const SizedBox(height: 12),
                _DateField(
                  label: 'Expected Harvest Date',
                  date: _harvestDate,
                  onTap: () => _selectDate(false),
                ),
                const SizedBox(height: 16),
                const Text('Growth Stage',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _GrowthStageSelector(
                  selected: _growthStage,
                  onChanged: (s) => setState(() => _growthStage = s),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  hintText: 'e.g. Field A, North Plot',
                  labelText: 'Location (Optional)',
                  controller: _locationCtrl,
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hintText: 'e.g. 2.5',
                  labelText: 'Area Size in Acres (Optional)',
                  controller: _areaCtrl,
                  prefixIcon: Icons.square_foot,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  hintText: 'Any additional notes about this crop...',
                  labelText: 'Notes (Optional)',
                  controller: _notesCtrl,
                  prefixIcon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Photos (Optional)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _ImagePicker(
                  images: _newImages,
                  onAdd: _pickImage,
                  onRemove: (i) =>
                      setState(() => _newImages.removeAt(i)),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: _isEditing ? 'Update Crop' : 'Add Crop',
                  onPressed: _save,
                  isLoading: crops.isLoading,
                  icon: _isEditing ? Icons.edit : Icons.add,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateField(
      {required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(DateFormat('dd MMM yyyy').format(date)),
      ),
    );
  }
}

class _GrowthStageSelector extends StatelessWidget {
  final GrowthStage selected;
  final ValueChanged<GrowthStage> onChanged;

  const _GrowthStageSelector(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: GrowthStage.values.map((stage) {
        final isSelected = stage == selected;
        return ChoiceChip(
          label: Text(stage.name),
          selected: isSelected,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textDark),
          onSelected: (_) => onChanged(stage),
        );
      }).toList(),
    );
  }
}

class _ImagePicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _ImagePicker(
      {required this.images,
      required this.onAdd,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...images.asMap().entries.map(
              (e) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(e.value,
                        width: 80, height: 80, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => onRemove(e.key),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        if (images.length < 5)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.add_photo_alternate, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
