import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.accentColor : Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.accentColor : Colors.white,
        ),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: isDark ? null : AppTheme.primaryGradient,
              color: isDark ? AppTheme.primaryColor : null,
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("General"),
                  _buildGlassCard(
                    context,
                    children: [
                      _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: "Dark Mode",
                        subtitle: "Toggle application theme",
                        value: isDark,
                        onChanged: (val) {
                          AppTheme.toggleTheme();
                        },
                      ),
                      const Divider(),
                      _buildListTile(
                        icon: Icons.language_outlined,
                        title: "Language",
                        subtitle: "English",
                        onTap: () {
                          // TODO: Implement Language Selection
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader("Notifications"),
                  _buildGlassCard(
                    context,
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_active_outlined,
                        title: "Push Notifications",
                        subtitle: "Receive updates and tips",
                        value: _notificationsEnabled,
                        onChanged: (val) {
                          setState(() {
                            _notificationsEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  
                  _buildSectionHeader("Support"),
                  _buildGlassCard(
                    context,
                    children: [
                      _buildListTile(
                        icon: Icons.help_outline_rounded,
                        title: "Help Center",
                        onTap: () {},
                      ),
                      const Divider(),
                      _buildListTile(
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacy Policy",
                        onTap: () {},
                      ),
                      const Divider(),
                      _buildListTile(
                        icon: Icons.description_outlined,
                        title: "Terms of Service",
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  
                  _buildSectionHeader("Account"),
                  _buildGlassCard(
                    context,
                    children: [
                      _buildListTile(
                        icon: Icons.lock_outline_rounded,
                        title: "Change Password",
                        onTap: () {},
                      ),
                      const Divider(),
                      _buildListTile(
                        icon: Icons.delete_outline_rounded,
                        title: "Delete Account",
                        titleColor: Colors.redAccent,
                        iconColor: Colors.redAccent,
                        onTap: () {},
                      ),
                    ],
                  ),
                   const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white70 
              : Colors.white70, 
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required List<Widget> children}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveIconColor = iconColor ?? (isDark ? AppTheme.accentColor : AppTheme.primaryColor);
    final Color effectiveTitleColor = titleColor ?? (isDark ? Colors.white : AppTheme.textDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24), // Rough approx, should match container if possible or be clipped
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: effectiveTitleColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white30 : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark ? AppTheme.accentColor : AppTheme.primaryColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }
}
