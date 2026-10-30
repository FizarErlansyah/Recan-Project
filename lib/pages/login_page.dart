import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/gradient_pill_button.dart';
import 'package:mobile_apps_recan/widgets/pill_backdrop.dart';
import 'package:mobile_apps_recan/widgets/recan_form_field.dart';

class LoginPage extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double _headerHeight = 220;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
        username: _usernameController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      body: Stack(
        children: [
          const Positioned.fill(child: PillBackdrop()),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: _headerHeight,
                        child: _LoginHeader(),
                      ),
                      _LoginSheet(
                        formKey: _formKey,
                        usernameController: _usernameController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscure: _obscure,
                        loading: _loading,
                        onToggleObscure: () =>
                            setState(() => _obscure = !_obscure),
                        onSubmit: _submit,
                        minHeight: constraints.maxHeight - _headerHeight,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/recan_brandmak_white.png',
          height: 88,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.recycling_rounded,
            size: 88,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ReCan',
          style: textTheme.headlineMedium?.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 4),
        Text(
          tr('Daur Ulang Kalengmu', 'Recycle Your Can'),
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _LoginSheet extends StatelessWidget {
  const new({
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.loading,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.minHeight,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final bool loading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowStrong,
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tr('Halo!', 'Hello!'),
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 24),
            ReCanFormField(
              controller: usernameController,
              label: 'Username',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) {
                  return tr('Username wajib diisi', 'Username is required');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ReCanFormField(
              controller: emailController,
              label: 'Email',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) {
                  return tr('Email wajib diisi', 'Email is required');
                }
                if (!v.contains('@')) {
                  return tr('Format email tidak valid', 'Invalid email format');
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ReCanFormField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              suffix: IconButton(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? tr('Password wajib diisi', 'Password is required')
                  : null,
            ),
            const SizedBox(height: 32),
            GradientPillButton(
              label: tr('Masuk', 'Login'),
              loading: loading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
