import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        backgroundColor:
            Colors.transparent, // Transparent to show gradient background
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
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
                                    child: const Icon(
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
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "\"Ignorantia juris non excusat\" - Ignorance of the law excuses no one. Always stay informed about your rights.",
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: AppTheme.primaryColor.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Grid Section
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
                            GestureDetector(
                              onTap: () {},
                              child: const Icon(
                                Icons.more_horiz_rounded,
                                color: Colors.grey,
                                size: 22,
                              ),
                            ),
                          ],
                        ),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
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
                              onTap: () {},
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.map_outlined,
                              title: "Legal Aid\nFinder",
                              color: Colors.red.shade50,
                              iconColor: Colors.red.shade700,
                              onTap: () {},
                            ),
                            _buildFeatureCard(
                              context,
                              icon: Icons.settings_outlined,
                              title: "Settings",
                              color: Colors.grey.shade100,
                              iconColor: Colors.grey.shade700,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
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
}
