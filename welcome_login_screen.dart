import 'dart:math';


import '../../core/app_export.dart';
import './widgets/anonymous_credential_box_widget.dart';
import './widgets/logo_header_widget.dart';
import './widgets/onboarding_hero_widget.dart';
import './widgets/particle_background_widget.dart';

// TODO: Replace with Riverpod/Bloc for production auth state

class WelcomeLoginScreen extends StatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends State<WelcomeLoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _pulse;

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _generatedUsername = '';
  String _generatedAvatarSeed = '';

  static const List<String> _adjectives = [
    'Shadow',
    'Neon',
    'Cosmic',
    'Silent',
    'Phantom',
    'Stellar',
    'Void',
    'Cipher',
    'Echo',
    'Nova',
    'Quantum',
    'Lunar',
    'Mystic',
    'Rogue',
    'Pixel',
    'Drift',
    'Surge',
    'Prism',
  ];
  static const List<String> _nouns = [
    'Fox',
    'Wolf',
    'Hawk',
    'Lynx',
    'Raven',
    'Panda',
    'Falcon',
    'Tiger',
    'Viper',
    'Eagle',
    'Otter',
    'Comet',
    'Nebula',
    'Spark',
    'Ghost',
    'Pulse',
    'Orbit',
    'Flare',
  ];

  @override
  void initState() {
    super.initState();
    _generateIdentity();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  void _generateIdentity() {
    final rng = Random();
    final adj = _adjectives[rng.nextInt(_adjectives.length)];
    final noun = _nouns[rng.nextInt(_nouns.length)];
    final num = rng.nextInt(900) + 100;
    setState(() {
      _generatedUsername = '$adj${noun}_$num';
      _generatedAvatarSeed = '$adj$noun$num';
    });
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: Replace with Supabase anonymous auth in production
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeFeed,
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBody: true,
      body: Stack(
        children: [
          const ParticleBackgroundWidget(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 0 : 24,
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 480 : double.infinity,
                    ),
                    child: FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideUp,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const LogoHeaderWidget(),
                              SizedBox(height: screenHeight * 0.04),
                              OnboardingHeroWidget(pulseAnimation: _pulse),
                              SizedBox(height: screenHeight * 0.04),
                              _buildHeadlineCopy(),
                              const SizedBox(height: 32),
                              AnonymousCredentialBoxWidget(
                                username: _generatedUsername,
                                avatarSeed: _generatedAvatarSeed,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                onRegenerateIdentity: _generateIdentity,
                              ),
                              const SizedBox(height: 20),
                              _buildLoginButton(),
                              const SizedBox(height: 16),
                              _buildSignInLink(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadlineCopy() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
            children: [
              TextSpan(
                text: 'Your Voice,\n',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              TextSpan(
                text: 'Zero Identity.',
                style: TextStyle(color: AppTheme.neonPurple),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Speak freely. Stay anonymous. Drive real change\nat your institution.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppTheme.textMuted,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.neonPurpleMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter the Void',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an identity? ',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to existing identity login
          },
          child: const Text(
            'Recover Access',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.neonPurple,
            ),
          ),
        ),
      ],
    );
  }
}
