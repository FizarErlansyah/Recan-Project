import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_icons.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/auth_form_footer.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/obscure_toggle.dart';
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
    this.error,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  /// Why the last submit was refused.
  final String? error;

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
            suffix: ObscureToggle(obscure: obscure, onPressed: onToggleObscure),
            validator: _validatePassword,
          ),
          AuthFormFooter(
            label: tr('Masuk', 'Login'),
            loading: loading,
            error: error,
            onSubmit: onSubmit,
          ),
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
