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

  static const _farmingTypes = ['Organic', 'Conventional', 'Mixed', 'Subsistence'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
            onPressed: () =>
                _isEditing ? _saveProfile() : setState(() => _isEditing = true),
            child: Text(
              _isEditing ? 'Save' : 'Edit',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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
                    _ProfileAvatar(profile: profile),
                    const SizedBox(height: 24),
                    _ProfileForm(
                      isEditing: _isEditing,
                      profile: profile,
                      nameCtrl: _nameCtrl,
                      ageCtrl: _ageCtrl,
                      locationCtrl: _locationCtrl,
                      farmSizeCtrl: _farmSizeCtrl,
                      selectedFarmingType: _selectedFarmingType,
                      farmingTypes: _farmingTypes,
                      onFarmingTypeChanged: (v) =>
                          setState(() => _selectedFarmingType = v),
                    ),
                    const SizedBox(height: 16),
                    _ProfileMenu(
                      onLogout: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text('Are you sure you want to sign out?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Sign Out',
                                      style: TextStyle(color: AppColors.error))),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await context.read<ap.AuthProvider>().signOut();
                        }
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final UserProfile profile;
  const _ProfileAvatar({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 52,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          backgroundImage: profile.profileImageUrl != null
              ? NetworkImage(profile.profileImageUrl!)
              : null,
          child: profile.profileImageUrl == null
              ? Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(profile.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(profile.email, style: const TextStyle(color: AppColors.textGrey)),
      ],
    );
  }
}

class _ProfileForm extends StatelessWidget {
  final bool isEditing;
  final UserProfile profile;
  final TextEditingController nameCtrl, ageCtrl, locationCtrl, farmSizeCtrl;
  final String? selectedFarmingType;
  final List<String> farmingTypes;
  final ValueChanged<String?> onFarmingTypeChanged;

  const _ProfileForm({
    required this.isEditing,
    required this.profile,
    required this.nameCtrl,
    required this.ageCtrl,
    required this.locationCtrl,
    required this.farmSizeCtrl,
    required this.selectedFarmingType,
    required this.farmingTypes,
    required this.onFarmingTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Farmer Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (isEditing) ...[
              AppTextField(
                hintText: 'Full Name',
                labelText: 'Name',
                controller: nameCtrl,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                hintText: 'Your age',
                labelText: 'Age',
                controller: ageCtrl,
                prefixIcon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              AppTextField(
                hintText: 'City, State',
                labelText: 'Location',
                controller: locationCtrl,
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              AppTextField(
                hintText: 'e.g. 2.5',
                labelText: 'Farm Size (Acres)',
                controller: farmSizeCtrl,
                prefixIcon: Icons.landscape_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Farming Type',
                  prefixIcon: const Icon(Icons.agriculture),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: selectedFarmingType,
                items: farmingTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: onFarmingTypeChanged,
              ),
            ] else ...[
              _InfoRow('Name', profile.name, Icons.person_outline),
              _InfoRow('Age', profile.age?.toString() ?? 'Not set', Icons.cake_outlined),
              _InfoRow('Location', profile.location ?? 'Not set', Icons.location_on_outlined),
              _InfoRow(
                'Farm Size',
                profile.farmSize != null ? '${profile.farmSize} acres' : 'Not set',
                Icons.landscape_outlined,
              ),
              _InfoRow('Farming Type', profile.farmingType ?? 'Not set', Icons.agriculture),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoRow(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textGrey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfileMenu({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & FAQ'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
