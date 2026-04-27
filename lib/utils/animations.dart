import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ============================================================
// STAGGERED LIST ITEM - wraps child with fade+slide animation
// ============================================================
class StaggeredListItem extends StatelessWidget {
  final int index;
  final Animation<double> animation;
  final Widget child;
  final double slideOffset;

  const StaggeredListItem({
    super.key,
    required this.index,
    required this.animation,
    required this.child,
    this.slideOffset = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.1).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, slideOffset / 100),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}

// ============================================================
// ANIMATED FADE SLIDE - auto-animating single widget
// ============================================================
class AnimatedFadeSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;

  const AnimatedFadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = const Offset(0, 0.3),
  });

  @override
  State<AnimatedFadeSlide> createState() => _AnimatedFadeSlideState();
}

class _AnimatedFadeSlideState extends State<AnimatedFadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// SCALE ON TAP - press-down scale effect for any widget
// ============================================================
class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const ScaleOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
  });

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ============================================================
// PAGE TRANSITIONS - custom route builders
// ============================================================
class PageTransitions {
  static Route fadeSlide(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static Route fadeScale(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  static Route heroFade(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  static Route rotateScale(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.7, end: 1.0).animate(curved),
            child: RotationTransition(
              turns: Tween<double>(begin: -0.02, end: 0.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  static Route slideUp(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }
}

// ============================================================
// SHIMMER LOADING SKELETON
// ============================================================
class ShimmerCardSkeleton extends StatelessWidget {
  final double height;
  final double imageHeight;

  const ShimmerCardSkeleton({
    super.key,
    this.height = 320,
    this.imageHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 180, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 120, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Container(height: 12, width: double.infinity, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PULSE ANIMATION - gentle repeating scale for CTA buttons
// ============================================================
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 1.0,
    this.maxScale = 1.03,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: widget.minScale, end: widget.maxScale)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scale, child: widget.child);
  }
}

// ============================================================
// FLOATING ANIMATION - makes widgets appear to hover/float up & down
// ============================================================
class FloatingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;

  const FloatingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2500),
    this.offset = 8.0,
  });

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy = math.sin(_controller.value * math.pi * 2) * widget.offset;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}

// ============================================================
// GLOW PULSE - soft animated glow around any widget
// ============================================================
class GlowPulse extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double maxRadius;
  final Duration duration;
  final BorderRadius? borderRadius;

  const GlowPulse({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF42A5F5),
    this.maxRadius = 28,
    this.duration = const Duration(milliseconds: 1800),
    this.borderRadius,
  });

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(_controller.value);
        final radius = 8 + (widget.maxRadius - 8) * value;
        final alpha = 0.25 + (0.35 * (1 - value));
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withValues(alpha: alpha),
                blurRadius: radius,
                spreadRadius: value * 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ============================================================
// ANIMATED COUNTER - counts up from 0 to target value
// ============================================================
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;
  final String suffix;
  final String prefix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1400),
    this.style,
    this.suffix = '',
    this.prefix = '',
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final current = (widget.value * _animation.value).round();
        return Text(
          '${widget.prefix}$current${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

// ============================================================
// ANIMATED GRADIENT BACKGROUND - slowly shifting gradient
// ============================================================
class AnimatedGradientBackground extends StatefulWidget {
  final List<List<Color>> gradients;
  final Widget child;
  final Duration duration;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.gradients,
    this.duration = const Duration(seconds: 6),
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.gradients.length;
        });
        _controller.forward(from: 0);
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _lerpColors(List<Color> from, List<Color> to, double t) {
    return List.generate(
      from.length,
      (i) => Color.lerp(from[i], to[i], t) ?? from[i],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextIndex = (_currentIndex + 1) % widget.gradients.length;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final colors = _lerpColors(
          widget.gradients[_currentIndex],
          widget.gradients[nextIndex],
          _controller.value,
        );
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ============================================================
// FLOATING PARTICLES BACKGROUND
// ============================================================
class FloatingParticles extends StatefulWidget {
  final int count;
  final Color color;
  final double maxRadius;

  const FloatingParticles({
    super.key,
    this.count = 18,
    this.color = Colors.white,
    this.maxRadius = 4,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (_) => _createParticle());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  _Particle _createParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      radius: _random.nextDouble() * widget.maxRadius + 1,
      speed: _random.nextDouble() * 0.3 + 0.1,
      phase: _random.nextDouble() * math.pi * 2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              progress: _controller.value,
              color: widget.color,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double radius;
  double speed;
  double phase;
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dx = p.x * size.width +
          math.sin(progress * math.pi * 2 + p.phase) * 20;
      final dy = ((p.y + progress * p.speed) % 1.0) * size.height;
      final alpha = 0.25 + 0.35 * math.sin(progress * math.pi * 2 + p.phase);
      final paint = Paint()..color = color.withValues(alpha: alpha.clamp(0.08, 0.6));
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) => true;
}

// ============================================================
// BOUNCE IN - scale bounce entry animation
// ============================================================
class BounceIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const BounceIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<BounceIn> createState() => _BounceInState();
}

class _BounceInState extends State<BounceIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ============================================================
// ROTATE IN - entry rotation + scale
// ============================================================
class RotateIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginAngle;

  const RotateIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 700),
    this.beginAngle = -0.15,
  });

  @override
  State<RotateIn> createState() => _RotateInState();
}

class _RotateInState extends State<RotateIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: RotationTransition(
        turns: Tween<double>(begin: widget.beginAngle, end: 0.0).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(curved),
          child: widget.child,
        ),
      ),
    );
  }
}

