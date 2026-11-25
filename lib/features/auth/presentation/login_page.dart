import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_palette.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/auth_mode_toggle.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/login_form_widget.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/login_hero.dart';
import 'package:mobile_apps_recan/features/auth/presentation/widgets/register_form_widget.dart';
import 'package:mobile_apps_recan/pages/home_page.dart';
import 'package:mobile_apps_recan/services/auth_service.dart';
import 'package:mobile_apps_recan/utils/app_snack_bar.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/motion/recan_page_route.dart';
import 'package:mobile_apps_recan/widgets/motion/shake.dart';
import 'package:mobile_apps_recan/widgets/pull_up_overlap.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';

class LoginPage extends StatefulWidget {
  const new({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const double _sheetOverlap = 28;

  AuthMode _mode = AuthMode.login;

  // Raised on every refusal; the form shakes when it changes.
  int _refusals = 0;
  String? _loginError;
  String? _registerError;

  final _loginFormKey = GlobalKey<FormState>();
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
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerEmailController.dispose();
    _registerPhoneController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _goTo(AuthMode mode) => setState(() {
    _mode = mode;
    _loginError = null;
    _registerError = null;
  });

  bool _isValid(GlobalKey<FormState> form) {
    final valid = form.currentState!.validate();
    if (!valid) setState(() => _refusals++);
    return valid;
  }

  Future<void> _openHome() async {
    if (!mounted) return;
    await Navigator.of(context)
        .pushReplacement(RecanPageRoute<void>(page: const HomePage()));
  }

  Future<void> _submitLogin() async {
    if (_loadingLogin || !_isValid(_loginFormKey)) return;

    setState(() {
      _loadingLogin = true;
      _loginError = null;
    });
    try {
      await AuthService.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );
      await _openHome();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loginError = e.message;
        _refusals++;
      });
    } finally {
      if (mounted) setState(() => _loadingLogin = false);
    }
  }

  Future<void> _submitRegister() async {
    if (_loadingRegister || !_isValid(_registerFormKey)) return;

    setState(() {
      _loadingRegister = true;
      _registerError = null;
    });
    try {
      final email = _registerEmailController.text.trim();
      final signedIn = await AuthService.register(
        username: _registerUsernameController.text.trim(),
        email: email,
        phone: _registerPhoneController.text.trim(),
        password: _registerPasswordController.text,
      );
      if (signedIn) {
        await _openHome();
        return;
      }
      if (!mounted) return;
      _loginEmailController.text = email;
      _goTo(AuthMode.login);
      AppSnackBar.show(
        context,
        tr(
          'Akun dibuat. Cek emailmu untuk verifikasi, lalu masuk.',
          'Account created. Check your email to verify it, then log in.',
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _registerError = e.message;
        _refusals++;
      });
    } finally {
      if (mounted) setState(() => _loadingRegister = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _loadingLogin || _loadingRegister;

    return StatusBarIcons(
      light: true,
      child: Scaffold(
        backgroundColor: context.palette.surface,
        body: _FillViewport(
          child: _AuthColumn(overlap: _sheetOverlap, sheet: _buildSheet(busy)),
        ),
      ),
    );
  }

  Widget _buildSheet(bool busy) => _AuthSheet(
    toggle: AuthModeToggle(mode: _mode, enabled: !busy, onChanged: _goTo),
    form: Shake(signal: _refusals, child: _buildForm()),
    mode: _mode,
  );

  Widget _buildForm() => switch (_mode) {
    AuthMode.login => LoginFormWidget(
      key: const ValueKey(AuthMode.login),
      formKey: _loginFormKey,
      emailController: _loginEmailController,
      passwordController: _loginPasswordController,
      obscure: _obscureLogin,
      loading: _loadingLogin,
      error: _loginError,
      onToggleObscure: () => setState(() => _obscureLogin = !_obscureLogin),
      onSubmit: _submitLogin,
    ),
    AuthMode.register => RegisterFormWidget(
      key: const ValueKey(AuthMode.register),
      formKey: _registerFormKey,
      usernameController: _registerUsernameController,
      emailController: _registerEmailController,
      phoneController: _registerPhoneController,
      passwordController: _registerPasswordController,
      obscure: _obscureRegister,
      loading: _loadingRegister,
      error: _registerError,
      onToggleObscure: () =>
          setState(() => _obscureRegister = !_obscureRegister),
      onSubmit: _submitRegister,
    ),
  };
}

/// Scrolls when the form outgrows the screen and fills it when it does not.
class _FillViewport extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: child,
        ),
      ),
    );
  }
}

class _AuthColumn extends StatelessWidget {
  const new({required this.overlap, required this.sheet});

  final double overlap;
  final Widget sheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginHero(overlap: overlap),
        PullUpOverlap(extent: overlap, child: sheet),
      ],
    );
  }
}

class _AuthSheet extends StatelessWidget {
  const new({required this.toggle, required this.form, required this.mode});

  final Widget toggle;
  final Widget form;
  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 24, 24, 32 + bottomInset),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          toggle,
          const SizedBox(height: 24),
          _AuthHeading(mode: mode),
          const SizedBox(height: 24),
          _ResizingSwitcher(key: const ValueKey('auth-form-area'), child: form),
        ],
      ),
    );
  }
}

class _AuthHeading extends StatelessWidget {
  const new({required this.mode});

  final AuthMode mode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (title, subtitle) = switch (mode) {
      AuthMode.login => (
        tr('Selamat datang di ReCan', 'Welcome to ReCan'),
        tr(
          'Masuk untuk setor kaleng dan pantau poinmu.',
          'Sign in to drop cans and track your points.',
        ),
      ),
      AuthMode.register => (
        tr('Daftar Akun ReCan', 'Create your ReCan account'),
        tr(
          'Isi data berikut untuk mulai menyetor kaleng.',
          'Fill in the details below to start depositing cans.',
        ),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: context.palette.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Crossfades between forms while the height glides from one to the other.
class _ResizingSwitcher extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  static const Duration _swap = Duration(milliseconds: 260);

  // The outgoing form is pinned over the incoming one without a say in the
  // size, and cannot be touched on its way out.
  static Widget _stack(Widget? current, List<Widget> previous) => Stack(
    clipBehavior: Clip.none,
    children: [
      for (final old in previous)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(child: ExcludeSemantics(child: old)),
        ),
      ?current,
    ],
  );

  @override
  Widget build(BuildContext context) {
    // AnimatedSize cannot run with a zero duration, so reduced motion swaps
    // the form outright.
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return AnimatedSize(
      duration: _swap,
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: _swap,
        layoutBuilder: _stack,
        child: child,
      ),
    );
  }
}
