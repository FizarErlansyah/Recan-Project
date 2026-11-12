import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/pages/drop_session_page.dart';
import 'package:mobile_apps_recan/services/camera_permission_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/circle_icon_button.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/scanner_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatefulWidget {
  const new({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> with WidgetsBindingObserver {
  static String get _dummyStationName =>
      tr('Drop Station Kampus Utama', 'Main Campus Drop Station');

  final MobileScannerController _scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  CameraAccess? _access;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_requestAccess());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _access != CameraAccess.granted) {
      unawaited(_requestAccess());
    }
  }

  Future<void> _requestAccess() async {
    final access = await CameraPermissionService.request();
    if (!mounted) return;
    setState(() {
      _access = access;
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final hasValue = capture.barcodes.any((b) => b.rawValue != null);
    if (!hasValue) return;
    _handled = true;
    await _scanner.stop();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadePageRoute<void>(
        page: DropSessionPage(stationName: _dummyStationName),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_scanner.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scrim,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBody(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: CircleIconButton(
                  icon: materialIcon(Icons.close_rounded),
                  tooltip: tr('Tutup', 'Close'),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final access = _access;
    if (access == null) return const SizedBox.shrink();
    if (access != CameraAccess.granted) {
      return _PermissionDenied(
        permanent: access == CameraAccess.permanentlyDenied,
        onRetry: _requestAccess,
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _scanner,
          onDetect: _onDetect,
          errorBuilder: (_, _) => const _PermissionDenied(permanent: false),
        ),
        const ScannerOverlay(),
        const _Instruction(),
      ],
    );
  }
}

class _Instruction extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final window = ScannerOverlay.windowRect(constraints.biggest);
        return Stack(
          children: [
            Positioned(
              top: window.bottom + 24,
              left: 24,
              right: 24,
              child: Text(
                tr(
                  'Arahkan ke QR Code di Drop Station',
                  'Point at the QR Code on the Drop Station',
                ),
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PermissionDenied extends StatelessWidget {
  const new({required this.permanent, this.onRetry});

  final bool permanent;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_rounded,
              size: 48,
              color: AppColors.primarySoft,
            ),
            const SizedBox(height: 16),
            Text(
              tr('Izin kamera diperlukan', 'Camera permission required'),
              style: textTheme.titleLarge?.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 8),
            Text(
              tr(
                'ReCan butuh kamera untuk memindai QR Code di Drop Station.',
                'ReCan needs the camera to scan the QR Code on the Drop '
                    'Station.',
              ),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.primarySoft,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primarySoft,
                  foregroundColor: AppColors.primary,
                ),
                onPressed: permanent
                    ? CameraPermissionService.openSettings
                    : onRetry,
                child: Text(
                  permanent
                      ? tr('Buka Pengaturan', 'Open Settings')
                      : tr('Izinkan Kamera', 'Allow Camera'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
