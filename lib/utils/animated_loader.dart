import 'package:flutter/material.dart';
import 'app_theme.dart';

/// A premium animated pulse and spinning glow loader widget for smooth UX.
class AppAnimatedPulseLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final String? loadingText;

  const AppAnimatedPulseLoader({
    super.key,
    this.size = 50.0,
    this.color,
    this.loadingText,
  });

  @override
  State<AppAnimatedPulseLoader> createState() => _AppAnimatedPulseLoaderState();
}

class _AppAnimatedPulseLoaderState extends State<AppAnimatedPulseLoader>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.4, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? AppColors.primary;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _rotationController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      themeColor.withValues(alpha: 0.1),
                      themeColor.withValues(alpha: 0.4),
                      themeColor,
                      themeColor.withValues(alpha: 0.1),
                    ],
                    transform: GradientRotation(_rotationController.value * 2 * 3.14159),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: _fadeAnimation.value * 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1B1D26),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.phone_in_talk_rounded,
                      color: themeColor,
                      size: widget.size * 0.45,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.loadingText != null) ...[
          const SizedBox(height: 14),
          Text(
            widget.loadingText!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    ),
  );
}
}

/// A shimmer skeleton card list loader for Call Logs screen to maintain seamless UX.
class CallLogsShimmerLoader extends StatefulWidget {
  final int itemCount;

  const CallLogsShimmerLoader({super.key, this.itemCount = 5});

  @override
  State<CallLogsShimmerLoader> createState() => _CallLogsShimmerLoaderState();
}

class _CallLogsShimmerLoaderState extends State<CallLogsShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        final opacity = _shimmerAnimation.value;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF22242E).withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2B2D38), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2D38).withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: 140,
                              decoration: BoxDecoration(
                                color: const Color(0xFF373A4A).withValues(alpha: opacity),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 12,
                              width: 90,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B2D38).withValues(alpha: opacity),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2D38).withValues(alpha: opacity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      5,
                      (i) => Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2D38).withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
