import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobile_apps_recan/core/theme/app_colors.dart';
import 'package:mobile_apps_recan/core/theme/app_icon.dart';
import 'package:mobile_apps_recan/pages/drop_session_page.dart';
import 'package:mobile_apps_recan/services/camera_permission_service.dart';
import 'package:mobile_apps_recan/utils/localization.dart';
import 'package:mobile_apps_recan/widgets/fade_page_route.dart';
import 'package:mobile_apps_recan/widgets/frosted_glass.dart';
import 'package:mobile_apps_recan/widgets/scanner_overlay.dart';
import 'package:mobile_apps_recan/widgets/status_bar_icons.dart';
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
    return StatusBarIcons(
      light: true,
      child: Scaffold(
        backgroundColor: AppColors.scrim,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBody(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _TopBar(
                  scanner: _scanner,
                  showFlash: _access == CameraAccess.granted,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
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
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _ZoomPanel(scanner: _scanner),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const new({
    required this.scanner,
    required this.showFlash,
    required this.onBack,
  });

  final MobileScannerController scanner;
  final bool showFlash;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassIconButton(
          icon: hugeIcon(HugeIcons.strokeRoundedArrowLeft01)(
            color: AppColors.white,
            size: 24,
          ),
          tooltip: tr('Kembali', 'Back'),
          onTap: onBack,
        ),
        if (showFlash) _FlashButton(scanner: scanner),
      ],
    );
  }
}

class _FlashButton extends StatelessWidget {
  const new({required this.scanner});

  final MobileScannerController scanner;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: scanner,
      builder: (context, state, _) {
        final torch = state.torchState;
        final on = torch == TorchState.on;
        final available = torch != TorchState.unavailable;
        final icon = on
            ? HugeIcons.strokeRoundedFlash
            : HugeIcons.strokeRoundedFlashOff;
        return GlassIconButton(
          active: on,
          icon: hugeIcon(icon)(
            color: available ? AppColors.white : AppColors.silver,
            size: 24,
          ),
          tooltip: on
              ? tr('Matikan flash', 'Flash off')
              : tr('Nyalakan flash', 'Flash on'),
          onTap: available ? () => unawaited(scanner.toggleTorch()) : null,
        );
      },
    );
  }
}

class _ZoomPanel extends StatefulWidget {
  const new({required this.scanner});

  final MobileScannerController scanner;

  @override
  State<_ZoomPanel> createState() => _ZoomPanelState();
}

class _ZoomPanelState extends State<_ZoomPanel> {
  double _zoom = 0;

  Future<void> _apply(double value) async {
    setState(() => _zoom = value);
    try {
      await widget.scanner.setZoomScale(value);
    } on MobileScannerException {
      // Dragging can start before the camera finishes initializing; the next
      // slider tick applies the zoom, so a dropped call is harmless.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FrostedGlass(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Slider fills any bounded height, so the row must be pinned or the
      // glass panel stretches over the whole viewfinder.
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            hugeIcon(HugeIcons.strokeRoundedZoomOutArea)(
              color: AppColors.white,
              size: 22,
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.sageLight,
                  inactiveTrackColor: AppColors.white.withValues(alpha: 0.28),
                  thumbColor: AppColors.white,
                  overlayColor: AppColors.white.withValues(alpha: 0.12),
                ),
                child: Slider(
                  value: _zoom,
                  onChanged: (value) => unawaited(_apply(value)),
                ),
              ),
            ),
            hugeIcon(HugeIcons.strokeRoundedZoomInArea)(
              color: AppColors.white,
              size: 22,
            ),
          ],
        ),
      ),
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
              top: window.bottom + 36,
              left: 24,
              right: 24,
              child: FrostedGlass(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    hugeIcon(HugeIcons.strokeRoundedQrCode)(
                      color: AppColors.sageLight,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        tr(
                          'Arahkan ke QR Code di Drop Station',
                          'Point at the QR Code on the Drop Station',
                        ),
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
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
            hugeIcon(HugeIcons.strokeRoundedCameraOff01)(
              color: AppColors.primarySoft,
              size: 48,
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
