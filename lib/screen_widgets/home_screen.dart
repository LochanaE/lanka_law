import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'package:provider/provider.dart';
import 'package:lanka_law/providers/daily_tip_provider.dart';
import 'dart:async';
import 'package:lanka_law/models/daily_tip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Timer? _carouselTimer;
  int _currentSlideIndex = 0;
  bool _isPaused = false;
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyTipProvider>().fetchTip();
    });

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _currentSlideIndex++;
        });
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _bgAnimController.dispose();
    super.dispose();
  }

  List<String> _buildSlides(DailyTip? tip) {
    if (tip == null) {
      return [
        "\"Ignorantia juris non excusat\" - Ignorance of the law excuses no one. Always stay informed about your rights."
      ];
    }

    final slides = <String>[];
    if (tip.tipEn.isNotEmpty) slides.add(tip.tipEn);
    if (tip.tipSi.isNotEmpty) slides.add(tip.tipSi);
    if (tip.category.isNotEmpty) slides.add("Category: ${tip.category} • Stay compliant.");
    if (tip.sourceRef != null && tip.sourceRef!.isNotEmpty) {
      slides.add("Source: ${tip.sourceRef}");
    }
    
    if (slides.isEmpty) {
      return ["Always stay informed about your rights."];
    }
    
    return slides;
  }

  void _showTipDetailsSettings(BuildContext context, DailyTip tip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Daily Legal Tip",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (tip.category.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tip.category.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                tip.tipEn,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                tip.tipSi,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              if (tip.sourceRef != null && tip.sourceRef!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Source: ${tip.sourceRef}",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedBackground(String category) {
    return AnimatedBuilder(
      animation: _bgAnimController,
      builder: (context, child) {
        if (category == 'motor_traffic') {
          return Stack(
            children: [
              Positioned(
                top: -20 + (_bgAnimController.value * 40),
                right: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.traffic_rounded, size: 120, color: AppTheme.primaryColor),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -10 + (_bgAnimController.value * 20),
                child: Opacity(
                  opacity: 0.05,
                  child: Icon(Icons.directions_car_rounded, size: 100, color: AppTheme.primaryColor),
                ),
              )
            ],
          );
        } else if (category == 'narcotics' || category == 'drugs') {
          return Stack(
            children: [
              Positioned(
                top: 20,
                right: 20,
                child: Opacity(
                  opacity: 0.1 + (_bgAnimController.value * 0.1),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 30,
                child: Opacity(
                  opacity: 0.05 + ((1-_bgAnimController.value) * 0.1),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              )
            ],
          );
        } else {
          // Default background
          return Stack(
            children: [
              Positioned(
                top: -20 + (_bgAnimController.value * 20),
                right: -20 + (_bgAnimController.value * 10),
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -40 + ((1-_bgAnimController.value) * 20),
                left: -20,
                child: Opacity(
                  opacity: 0.05,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "LankaLAW",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: CircleAvatar(
                backgroundColor: AppTheme.accentColor,
                radius: 20,
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.primaryColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              color: AppTheme.backgroundColor,
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome,",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your Legal Assistant",
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(color: Colors.white, height: 1.2),
                        ),
                        const SizedBox(height: 30),

                        // Daily Tip Card
                        Consumer<DailyTipProvider>(
                          builder: (context, provider, child) {
                            final slides = _buildSlides(provider.tip);
                            final currentText = slides[_currentSlideIndex % slides.length];

                            return GestureDetector(
                              onLongPressStart: (_) => setState(() => _isPaused = true),
                              onLongPressEnd: (_) => setState(() => _isPaused = false),
                              onLongPressCancel: () => setState(() => _isPaused = false),
                              onTap: () {
                                if (provider.errorMessage != null) {
                                  provider.fetchTip(forceRefresh: true);
                                } else if (provider.tip != null) {
                                  _showTipDetailsSettings(context, provider.tip!);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.goldGradient,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Animated Background Layer
                                    Positioned.fill(
                                      child: _buildAnimatedBackground(provider.tip?.category ?? ''),
                                    ),
                                    
                                    // Content Layer
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: provider.isLoading 
                                                    ? const SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                                        ),
                                                      )
                                                    : const Icon(
                                                        Icons.lightbulb_outline_rounded,
                                                        color: AppTheme.primaryColor,
                                                        size: 20,
                                                      ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                "Daily Legal Tip",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              if (provider.errorMessage != null)
                                                const Icon(
                                                  Icons.refresh_rounded,
                                                  color: AppTheme.primaryColor,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          if (provider.errorMessage != null)
                                            Text(
                                              provider.errorMessage!,
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                color: AppTheme.primaryColor.withOpacity(0.8),
                                                fontWeight: FontWeight.w500,
                                                height: 1.5,
                                              ),
                                            )
                                          else
                                            AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 500),
                                              transitionBuilder: (Widget child, Animation<double> animation) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(0.0, 0.2),
                                                      end: Offset.zero,
                                                    ).animate(animation),
                                                    child: child,
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                currentText,
                                                key: ValueKey<String>(currentText),
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  color: AppTheme.primaryColor.withOpacity(0.8),
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Services + Bottom CTA Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Services",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            IconButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.more_horiz_rounded,
                                color: Colors.grey,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        GridView.count(
                          crossAxisCount: 2,
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.92,
                          children: [
                            _buildFeatureCard(
                              context,
                              icon: Icons.chat_bubble_outline_rounded,
                              title: "AI Legal\nAssistant",
                              color: Colors.blue.shade50,
                              iconColor: Colors.blue.shade700,
                              onTap: () =>
                                  Navigator.pushNamed(context, '/chat_list'),
                              isPrimary: true,
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.library_books_outlined,
                              title: "Document\nLibrary",
                              color: Colors.orange.shade50,
                              iconColor: Colors.orange.shade700,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/document_library',
                              ),
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.description_outlined,
                              title: "Document\nTemplates",
                              color: Colors.purple.shade50,
                              iconColor: Colors.purple.shade700,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/document_templates',
                              ),
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.history_rounded,
                              title: "Chat\nHistory",
                              color: Colors.green.shade50,
                              iconColor: Colors.green.shade700,
                              onTap: () =>
                                  Navigator.pushNamed(context, '/chat_list'),
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.map_outlined,
                              title: "Legal Aid\nFinder",
                              color: Colors.red.shade50,
                              iconColor: Colors.red.shade700,
                              onTap: () => Navigator.pushNamed(context, '/legal_aid_home'),
                            ),
                            // _buildFeatureCard(
                            //   context,
                            //   icon: Icons.settings_outlined,
                            //   title: "Settings",
                            //   color: Colors.grey.shade100,
                            //   iconColor: Colors.grey.shade700,
                            //   onTap: () {},
                            // ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        _buildHelpCard(context),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: isPrimary
              ? Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  width: 1.5,
                )
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppTheme.primaryColor.withOpacity(0.05)
                    : color.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isPrimary ? AppTheme.primaryColor : iconColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Need help finding the right law?",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Ask the AI assistant and get quick legal guidance in seconds.",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.82),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/chat_list'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "Ask Now",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lanka_law/theme.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: Text(
//           "LankaLAW",
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor:
//             Colors.transparent, // Transparent to show gradient background
//         elevation: 0,
//         centerTitle: false,
//         actions: [
//           IconButton(
//             icon: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.notifications_none_rounded,
//                 color: Colors.white,
//                 size: 20,
//               ),
//             ),
//             onPressed: () {},
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 16.0, left: 8.0),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pushNamed(context, '/profile');
//               },
//               child: CircleAvatar(
//                 backgroundColor: AppTheme.accentColor,
//                 radius: 20,
//                 child: const Icon(
//                   Icons.person,
//                   color: AppTheme.primaryColor,
//                   size: 20,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       backgroundColor: AppTheme.primaryColor,
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: EdgeInsets.zero,
//             child: Container(
//               constraints: BoxConstraints(minHeight: constraints.maxHeight),
//               color: AppTheme.backgroundColor,
//               child: Column(
//                 children: [
//                   // Header Section
//                   Container(
//                     padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
//                     decoration: const BoxDecoration(
//                       gradient: AppTheme.primaryGradient,
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(40),
//                         bottomRight: Radius.circular(40),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Welcome,",
//                           style: GoogleFonts.inter(
//                             fontSize: 16,
//                             color: Colors.white70,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Your Legal Assistant",
//                           style: Theme.of(context).textTheme.displayMedium
//                               ?.copyWith(color: Colors.white, height: 1.2),
//                         ),
//                         const SizedBox(height: 30),
//                         // Daily Tip Card
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.all(24),
//                           decoration: BoxDecoration(
//                             gradient: AppTheme.goldGradient,
//                             borderRadius: BorderRadius.circular(24),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: AppTheme.accentColor.withOpacity(0.3),
//                                 blurRadius: 20,
//                                 offset: const Offset(0, 10),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(8),
//                                     decoration: BoxDecoration(
//                                       color: Colors.black.withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: const Icon(
//                                       Icons.lightbulb_outline_rounded,
//                                       color: AppTheme.primaryColor,
//                                       size: 20,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Text(
//                                     "Daily Legal Tip",
//                                     style: GoogleFonts.poppins(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                       color: AppTheme.primaryColor,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 "\"Ignorantia juris non excusat\" - Ignorance of the law excuses no one. Always stay informed about your rights.",
//                                 style: GoogleFonts.inter(
//                                   fontSize: 15,
//                                   color: AppTheme.primaryColor.withOpacity(0.8),
//                                   fontWeight: FontWeight.w500,
//                                   height: 1.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Grid Section
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Text(
//                               "Services",
//                               style: Theme.of(context).textTheme.headlineSmall,
//                             ),
//                             GestureDetector(
//                               onTap: () {},
//                               child: const Icon(
//                                 Icons.more_horiz_rounded,
//                                 color: Colors.grey,
//                                 size: 22,
//                               ),
//                             ),
//                           ],
//                         ),

//                         GridView.count(
//                           crossAxisCount: 2,
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           crossAxisSpacing: 16,
//                           mainAxisSpacing: 16,
//                           childAspectRatio: 1.0,
//                           children: [
//                             _buildFeatureCard(
//                               context,
//                               icon: Icons.chat_bubble_outline_rounded,
//                               title: "AI Legal\nAssistant",
//                               color: Colors.blue.shade50,
//                               iconColor: Colors.blue.shade700,
//                               onTap: () =>
//                                   Navigator.pushNamed(context, '/chat_list'),
//                               isPrimary: true,
//                             ),
//                             _buildFeatureCard(
//                               context,
//                               icon: Icons.library_books_outlined,
//                               title: "Document\nLibrary",
//                               color: Colors.orange.shade50,
//                               iconColor: Colors.orange.shade700,
//                               onTap: () => Navigator.pushNamed(
//                                 context,
//                                 '/document_library',
//                               ),
//                             ),
//                             _buildFeatureCard(
//                               context,
//                               icon: Icons.description_outlined,
//                               title: "Document\nTemplates",
//                               color: Colors.purple.shade50,
//                               iconColor: Colors.purple.shade700,
//                               onTap: () => Navigator.pushNamed(
//                                 context,
//                                 '/document_templates',
//                               ),
//                             ),
//                             _buildFeatureCard(
//                               context,
//                               icon: Icons.history_rounded,
//                               title: "Chat\nHistory",
//                               color: Colors.green.shade50,
//                               iconColor: Colors.green.shade700,
//                               onTap: () {},
//                             ),
//                             _buildFeatureCard(
//                               context,
//                               icon: Icons.map_outlined,
//                               title: "Legal Aid\nFinder",
//                               color: Colors.red.shade50,
//                               iconColor: Colors.red.shade700,
//                               onTap: () {},
//                             ),
//                             _buildFeatureCard(
//                               context,
//                               icon: Icons.settings_outlined,
//                               title: "Settings",
//                               color: Colors.grey.shade100,
//                               iconColor: Colors.grey.shade700,
//                               onTap: () {},
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildFeatureCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required Color color,
//     required Color iconColor,
//     required VoidCallback onTap,
//     bool isPrimary = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.08),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//           border: isPrimary
//               ? Border.all(
//                   color: AppTheme.primaryColor.withOpacity(0.1),
//                   width: 1.5,
//                 )
//               : Border.all(color: Colors.transparent),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isPrimary
//                     ? AppTheme.primaryColor.withOpacity(0.05)
//                     : color.withOpacity(0.5),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 icon,
//                 color: isPrimary ? AppTheme.primaryColor : iconColor,
//                 size: 28,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: GoogleFonts.inter(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: AppTheme.textDark,
//                 height: 1.2,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
