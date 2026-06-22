import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../services/disease_service.dart';
import '../../models/disease.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class DiseaseScreen extends StatefulWidget {
  const DiseaseScreen({super.key});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  final _diseaseService = DiseaseService();
  File? _selectedImage;
  DiseaseResult? _result;
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final result =
        await picker.pickImage(source: source, imageQuality: 80);
    if (result != null) {
      setState(() {
        _selectedImage = File(result.path);
        _result = null;
        _errorMessage = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _diseaseService.detectDisease(_selectedImage!);
      setState(() => _result = result);

      // Upload image and save to history
      final userId =
          context.read<ap.AuthProvider>().profile?.uid ?? '';
      if (userId.isNotEmpty) {
        final ref = FirebaseStorage.instance
            .ref('disease_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_selectedImage!);
        final imageUrl = await ref.getDownloadURL();
        await _diseaseService.saveToHistory(
          userId: userId,
          imageUrl: imageUrl,
          result: result,
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disease Detection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageSection(
              image: _selectedImage,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null && _result == null && !_isAnalyzing)
              AppButton(
                label: 'Analyze Plant',
                onPressed: _analyzeImage,
                icon: Icons.search,
              ),
            if (_isAnalyzing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 12),
                    Text('Analyzing plant image with AI...'),
                  ],
                ),
              ),
            if (_errorMessage != null)
              ErrorView(message: _errorMessage!, onRetry: _analyzeImage),
            if (_result != null)
              _ResultCard(result: _result!),
            const SizedBox(height: 24),
            const _DiseaseHistorySection(),
          ],
        ),
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final File? image;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ImageSection({
    required this.image,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.3), width: 2),
          ),
          child: image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(image!, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate,
                        size: 64,
                        color: AppColors.primary.withOpacity(0.4)),
                    const SizedBox(height: 12),
                    Text('Select or capture a plant image',
                        style: TextStyle(color: AppColors.textGrey)),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Camera',
                onPressed: onCamera,
                icon: Icons.camera_alt,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Gallery',
                onPressed: onGallery,
                isOutlined: true,
                icon: Icons.photo_library,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final DiseaseResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final isHealthy = result.isHealthy;
    final color = isHealthy ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.warning,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.diseaseName,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                    Text(
                      'Confidence: ${result.confidencePercent}',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isHealthy) ...[
            const Divider(height: 24),
            if (result.causes.isNotEmpty) ...[
              _ListSection(
                  title: '🔍 Causes',
                  items: result.causes,
                  color: AppColors.error),
              const SizedBox(height: 12),
            ],
            if (result.prevention.isNotEmpty) ...[
              _ListSection(
                  title: '🛡️ Prevention',
                  items: result.prevention,
                  color: AppColors.warning),
              const SizedBox(height: 12),
            ],
            if (result.treatments.isNotEmpty) ...[
              _ListSection(
                  title: '💊 Treatment',
                  items: result.treatments,
                  color: AppColors.success),
            ],
          ] else ...[
            const SizedBox(height: 12),
            const Text(
                '✅ Your plant looks healthy! Keep up the good care.',
                style: TextStyle(color: AppColors.success)),
          ],
        ],
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;
  final Color color;

  const _ListSection(
      {required this.title, required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 15)),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(item)),
                ],
              ),
            )),
      ],
    );
  }
}

class _DiseaseHistorySection extends StatelessWidget {
  const _DiseaseHistorySection();

  @override
  Widget build(BuildContext context) {
    final userId = context.read<ap.AuthProvider>().profile?.uid ?? '';
    if (userId.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Detection History'),
        const SizedBox(height: 8),
        StreamBuilder<List<DiseaseHistory>>(
          stream: DiseaseService().watchHistory(userId),
          builder: (_, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No detection history yet.',
                  style: TextStyle(color: AppColors.textGrey));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, i) {
                final h = snapshot.data![i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(h.imageUrl,
                        width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  title: Text(h.result.diseaseName,
                      style: const TextStyle(fontSize: 14)),
                  subtitle: Text(h.result.confidencePercent),
                  trailing: Text(
                    '${h.detectedAt.day}/${h.detectedAt.month}',
                    style:
                        TextStyle(color: AppColors.textGrey, fontSize: 12),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