// ============================================================
// SHIMMER TEXT - animated shine across text
// ============================================================
class ShimmerText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerText({
    super.key,
    required this.text,
    required this.style,
    this.baseColor = Colors.white,
    this.highlightColor = const Color(0xFFFFD54F),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 2200),
      child: Text(text, style: style),
    );
  }
}

// ============================================================
// GRADIENT TEXT - color-graded text using ShaderMask
// ============================================================
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;
  final TextAlign? textAlign;

  const GradientText({
    super.key,
    required this.text,
    required this.style,
    required this.colors,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

// ============================================================
// ANIMATED ICON CIRCLE - rotating gradient ring around icon
// ============================================================
class AnimatedIconCircle extends StatefulWidget {
  final IconData icon;
  final double size;
  final List<Color> ringColors;
  final Color iconColor;
  final Color backgroundColor;

  const AnimatedIconCircle({
    super.key,
    required this.icon,
    this.size = 72,
    this.ringColors = const [Color(0xFF42A5F5), Color(0xFF00BFA5), Color(0xFFFF7043)],
    this.iconColor = Colors.white,
    this.backgroundColor = const Color(0xFF1565C0),
  });

  @override
  State<AnimatedIconCircle> createState() => _AnimatedIconCircleState();
}

class _AnimatedIconCircleState extends State<AnimatedIconCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: _controller.value * math.pi * 2,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(colors: [
                      ...widget.ringColors,
                      widget.ringColors.first,
                    ]),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.backgroundColor,
                ),
                child: Center(
                  child: Icon(widget.icon,
                      color: widget.iconColor, size: widget.size * 0.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// WAVE LOADING - elegant wave dots loader
// ============================================================
class WaveLoader extends StatefulWidget {
  final Color color;
  final double dotSize;
  final int dotCount;

  const WaveLoader({
    super.key,
    this.color = const Color(0xFF1565C0),
    this.dotSize = 10,
    this.dotCount = 4,
  });

  @override
  State<WaveLoader> createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<WaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.dotSize * 3,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.dotCount, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final phase = (_controller.value + i / widget.dotCount) % 1;
              final dy = math.sin(phase * math.pi * 2) * widget.dotSize;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.dotSize / 3),
                child: Transform.translate(
                  offset: Offset(0, -dy),
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// ============================================================
// TYPEWRITER TEXT - types text one character at a time
// ============================================================
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final TextAlign? textAlign;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 1600),
    this.textAlign,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final count = (widget.text.length * _controller.value).round();
        return Text(
          widget.text.substring(0, count),
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

// ============================================================
// ANIMATED BORDER - moving gradient border
// ============================================================
class AnimatedBorderContainer extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;
  final List<Color> colors;
  final Duration duration;
  final Color fillColor;

  const AnimatedBorderContainer({
    super.key,
    required this.child,
    this.borderWidth = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.colors = const [Color(0xFF1565C0), Color(0xFF00BFA5), Color(0xFFFF7043)],
    this.duration = const Duration(seconds: 3),
    this.fillColor = Colors.white,
  });

  @override
  State<AnimatedBorderContainer> createState() =>
      _AnimatedBorderContainerState();
}

class _AnimatedBorderContainerState extends State<AnimatedBorderContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(widget.borderWidth),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              startAngle: _controller.value * math.pi * 2,
              endAngle: _controller.value * math.pi * 2 + math.pi * 2,
              colors: [...widget.colors, widget.colors.first],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: widget.fillColor,
              borderRadius: widget.borderRadius.subtract(
                BorderRadius.circular(widget.borderWidth),
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ============================================================
// PRESS RIPPLE - soft material ripple on press
// ============================================================
class PressRipple extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? splashColor;

  const PressRipple({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.splashColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        splashColor: splashColor ?? Colors.white.withValues(alpha: 0.25),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: child,
      ),
    );
  }
}

// ============================================================
// STAGGERED GRID - animates children as a grid (fade+slide)
// ============================================================
class StaggeredEntry extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Offset beginOffset;

  const StaggeredEntry({
    super.key,
    required this.child,
    required this.index,
    this.baseDelay = const Duration(milliseconds: 80),
    this.beginOffset = const Offset(0, 0.3),
  });

  @override
  State<StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.beginOffset, end: Offset.zero)
            .animate(curved),
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// LIQUID BUTTON - elegant gradient CTA with shine sweep
// ============================================================
class LiquidButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final List<Color> colors;
  final double height;
  final bool isLoading;

  const LiquidButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.colors = const [Color(0xFF1565C0), Color(0xFF42A5F5)],
    this.height = 56,
    this.isLoading = false,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              gradient: LinearGradient(
                colors: widget.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.colors.last.withValues(alpha: 0.45),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.height / 2),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Moving shine
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(
                        _controller.value * 400 - 200,
                        0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.25),
                              Colors.white.withValues(alpha: 0),
                            ],
                            stops: const [0.4, 0.5, 0.6],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.isLoading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (widget.icon != null) ...[
                          const SizedBox(width: 10),
                          Icon(widget.icon, color: Colors.white, size: 20),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// BLOB BACKGROUND - soft decorative animated blob
// ============================================================
class BlobDecoration extends StatefulWidget {
  final double size;
  final List<Color> colors;
  final Duration duration;

  const BlobDecoration({
    super.key,
    this.size = 220,
    this.colors = const [Color(0xFFFFAB40), Color(0xFFFF7043)],
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<BlobDecoration> createState() => _BlobDecorationState();
}

class _BlobDecorationState extends State<BlobDecoration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * math.pi * 2;
        return Transform.translate(
          offset: Offset(math.sin(t) * 10, math.cos(t) * 14),
          child: Transform.scale(
            scale: 1 + math.sin(t) * 0.04,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: widget.colors),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors.last.withValues(alpha: 0.35),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
