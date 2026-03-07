import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lanka_law/services/auth_service.dart';
import 'package:lanka_law/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  String? _role;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (_user != null) {
      String? role = await _authService.getUserRole(_user!.uid);
      if (mounted) {
        setState(() {
          _role = role;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _showImagePickerOptions() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.primaryLight : AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Profile Picture",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppTheme.accentColor),
                  title: Text("Take a Photo", style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppTheme.accentColor),
                  title: Text("Choose from Gallery", style: TextStyle(color: isDark ? Colors.white : AppTheme.textDark)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_user?.photoURL != null) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text("Remove Photo", style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      _deleteProfilePicture();
                    },
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => _isUploading = true);

        final File imageFile = File(pickedFile.path);
        await _authService.uploadProfilePicture(imageFile);

        if (mounted) {
          await _authService.currentUser?.reload();
          setState(() {
            _user = _authService.currentUser;
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile picture updated successfully!")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile picture: $e")),
        );
      }
    }
  }

  Future<void> _deleteProfilePicture() async {
    setState(() => _isUploading = true);

    try {
      await _authService.deleteProfilePicture();
      if (mounted) {
        await _authService.currentUser?.reload();
        setState(() {
          _user = _authService.currentUser;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture removed.")),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to remove profile picture: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("My Profile", style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Avatar
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_user != null) _showImagePickerOptions();
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.goldGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 65,
                                  backgroundColor: isDark ? AppTheme.primaryLight : Colors.white,
                                  backgroundImage: _user?.photoURL != null && _user!.photoURL!.isNotEmpty
                                      ? NetworkImage(_user!.photoURL!) 
                                      : null,
                                  child: _user?.photoURL == null || _user!.photoURL!.isEmpty
                                      ? Text(
                                          _user != null
                                              ? (_user?.displayName != null &&
                                                      _user!.displayName!.isNotEmpty
                                                  ? _user!.displayName![0].toUpperCase()
                                                  : (_user?.email != null &&
                                                          _user!.email!.isNotEmpty
                                                      ? _user!.email![0].toUpperCase()
                                                      : "U"))
                                              : "G",
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 52,
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                if (_isUploading)
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(color: AppTheme.accentColor),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (_user != null)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.accentColor, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.camera_alt, color: AppTheme.accentColor, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  // Name and Role underneath
                  Text(
                    _user?.displayName != null && _user!.displayName!.isNotEmpty ? _user!.displayName! : "Update your name",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontStyle: (_user?.displayName == null || _user!.displayName!.isEmpty) ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user != null ? (_role?.toUpperCase() ?? "Loading...") : "GUEST",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.primaryLight : AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          icon: Icons.person_outline,
                          label: "Full Name",
                          value: _user?.displayName != null && _user!.displayName!.isNotEmpty ? _user!.displayName! : "Not updated yet",
                          isPlaceholder: _user?.displayName == null || _user!.displayName!.isEmpty,
                          isDark: isDark,
                        ),
                        Divider(height: 32, color: isDark ? Colors.white10 : Colors.grey.shade200),
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: "Email Address",
                          value: _user?.email != null && _user!.email!.isNotEmpty ? _user!.email! : "No email provided",
                          isPlaceholder: _user?.email == null || _user!.email!.isEmpty,
                          isDark: isDark,
                        ),
                        Divider(height: 32, color: isDark ? Colors.white10 : Colors.grey.shade200),
                        _buildInfoRow(
                          icon: Icons.badge_outlined,
                          label: "Account Role",
                          value: _user != null ? (_role ?? "Loading...") : "Guest Account",
                          isPlaceholder: _user == null,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              _user != null
                                  ? Icons.logout_rounded
                                  : Icons.login_rounded,
                              color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Text(
                            _user != null ? "Logout" : "Log In",
                            style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isPlaceholder = false,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.primaryColor : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: isPlaceholder ? (isDark ? Colors.grey.shade500 : Colors.grey.shade400) : (isDark ? Colors.white : AppTheme.textDark),
                  fontSize: 16,
                  fontWeight: isPlaceholder ? FontWeight.w400 : FontWeight.w600,
                  fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
