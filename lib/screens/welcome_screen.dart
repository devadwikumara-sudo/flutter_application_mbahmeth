import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_application_mbahmeth/theme/app_colors.dart';
import 'package:flutter_application_mbahmeth/screens/customer_login.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _swipeHintController;

  late Animation<double> _logoFade;
  late Animation<double> _titleFade;
  late Animation<double> _subtitleFade;
  late Animation<double> _swipeFade;
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _floatAnim;

  double _dragOffset = 0.0;
  bool _isNavigating = false;
  final double _triggerThreshold = 110.0;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _swipeHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _titleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );
    _subtitleFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    );
    _swipeFade = CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ));

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
    ));

    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _swipeHintController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    HapticFeedback.mediumImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // FIX: clamp swipeProgress dengan aman agar tidak pernah di luar 0.0–1.0
    final double swipeProgress =
        (_dragOffset / _triggerThreshold).clamp(0.0, 1.0);

    // FIX: hitung flash opacity dengan clamp eksplisit
    final double flashOpacity =
        ((swipeProgress - 0.85) / 0.15).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // FIX: backgroundColor transparan agar image bisa full screen
        backgroundColor: Colors.black,
        // FIX: extend body agar image di belakang status bar
        extendBodyBehindAppBar: true,
        extendBody: true,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            if (_isNavigating) return;
            if (details.delta.dy < 0) {
              setState(() {
                _dragOffset = (_dragOffset - details.delta.dy)
                    .clamp(0.0, _triggerThreshold * 1.2);
              });
            }
          },
          onVerticalDragEnd: (details) {
            if (_isNavigating) return;
            if (_dragOffset >= _triggerThreshold) {
              _navigateToLogin();
            } else {
              setState(() => _dragOffset = 0.0);
            }
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _floatController,
              _swipeHintController,
              _fadeController,
            ]),
            builder: (context, _) {
              return SizedBox.expand(
                child: Stack(
                  fit: StackFit.expand, // FIX: Stack expand penuh ke seluruh layar
                  children: [
                    // ── Background image fullscreen ──
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/wellcome.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),

                    // ── Gradient overlay ──
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.30),
                              Colors.black.withOpacity(0.50),
                              Colors.black.withOpacity(0.88),
                              Colors.black.withOpacity(0.97),
                            ],
                            stops: const [0.0, 0.35, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // ── Green glow top-left ──
                    Positioned(
                      top: -60,
                      left: -50,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Green glow bottom-right ──
                    Positioned(
                      bottom: 160,
                      right: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primaryGreen.withOpacity(0.15),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── Swipe progress green wash ──
                    // FIX: Gunakan Opacity widget biasa bukan AnimatedOpacity,
                    //      dan pastikan nilai selalu di antara 0.0–1.0
                    Positioned.fill(
                      child: Opacity(
                        opacity: (swipeProgress * 0.28).clamp(0.0, 1.0),
                        child: Container(color: AppColors.primaryGreen),
                      ),
                    ),

                    // ── Main content ──
                    Positioned.fill(
                      child: Transform.translate(
                        offset: Offset(0, -(_dragOffset * 0.35)),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28.0, vertical: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Spacer(flex: 2),

                                // ── Logo floating ──
                                FadeTransition(
                                  opacity: _logoFade,
                                  child: SlideTransition(
                                    position: _logoSlide,
                                    child: Transform.translate(
                                      offset: Offset(0, _floatAnim.value),
                                      child: Image.asset(
                                        'assets/images/x1.png',
                                        width: 270,
                                        height: 165,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),

                                const Spacer(flex: 3),

                                // ── Badge ──
                                FadeTransition(
                                  opacity: _subtitleFade,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: AppColors.primaryGreen
                                            .withOpacity(0.45),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primaryGreen,
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primaryGreen
                                                    .withOpacity(0.8),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Pertanian Modern • Dipercaya Petani',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                            letterSpacing: 0.8,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 18),

                                // ── Title ──
                                FadeTransition(
                                  opacity: _titleFade,
                                  child: SlideTransition(
                                    position: _titleSlide,
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Selamat Datang di\n',
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.white,
                                              height: 1.2,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Toko Mbahmeth',
                                            style: TextStyle(
                                              fontSize: 35,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primaryGreen,
                                              height: 1.25,
                                              letterSpacing: -0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // ── Subtitle ──
                                FadeTransition(
                                  opacity: _subtitleFade,
                                  child: SlideTransition(
                                    position: _subtitleSlide,
                                    child: const Text(
                                      'Kemudahan memesan obat-obatan sawah\nlangsung tanpa antri, kapan saja.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white54,
                                        height: 1.65,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 44),

                                // ── Swipe indicator ──
                                FadeTransition(
                                  opacity: _swipeFade,
                                  child: Column(
                                    children: [
                                      // Ripple arrows
                                      SizedBox(
                                        height: 50,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: List.generate(3, (i) {
                                            final double delay = i * 0.33;
                                            // FIX: clamp aman agar sin tidak negatif
                                            final double phase =
                                                (_swipeHintController.value -
                                                        delay)
                                                    .clamp(0.0, 1.0);
                                            // sin(phase * pi) selalu 0–1 karena phase sudah 0–1
                                            final double arrowOpacity =
                                                math.sin(phase * math.pi)
                                                    .clamp(0.0, 1.0);
                                            return Opacity(
                                              opacity: arrowOpacity,
                                              child: Transform.translate(
                                                offset:
                                                    Offset(0, (i - 1) * -15.0),
                                                child: Icon(
                                                  Icons
                                                      .keyboard_arrow_up_rounded,
                                                  color: AppColors.primaryGreen,
                                                  size: 27 + (i * 3.0),
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // Shimmer text
                                      ShaderMask(
                                        shaderCallback: (bounds) {
                                          // FIX: hitung shimmer stops dengan clamp aman
                                          final double raw =
                                              _swipeHintController.value * 2.0 -
                                                  0.5;
                                          final double s0 =
                                              (raw - 0.3).clamp(0.0, 1.0);
                                          final double s1 =
                                              raw.clamp(0.0, 1.0);
                                          final double s2 =
                                              (raw + 0.3).clamp(0.0, 1.0);
                                          // Jika semua stop sama, buat gradien flat
                                          final List<double> stops = (s0 == s1 &&
                                                  s1 == s2)
                                              ? [0.0, 0.5, 1.0]
                                              : [s0, s1, s2];
                                          return LinearGradient(
                                            colors: const [
                                              Colors.white38,
                                              Colors.white,
                                              Colors.white38,
                                            ],
                                            stops: stops,
                                          ).createShader(bounds);
                                        },
                                        child: const Text(
                                          'GESER KE ATAS UNTUK MULAI',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 2.5,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 14),

                                      // Progress bar
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: SizedBox(
                                          width: 100,
                                          height: 3,
                                          child: LinearProgressIndicator(
                                            value: swipeProgress,
                                            backgroundColor:
                                                Colors.white.withOpacity(0.12),
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.primaryGreen,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Flash saat hampir trigger ──
                    // FIX: Gunakan Opacity biasa dengan nilai yang sudah di-clamp,
                    //      bukan AnimatedOpacity (yang validasi lebih ketat)
                    if (swipeProgress > 0.85)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Opacity(
                            // FIX: clamp eksplisit, tidak mungkin di luar range
                            opacity: flashOpacity.clamp(0.0, 1.0),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.primaryGreen.withOpacity(0.35),
                                    Colors.transparent,
                                  ],
                                  center: Alignment.bottomCenter,
                                  radius: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}