

import '../../core/app_export.dart';
import './widgets/ai_moderation_status_widget.dart';
import './widgets/category_selector_widget.dart';
import './widgets/cooldown_timer_widget.dart';
import './widgets/post_guidelines_widget.dart';
import './widgets/suggestion_text_field_widget.dart';

// TODO: Replace with Riverpod/Bloc for production state management

class PostSuggestionScreen extends StatefulWidget {
  const PostSuggestionScreen({super.key});

  @override
  State<PostSuggestionScreen> createState() => _PostSuggestionScreenState();
}

class _PostSuggestionScreenState extends State<PostSuggestionScreen>
    with TickerProviderStateMixin {
  int _navIndex = 1;
  int _selectedCategoryIndex = 0;
  final TextEditingController _suggestionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // AI moderation state
  // TODO: Replace with actual OpenAI API call in production
  AiModerationState _moderationState = AiModerationState.idle;
  String _moderationMessage = '';
  double _toxicityScore = 0.0;

  // Cooldown state
  // TODO: Replace with Supabase rate-limit check in production
  bool _isOnCooldown = false;
  int _cooldownSeconds = 0;

  bool _isSubmitting = false;

  late AnimationController _entranceController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  static const int _maxChars = 500;
  static const int _minChars = 30;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _suggestionController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      // Reset moderation when text changes
      if (_moderationState != AiModerationState.idle) {
        _moderationState = AiModerationState.idle;
        _moderationMessage = '';
      }
    });
  }

  Future<void> _runAiCheck() async {
    final text = _suggestionController.text.trim();
    if (text.length < _minChars) return;

    setState(() => _moderationState = AiModerationState.checking);

    // TODO: Replace with actual OpenAI moderation API call in production
    // Simulate AI moderation delay
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    // Simulate moderation result based on content
    final lowerText = text.toLowerCase();
    final toxicKeywords = [
      'hate',
      'useless',
      'stupid',
      'idiot',
      'kill',
      'attack',
      'harass',
    ];
    final hasToxic = toxicKeywords.any((k) => lowerText.contains(k));
    final isShort = text.length < 50;

    if (hasToxic) {
      setState(() {
        _moderationState = AiModerationState.blocked;
        _moderationMessage =
            'This suggestion contains harmful language. Please rephrase constructively.';
        _toxicityScore = 0.87;
      });
    } else if (isShort) {
      setState(() {
        _moderationState = AiModerationState.flagged;
        _moderationMessage =
            'Your suggestion is brief. Adding more detail increases its chance of being reviewed.';
        _toxicityScore = 0.22;
      });
    } else {
      setState(() {
        _moderationState = AiModerationState.approved;
        _moderationMessage =
            'Suggestion looks constructive and respectful. Ready to post!';
        _toxicityScore = 0.04;
      });
    }
  }

  Future<void> _submitSuggestion() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    // TODO: Replace with Supabase insert + OpenAI final validation in production
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _isOnCooldown = true;
      _cooldownSeconds = 300; // 5 minute cooldown
      _suggestionController.clear();
      _moderationState = AiModerationState.idle;
      _moderationMessage = '';
    });

    _startCooldownTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppTheme.neonGreen,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Suggestion submitted anonymously!',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.homeFeed,
      (_) => false,
    );
  }

  void _startCooldownTimer() {
    // TODO: Persist cooldown end time to SharedPreferences in production
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) {
          _isOnCooldown = false;
          _cooldownSeconds = 0;
        }
      });
      return _cooldownSeconds > 0;
    });
  }

  bool get _canSubmit {
    final text = _suggestionController.text.trim();
    return text.length >= _minChars &&
        text.length <= _maxChars &&
        _moderationState == AiModerationState.approved &&
        !_isOnCooldown &&
        !_isSubmitting;
  }

  void _onNavChanged(int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeFeed,
        (_) => false,
      );
      return;
    }
    setState(() => _navIndex = index);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _suggestionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 560 : double.infinity,
                ),
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          isTablet ? 0 : 16,
                          8,
                          isTablet ? 0 : 16,
                          120,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildScreenTitle(),
                            const SizedBox(height: 20),
                            // Category selector — Image 2 Screen 2.3 pill rows
                            _buildSectionLabel('Choose Category'),
                            const SizedBox(height: 10),
                            CategorySelectorWidget(
                              selectedIndex: _selectedCategoryIndex,
                              onSelected: (i) =>
                                  setState(() => _selectedCategoryIndex = i),
                            ),
                            const SizedBox(height: 20),
                            _buildSectionLabel('Your Suggestion'),
                            const SizedBox(height: 10),
                            SuggestionTextFieldWidget(
                              controller: _suggestionController,
                              focusNode: _focusNode,
                              maxChars: _maxChars,
                              minChars: _minChars,
                            ),
                            const SizedBox(height: 16),
                            // AI check button
                            _buildAiCheckButton(),
                            const SizedBox(height: 12),
                            // AI moderation status
                            if (_moderationState != AiModerationState.idle)
                              AiModerationStatusWidget(
                                state: _moderationState,
                                message: _moderationMessage,
                                toxicityScore: _toxicityScore,
                              ),
                            if (_moderationState != AiModerationState.idle)
                              const SizedBox(height: 12),
                            // Cooldown timer
                            if (_isOnCooldown)
                              CooldownTimerWidget(
                                secondsRemaining: _cooldownSeconds,
                              ),
                            if (_isOnCooldown) const SizedBox(height: 12),
                            // Submit button
                            _buildSubmitButton(),
                            const SizedBox(height: 20),
                            const PostGuidelinesWidget(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppNavigation(
        selectedIndex: _navIndex,
        onDestinationSelected: _onNavChanged,
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.homeFeed,
              (_) => false,
            ),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.glassSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textPrimary,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'New Suggestion',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withAlpha(31),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppTheme.neonGreen.withAlpha(77),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, color: AppTheme.neonGreen, size: 12),
                SizedBox(width: 4),
                Text(
                  'Anonymous',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neonGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
            children: [
              TextSpan(
                text: 'Raise Your\n',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              TextSpan(
                text: 'Voice Safely',
                style: TextStyle(color: AppTheme.neonPurple),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'AI reviews every suggestion before it goes live.',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildAiCheckButton() {
    final text = _suggestionController.text.trim();
    final canCheck =
        text.length >= _minChars && _moderationState == AiModerationState.idle;

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: canCheck ? _runAiCheck : null,
        icon: Icon(
          Icons.auto_fix_high_rounded,
          size: 16,
          color: canCheck ? AppTheme.neonPurple : AppTheme.textDisabled,
        ),
        label: Text(
          'Check with AI Moderator',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: canCheck ? AppTheme.neonPurple : AppTheme.textDisabled,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: canCheck
                ? AppTheme.neonPurple.withAlpha(128)
                : AppTheme.glassBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          backgroundColor: canCheck
              ? AppTheme.neonPurple.withAlpha(15)
              : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _canSubmit ? _submitSuggestion : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canSubmit
              ? AppTheme.neonPurple
              : AppTheme.surfaceVariantDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.surfaceVariantDark,
          disabledForegroundColor: AppTheme.textDisabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _isOnCooldown
                        ? 'Cooldown Active'
                        : _moderationState != AiModerationState.approved
                        ? 'Run AI Check First'
                        : 'Submit Anonymously',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
