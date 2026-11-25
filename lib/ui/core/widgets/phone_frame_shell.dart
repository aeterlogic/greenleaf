import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:greenleaf/ui/core/theme/app_theme.dart';

/// Wraps the app in a centred 390 x 844 phone frame (rounded corners + notch)
/// on laptop/desktop browsers, and renders full screen on real phones.
class PhoneFrameShell extends StatelessWidget {
  const PhoneFrameShell({
    super.key,
    required this.child,
  });

  final Widget child;

  static const double phoneWidth = 390;
  static const double phoneHeight = 844;
  static const double desktopBreakpoint = 520;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileDevice =
            defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android;
        final useFullScreen =
            isMobileDevice || constraints.maxWidth <= desktopBreakpoint;

        if (useFullScreen) {
          return child;
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFECEFED),
                GreenLeafColors.desktopBackdrop,
                Color(0xFFDFE4E1),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _PhoneMockupFrame(child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhoneMockupFrame extends StatelessWidget {
  const _PhoneMockupFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final baseMediaQuery = MediaQuery.of(context);
    final simulatedMediaQuery = baseMediaQuery.copyWith(
      size: const Size(
        PhoneFrameShell.phoneWidth,
        PhoneFrameShell.phoneHeight,
      ),
      padding: const EdgeInsets.only(top: 44, bottom: 20),
      viewPadding: const EdgeInsets.only(top: 44, bottom: 20),
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Subtle left side hardware buttons
        Positioned(
          left: -3,
          top: 140,
          child: _HardwareButton(height: 32),
        ),
        Positioned(
          left: -3,
          top: 192,
          child: _HardwareButton(height: 54),
        ),
        Positioned(
          left: -3,
          top: 258,
          child: _HardwareButton(height: 54),
        ),
        // Subtle right power button
        Positioned(
          right: -3,
          top: 204,
          child: _HardwareButton(height: 72),
        ),

        // Outer phone body
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: GreenLeafColors.phoneBezel,
            borderRadius: BorderRadius.circular(54),
            border: Border.all(
              color: const Color(0xFF393E3B),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33122017),
                blurRadius: 48,
                offset: Offset(0, 24),
              ),
              BoxShadow(
                color: Color(0x18122017),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(43),
            child: SizedBox(
              width: PhoneFrameShell.phoneWidth,
              height: PhoneFrameShell.phoneHeight,
              child: MediaQuery(
                data: simulatedMediaQuery,
                child: Stack(
                  children: [
                    // The actual GreenLeaf Flutter app
                    Positioned.fill(child: child),

                    // Simulated status bar icons alongside the notch
                    const Positioned(
                      top: 10,
                      left: 26,
                      right: 26,
                      child: IgnorePointer(
                        child: _PhoneStatusBar(),
                      ),
                    ),

                    // Classic top notch with speaker & camera lens
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 152,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: GreenLeafColors.phoneBezel,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E3330),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF26302B),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF3A4942),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom home indicator bar
                    Positioned(
                      bottom: 7,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 128,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: const Color(0x441B3524),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HardwareButton extends StatelessWidget {
  const _HardwareButton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF2E3330),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _PhoneStatusBar extends StatelessWidget {
  const _PhoneStatusBar();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: GreenLeafColors.textPrimary,
      decoration: TextDecoration.none,
    );

    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('9:41', style: textStyle),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.signal_cellular_alt_rounded,
              size: 14,
              color: GreenLeafColors.textPrimary,
            ),
            SizedBox(width: 4),
            Icon(
              Icons.wifi_rounded,
              size: 14,
              color: GreenLeafColors.textPrimary,
            ),
            SizedBox(width: 4),
            Icon(
              Icons.battery_full_rounded,
              size: 16,
              color: GreenLeafColors.textPrimary,
            ),
          ],
        ),
      ],
    );
  }
}
