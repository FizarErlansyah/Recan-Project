import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/login_form_widget.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/login_hero.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/register_form_widget.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';

enum _AuthMode { landing, login, register }

class LoginPage extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double _heroFraction = 0.35;
  static const double _sheetOverlap = 32;

  _AuthMode _mode = _AuthMode.landing;

  final _loginFormKey = GlobalKey<FormState>();
  final _loginUsernameController = TextEditingController();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLogin = true;
  bool _loadingLogin = false;

  final _registerFormKey = GlobalKey<FormState>();
  final _registerUsernameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPhoneController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  bool _obscureRegister = true;
  bool _loadingRegister = false;

  @override
  void dispose() {
    _loginUsernameController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _goTo(_AuthMode mode) => setState(() => _mode = mode);

  Future<void> _openHome() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  Future<void> _submitLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _loadingLogin = true);
    try {
      await AuthService.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
        username: _loginUsernameController.text,
      );
      await _openHome();
    } on AuthException catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, e.message);
    } finally {
      if (mounted) setState(() => _loadingLogin = false);
    }
  }

  Future<void> _submitRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() => _loadingRegister = true);
    try {
      await AuthService.register(
        username: _registerUsernameController.text.trim(),
        email: _registerEmailController.text.trim(),
        phone: _registerPhoneController.text.trim(),
        password: _registerPasswordController.text,
      );
      await _openHome();
    } on AuthException catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, e.message);
    } finally {
      if (mounted) setState(() => _loadingRegister = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hero height comes from the full screen, not the layout constraints, so
    // it stays fixed instead of shrinking when the keyboard opens.
    final heroHeight = MediaQuery.sizeOf(context).height * _heroFraction;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: heroHeight, child: const LoginHero()),
              Transform.translate(
                offset: const Offset(0, -_sheetOverlap),
                child: _AuthSheet(
                  minHeight: math.max(0, constraints.maxHeight - heroHeight),
                  child: _buildSheetContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetContent() {
    switch (_mode) {
      case _AuthMode.landing:
        return _AuthLandingContent(
          onLogin: () => _goTo(_AuthMode.login),
          onRegister: () => _goTo(_AuthMode.register),
        );
      case _AuthMode.login:
        return _AuthFormSection(
          onBack: () => _goTo(_AuthMode.landing),
          title: tr('Masuk ke ReCan', 'Sign in to ReCan'),
          subtitle: tr(
            'Masuk untuk setor kaleng dan pantau poinmu.',
            'Sign in to drop cans and track your points.',
          ),
          form: LoginFormWidget(
            formKey: _loginFormKey,
            usernameController: _loginUsernameController,
            emailController: _loginEmailController,
            passwordController: _loginPasswordController,
            obscure: _obscureLogin,
            loading: _loadingLogin,
            onToggleObscure: () =>
                setState(() => _obscureLogin = !_obscureLogin),
            onSubmit: _submitLogin,
          ),
        );
      case _AuthMode.register:
        return _AuthFormSection(
          onBack: () => _goTo(_AuthMode.landing),
          title: tr('Daftar Akun ReCan', 'Create your ReCan account'),
          subtitle: tr(
            'Isi data berikut untuk mulai menyetor kaleng.',
            'Fill in the details below to start depositing cans.',
          ),
          form: RegisterFormWidget(
            formKey: _registerFormKey,
            usernameController: _registerUsernameController,
            emailController: _registerEmailController,
            phoneController: _registerPhoneController,
            passwordController: _registerPasswordController,
            obscure: _obscureRegister,
            loading: _loadingRegister,
            onToggleObscure: () =>
                setState(() => _obscureRegister = !_obscureRegister),
            onSubmit: _submitRegister,
          ),
        );
    }
  }
}

class _AuthSheet extends StatelessWidget {
  const new({required this.minHeight, required this.child});

  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.fromLTRB(24, 36, 24, 32 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: child,
      ),
    );
  }
}

class _AuthLandingContent extends StatelessWidget {
  const new({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey('landing'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tr('Selamat datang di ReCan', 'Welcome to ReCan'),
          style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          tr(
            'Masuk atau daftar untuk mulai setor kaleng dan pantau poinmu.',
            'Sign in or create an account to start dropping cans and '
                'tracking your points.',
          ),
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: onLogin,
            child: Text(tr('Masuk', 'Login')),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: onRegister,
            child: Text(tr('Daftar', 'Sign Up')),
          ),
        ),
      ],
    );
  }
}

class _AuthFormSection extends StatelessWidget {
  const new({
    required this.onBack,
    required this.title,
    required this.subtitle,
    required this.form,
  });

  final VoidCallback onBack;
  final String title;
  final String subtitle;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: ValueKey(title),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 40),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        form,
      ],
    );
  }
}
