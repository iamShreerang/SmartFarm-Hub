import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../providers/crop_provider.dart';
import '../../models/crop.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'add_crop_screen.dart';
import 'crop_detail_screen.dart';

class CropListScreen extends StatelessWidget {
  const CropListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final crops = context.watch<CropProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Crops')),
      body: crops.isLoading && crops.crops.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : crops.crops.isEmpty
              ? EmptyState(
                  title: 'No Crops Yet',
                  subtitle: 'Start by adding your first crop to track its growth.',
                  icon: Icons.grass,
                  actionLabel: 'Add Crop',
                  onAction: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddCropScreen())),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: crops.crops.length,
                  itemBuilder: (_, i) =>
                      _CropCard(crop: crops.crops[i]),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddCropScreen())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Add Crop', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final Crop crop;
  const _CropCard({required this.crop});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(crop.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Crop'),
            content: Text('Delete "${crop.name}"? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => context.read<CropProvider>().deleteCrop(crop),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CropDetailScreen(crop: crop))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: crop.imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                crop.imageUrls.first,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.grass,
                              color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(crop.name,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            crop.growthStage.name.toUpperCase(),
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    _HarvestBadge(daysToHarvest: crop.daysToHarvest),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${(crop.growthProgress * 100).toInt()}%',
                      style: TextStyle(
                          color: AppColors.textGrey, fontSize: 12),
                    ),
                    Text(
                      'Planted: ${_formatDate(crop.plantingDate)}',
                      style: TextStyle(
                          color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: crop.growthProgress,
                  backgroundColor: Colors.grey.shade200,
                  color: _progressColor(crop.growthProgress),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _progressColor(double progress) {
    if (progress < 0.33) return AppColors.info;
    if (progress < 0.66) return AppColors.primaryLight;
    return AppColors.success;
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class _HarvestBadge extends StatelessWidget {
  final int daysToHarvest;
  const _HarvestBadge({required this.daysToHarvest});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    if (daysToHarvest < 0) {
      color = AppColors.error;
      label = 'Overdue';
    } else if (daysToHarvest <= 7) {
      color = AppColors.warning;
      label = '${daysToHarvest}d left';
    } else {
      color = AppColors.success;
      label = '${daysToHarvest}d left';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
