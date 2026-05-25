import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../onboarding/onboarding_screen.dart';
import '../main_screen.dart';
import '../../core/widgets/background_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 2500), () async {
      final prefs = await SharedPreferences.getInstance();
      final isOnboarded = prefs.getBool('isOnboarded') ?? false;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isOnboarded ? const MainScreen() : const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      body: Stack(
        children: [
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainState.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom Logo
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brightGreen.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      'assets/images/logo_square.png',
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 60,
                            color: AppColors.primaryGreen,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App Name
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Merienda',
                    ),
                    children: [
                      TextSpan(
                        text: 'FluentPath ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'AI',
                        style: TextStyle(color: AppColors.ctaRed),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  'Speak Better. Learn Smarter.',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),
                // Custom Audio Wave
                AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(12, (index) {
                          // Stagger the wave using a sine function of time and index
                          final double level = (1.0 + double.parse(((index % 2 == 0) ? 
                            (0.5 * (1.0 + (1.0 - _waveController.value))) : 
                            (0.5 * (1.0 + _waveController.value))).toString())) / 2.0;
                          final double scale = (0.3 + 0.7 * level);
                          final double height = 8.0 + 40.0 * scale;

                          return Container(
                            width: 4,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 2.0),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Version info
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v1.0',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Minimal placeholder class for MainState helper
class MainState {
  static const center = MainAxisAlignment.center;
}
