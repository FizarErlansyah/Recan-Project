import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/profile/presentation/widgets/avatar_source_sheet.dart';
import 'package:mobile_apps_recan/models/avatar_ref.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/services/avatar_picker.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/field_glyph.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/profile_avatar.dart';

class EditProfilPage extends StatefulWidget {
  const new({required this.profile, super.key});

  static void open(BuildContext context, ProfileData profile) {
    Navigator.of(context)
        .push(RecanPageRoute<void>(page: EditProfilPage(profile: profile)));
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
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.profile.phone,
  );
  late AvatarRef _avatar = widget.profile.avatar;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ProfileService.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    AppSnackBar.showWith(
      messenger,
      tr('Profil berhasil diperbarui', 'Profile updated successfully'),
    );
  }

  Future<void> _changeAvatar() async {
    final action = await AvatarSourceSheet.show(
      context,
      hasPhoto: !_avatar.isEmpty,
    );
    if (action == null || !mounted) return;
    try {
      final updated = await switch (action) {
        AvatarAction.remove => ProfileService.removeAvatar(),
        AvatarAction.camera => _pick(AvatarSource.camera),
        AvatarAction.gallery => _pick(AvatarSource.gallery),
      };
      if (updated != null && mounted) setState(() => _avatar = updated);
    } on PlatformException {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        tr(
          'Foto tidak bisa diambil. Periksa izin kamera atau galeri.',
          'Could not get the photo. Check the camera or gallery permission.',
        ),
      );
    }
  }

  Future<AvatarRef?> _pick(AvatarSource source) async {
    final path = await AvatarPicker.pick(source);
    if (path == null) return null;
    final updated = await ProfileService.updateAvatar(path);
    return updated;
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

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr('Nomor telepon wajib diisi', 'Phone number is required');
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
            child: _AvatarPicker(
              initials: widget.profile.initials,
              avatar: _avatar,
              onTap: _changeAvatar,
            ),
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
                    prefixIcon: const FieldGlyph(icon: AppIcons.person),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  enabled: ProfileService.canEditEmail,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: FieldGlyph(icon: AppIcons.mail),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: tr('Nomor Telepon', 'Phone Number'),
                    prefixIcon: const FieldGlyph(icon: AppIcons.phone),
                  ),
                  validator: _validatePhone,
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
                  ?.copyWith(color: context.palette.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const new({
    required this.initials,
    required this.avatar,
    required this.onTap,
  });

  final String initials;
  final AvatarRef avatar;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: ProfileAvatar(initials: initials, avatar: avatar, size: 104),
        ),
        Positioned(right: 0, bottom: 0, child: _CameraBadge(onTap: onTap)),
      ],
    );
  }
}

class _CameraBadge extends StatelessWidget {
  const new({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: CircleBorder(
        side: BorderSide(color: context.palette.surface, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(9),
          child: HugeIcon(
            icon: AppIcons.camera,
            size: 18,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
