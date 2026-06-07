import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/audit_item.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'audit_checklist_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  List<AuditItem> _auditItems = [];

  void _handleAnalysisComplete(List<AuditItem> items) {
    setState(() {
      _auditItems = items;
      _selectedIndex = 2; // Switch to Checklist screen
    });
  }

  void _handleAuditItemsUpdated(List<AuditItem> items) {
    setState(() {
      _auditItems = items;
    });
  }

  Widget _buildNavButton(String title, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? theme.colorScheme.primary : const Color(0xFF64748B),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? theme.colorScheme.primary : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<Widget> screens = [
      DashboardScreen(auditItems: _auditItems),
      HomeScreen(onAnalysisComplete: _handleAnalysisComplete),
      AuditChecklistScreen(
        auditItems: _auditItems,
        onItemsChanged: _handleAuditItemsUpdated,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        titleSpacing: 32,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.security_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'AuditSense',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 48),
            if (MediaQuery.of(context).size.width > 900)
              Expanded(
                child: Row(
                  children: [
                    _buildNavButton('Dashboard', Icons.grid_view_rounded, 0),
                    const SizedBox(width: 8),
                    _buildNavButton('Analyze', Icons.document_scanner_rounded, 1),
                    const SizedBox(width: 8),
                    _buildNavButton('Checklist', Icons.fact_check_rounded, 2),
                    const SizedBox(width: 8),
                    _buildNavButton('Profile', Icons.person_rounded, 3),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFFF1F5F9),
                        child: Icon(Icons.person_rounded, size: 16, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'John Auditor',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedIndex == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Overview',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your ISO 27001 compliance progress and document analysis.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedIndex = 1),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text('New Analysis'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: screens[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900
          ? Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: const Color(0xFF64748B),
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
                  BottomNavigationBarItem(icon: Icon(Icons.document_scanner_rounded), label: 'Analyze'),
                  BottomNavigationBarItem(icon: Icon(Icons.fact_check_rounded), label: 'Checklist'),
                  BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
                ],
              ),
            )
          : null,
    );
  }
}
