import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/crop.dart';
import '../../providers/crop_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'add_crop_screen.dart';

class CropDetailScreen extends StatelessWidget {
  final Crop crop;
  const CropDetailScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(crop.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddCropScreen(crop: crop))),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Crop'),
                  content:
                      Text('Delete "${crop.name}"? This cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete',
                            style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<CropProvider>().deleteCrop(crop);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (crop.imageUrls.isNotEmpty) _ImageCarousel(urls: crop.imageUrls),
            const SizedBox(height: 16),
            _InfoCard(crop: crop),
            const SizedBox(height: 16),
            _GrowthProgressCard(crop: crop),
            if (crop.notes != null && crop.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _NotesCard(notes: crop.notes!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  final List<String> urls;
  const _ImageCarousel({required this.urls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: urls.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(urls[i], fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Crop crop;
  const _InfoCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crop Information',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            _InfoRow('Status', crop.growthStage.name.toUpperCase()),
            _InfoRow('Planted',
                DateFormat('dd MMM yyyy').format(crop.plantingDate)),
            _InfoRow('Harvest Date',
                DateFormat('dd MMM yyyy').format(crop.expectedHarvestDate)),
            if (crop.location != null && crop.location!.isNotEmpty)
              _InfoRow('Location', crop.location!),
            if (crop.areaSize != null)
              _InfoRow('Area', '${crop.areaSize} acres'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textGrey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GrowthProgressCard extends StatelessWidget {
  final Crop crop;
  const _GrowthProgressCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Growth Progress',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(crop.growthProgress * 100).toInt()}% complete'),
                Text(
                  crop.daysToHarvest >= 0
                      ? '${crop.daysToHarvest} days to harvest'
                      : 'Harvest overdue',
                  style: TextStyle(
                    color: crop.daysToHarvest >= 0
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: crop.growthProgress,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(
              '${crop.daysSincePlanting} days since planting',
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notes',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(notes,
                style: TextStyle(color: AppColors.textGrey, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
