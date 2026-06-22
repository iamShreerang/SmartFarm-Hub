import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../models/user_profile.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _farmSizeCtrl = TextEditingController();
  String? _selectedFarmingType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  void _loadProfile() {
    final profile = context.read<ap.AuthProvider>().profile;
    if (profile != null) {
      _nameCtrl.text = profile.name;
      _ageCtrl.text = profile.age?.toString() ?? '';
      _locationCtrl.text = profile.location ?? '';
      _farmSizeCtrl.text = profile.farmSize?.toString() ?? '';
      _selectedFarmingType = profile.farmingType;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _locationCtrl.dispose();
    _farmSizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<ap.AuthProvider>();
    final updated = auth.profile!.copyWith(
      name: _nameCtrl.text.trim(),
      age: int.tryParse(_ageCtrl.text),
      location: _locationCtrl.text.trim(),
      farmSize: double.tryParse(_farmSizeCtrl.text),
      farmingType: _selectedFarmingType,
    );
    final success = await auth.updateProfile(updated);
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Profile updated!' : 'Failed to update.'),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<ap.AuthProvider>();
    final profile = auth.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton(
            onPressed: () => _isEditing ? _saveProfile() : setState(() => _isEditing = true),
            child: Text(_isEditing ? 'Save' : 'Edit',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                    const SizedBox(height: 12),
                    Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(profile.email, style: const TextStyle(color: AppColors.textGrey)),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Farmer Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            if (_isEditing) ...[
                              AppTextField(hintText: 'Full Name', labelText: 'Name', controller: _nameCtrl, prefixIcon: Icons.person_outline, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                              const SizedBox(height: 12),
                              AppTextField(hintText: 'Your age', labelText: 'Age', controller: _ageCtrl, prefixIcon: Icons.cake_outlined, keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              AppTextField(hintText: 'City, State', labelText: 'Location', controller: _locationCtrl, prefixIcon: Icons.location_on_outlined),
                              const SizedBox(height: 12),
                              AppTextField(hintText: 'e.g. 2.5', labelText: 'Farm Size (Acres)', controller: _farmSizeCtrl, prefixIcon: Icons.landscape_outlined, keyboardType: TextInputType.number),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(labelText: 'Farming Type', prefixIcon: const Icon(Icons.agriculture), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white),
                                value: _selectedFarmingType,
                                items: ['Organic', 'Conventional', 'Mixed', 'Subsistence'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                onChanged: (v) => setState(() => _selectedFarmingType = v),
                              ),
                            ] else ...[
                              _InfoRow('Name', profile.name),
                              _InfoRow('Age', profile.age?.toString() ?? 'Not set'),
                              _InfoRow('Location', profile.location ?? 'Not set'),
                              _InfoRow('Farm Size', profile.farmSize != null ? '${profile.farmSize} acres' : 'Not set'),
                              _InfoRow('Farming Type', profile.farmingType ?? 'Not set'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Column(
                        children: [
                          ListTile(leading: const Icon(Icons.logout, color: AppColors.error), title: const Text('Sign Out', style: TextStyle(color: AppColors.error)), onTap: () async {
                            final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Sign Out'), content: const Text('Are you sure?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign Out', style: TextStyle(color: AppColors.error)))]));
                            if (confirm == true && context.mounted) await context.read<ap.AuthProvider>().signOut();
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
