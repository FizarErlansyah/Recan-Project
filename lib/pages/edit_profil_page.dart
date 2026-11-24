import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/models/profile_data.dart';
import 'package:mobile_apps_recan/services/profile_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/field_glyph.dart';
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
  static const List<Color> _avatarColors = [
    AppColors.primary,
    AppColors.primaryLight,
    AppColors.clay,
    AppColors.sand,
    AppColors.primaryDeep,
  ];

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
  late Color _avatarColor = _avatarColors.first;

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

  Future<void> _pickAvatarColor() async {
    final picked = await showModalBottomSheet<Color>(
      context: context,
      builder: (sheetContext) => _AvatarColorSheet(
        initials: widget.profile.initials,
        colors: _avatarColors,
        selected: _avatarColor,
      ),
    );
    if (picked != null) setState(() => _avatarColor = picked);
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
              color: _avatarColor,
              onTap: _pickAvatarColor,
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
                  ?.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const new({required this.initials, required this.color, required this.onTap});

  final String initials;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ProfileAvatar(initials: initials, size: 104, color: color),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: AppColors.primary,
            shape: CircleBorder(
              side: BorderSide(color: context.palette.surface, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: HugeIcon(
                    icon: AppIcons.camera,
                    size: 18,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AvatarColorSheet extends StatelessWidget {
  const new({
    required this.initials,
    required this.colors,
    required this.selected,
  });

  final String initials;
  final List<Color> colors;
  final Color selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('Pilih Warna Avatar', 'Choose Avatar Color'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              tr(
                'Pratinjau foto profil belum tersedia, pilih warna sebagai gantinya.',
                "Photo upload isn't available yet, pick a color instead.",
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final color in colors)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(color),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: Border.all(
                          color: color == selected
                              ? context.palette.textPrimary
                              : AppColors.transparent,
                          width: 3,
                        ),
                      ),
                      child: color == selected
                          ? const HugeIcon(
                              icon: AppIcons.check,
                              color: AppColors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
