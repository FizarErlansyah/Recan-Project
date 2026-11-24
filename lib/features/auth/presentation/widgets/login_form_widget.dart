import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/recan_form_field.dart';

class LoginFormWidget extends StatelessWidget {
  const new({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReCanFormField(
            controller: emailController,
            label: 'Email',
            icon: AppIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          ReCanFormField(
            controller: passwordController,
            label: 'Password',
            icon: AppIcons.lock,
            obscureText: obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            suffix: _ObscureToggle(
              obscure: obscure,
              onPressed: onToggleObscure,
            ),
            validator: _validatePassword,
          ),
          const SizedBox(height: 32),
          _SubmitButton(loading: loading, onPressed: onSubmit),
        ],
      ),
    );
  }

  static String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return tr('Email wajib diisi', 'Email is required');
    if (!v.contains('@')) {
      return tr('Format email tidak valid', 'Invalid email format');
    }
    return null;
  }

  static String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return tr('Password wajib diisi', 'Password is required');
    }
    return null;
  }
}

class _ObscureToggle extends StatelessWidget {
  const new({required this.obscure, required this.onPressed});

  final bool obscure;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: HugeIcon(
        icon: obscure ? AppIcons.hidden : AppIcons.visible,
        size: 20,
        color: context.palette.textSecondary,
      ),
      onPressed: onPressed,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const new({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(tr('Masuk', 'Login')),
      ),
    );
  }
}
