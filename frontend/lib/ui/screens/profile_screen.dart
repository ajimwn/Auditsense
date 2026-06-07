import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Settings',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _ProfileSidebar(theme: theme),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: _ProfileDetailsForm(theme: theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSidebar extends StatelessWidget {
  final ThemeData theme;
  const _ProfileSidebar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person_rounded, size: 50, color: theme.colorScheme.primary),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('John Auditor', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          Text('Compliance Professional', style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.secondary)),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          _buildMenuItem(Icons.shield_outlined, 'Security Settings'),
          _buildMenuItem(Icons.notifications_none_rounded, 'Notifications'),
          _buildMenuItem(Icons.help_outline_rounded, 'Help & Support'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Color(0xFFFEE2E2)),
              ),
              child: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.secondary),
          const SizedBox(width: 12),
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}

class _ProfileDetailsForm extends StatelessWidget {
  final ThemeData theme;
  const _ProfileDetailsForm({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          _buildField('Full Name', 'John Auditor'),
          const SizedBox(height: 20),
          _buildField('Email Address', 'john.auditor@auditsense.com'),
          const SizedBox(height: 20),
          _buildField('Department', 'Governance, Risk & Compliance'),
          const SizedBox(height: 40),
          Text('System Preferences', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          _buildSwitch('Enable AI Suggestions', true),
          _buildSwitch('Dark Mode (Beta)', false),
          const SizedBox(height: 40),
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: const Text('Save Changes')),
              const SizedBox(width: 16),
              TextButton(onPressed: () {}, child: const Text('Discard')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.secondary)),
        const SizedBox(height: 8),
        TextFormField(initialValue: value),
      ],
    );
  }

  Widget _buildSwitch(String title, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
        Switch(
          value: value, 
          onChanged: (v) {}, 
          activeThumbColor: theme.colorScheme.primary, // Fixed deprecation
        ),
      ],
    );
  }
}
