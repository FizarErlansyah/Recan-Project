import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/profile_avatar.dart';

class EditProfilPage extends StatefulWidget {
  const new({required this.profile, super.key});

  static void open(BuildContext context, ProfileData profile) {
    Navigator.of(context)
        .push(FadePageRoute<void>(page: EditProfilPage(profile: profile)));
  }

  final ProfileData profile;

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.profile.email,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ProfileService.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    AppSnackBar.showWith(
      messenger,
      tr('Profil berhasil diperbarui', 'Profile updated successfully'),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr('Nama wajib diisi', 'Name is required');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return tr('Email wajib diisi', 'Email is required');
    if (!email.contains('@')) {
      return tr('Format email tidak valid', 'Invalid email format');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('Edit Profil', 'Edit Profile'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ProfileAvatar(initials: widget.profile.initials, size: 104),
          ),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: tr('Nama Lengkap', 'Full Name'),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: _validateEmail,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              tr('Simpan Perubahan', 'Save Changes'),
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
