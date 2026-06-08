import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/audit_item.dart';
import '../../data/models/iso_standards.dart';
import '../../data/services/api_service.dart';
import 'dashboard_screen.dart';
import 'home_screen.dart';
import 'audit_checklist_screen.dart';
import 'audit_history_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  List<AuditItem> _auditItems = [];
  String? _pendingChecklistFilter;
  final List<AuditHistoryItem> _auditHistory = [];
  bool _isGlobalLoading = false;

  @override
  void initState() {
    super.initState();
    _auditItems = ISOStandards.getAnnexA2022();
  }

  void _handleAnalysisComplete(List<AuditItem> items, String originalText) {
    setState(() {
      _auditItems = items;
      _selectedIndex = 2;
      _pendingChecklistFilter = null;
      _saveToHistory(items, originalText);
    });
  }

  void _handleReanalyze(String text) async {
    setState(() => _isGlobalLoading = true);

    final items = await ApiService.fetchAnalysis(text);

    if (items != null) {
      _handleAnalysisComplete(items, text);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Re-analysis failed. Check connectivity.'),
          ),
        );
      }
    }

    if (mounted) setState(() => _isGlobalLoading = false);
  }

  void _saveToHistory(List<AuditItem> items, String originalText) {
    final score = _calculateComplianceScore(items);
    _auditHistory.insert(
      0,
      AuditHistoryItem(
        id: "AUD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        date: DateTime.now(),
        controlCount: items.length,
        complianceScore: score,
        results: items.map((i) => i.copy()).toList(),
        originalText: originalText,
      ),
    );
  }

  int _calculateComplianceScore(List<AuditItem> items) {
    final applicable = items
        .where((i) => i.applicability == 'Applicable')
        .toList();
    if (applicable.isEmpty) return 0;
    final implemented = applicable
        .where((i) => i.status == 'Implemented')
        .length;
    return ((implemented / applicable.length) * 100).round();
  }

  void _handleAuditItemsUpdated(List<AuditItem> items) {
    setState(() {
      _auditItems = items;
    });
  }

  void _handleLoadAudit(List<AuditItem> historicalItems) {
    setState(() {
      _auditItems = historicalItems.map((i) => i.copy()).toList();
      _selectedIndex = 2;
    });
  }

  void _handleNavigation(int index, String? filter) {
    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _pendingChecklistFilter = filter;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    final List<Widget> screens = [
      DashboardScreen(
        auditItems: _auditItems,
        history: _auditHistory,
        onNavigate: _handleNavigation,
      ),
      HomeScreen(onAnalysisComplete: _handleAnalysisComplete),
      AuditChecklistScreen(
        auditItems: _auditItems,
        onItemsChanged: _handleAuditItemsUpdated,
        initialFilter: _pendingChecklistFilter,
      ),
      AuditHistoryScreen(
        history: _auditHistory,
        onLoadAudit: _handleLoadAudit,
        onReanalyze: _handleReanalyze,
      ),
      const ProfileScreen(),
    ];

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            toolbarHeight: 80,
            titleSpacing: 32,
            backgroundColor: Colors.white,
            elevation: 0,
            shape: const Border(
              bottom: BorderSide(color: Color(0xFFD1D5DB), width: 1),
            ),
            title: Row(
              children: [
                Text(
                  'AuditSense',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(width: 48),
                if (isDesktop)
                  Expanded(
                    child: Row(
                      children: [
                        _buildTopNavButton(
                          'Dashboard',
                          Icons.grid_view_rounded,
                          0,
                        ),
                        const SizedBox(width: 8),
                        _buildTopNavButton(
                          'Analyze',
                          Icons.analytics_outlined,
                          1,
                        ),
                        const SizedBox(width: 8),
                        _buildTopNavButton(
                          'Checklist',
                          Icons.fact_check_rounded,
                          2,
                        ),
                        const SizedBox(width: 8),
                        _buildTopNavButton(
                          'My Audit',
                          Icons.history_rounded,
                          3,
                        ),
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
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Color(0xFF6B7280),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildProfileDropdown(theme),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFD1D5DB))),
                ),
                child: Text(
                  _getScreenTitle().toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 2,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: IndexedStack(index: _selectedIndex, children: screens),
              ),
            ],
          ),
          bottomNavigationBar: !isDesktop ? _buildMobileNav(theme) : null,
        ),
        if (_isGlobalLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Analyze';
      case 2:
        return 'Checklist';
      case 3:
        return 'My Audit';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }

  Widget _buildTopNavButton(String label, IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.primary
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.publicSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDropdown(ThemeData theme) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'John Auditor',
              style: GoogleFonts.publicSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
      onSelected: (val) {
        if (val == 1) {
          setState(() => _selectedIndex = 4);
        } else if (val == 2) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: 1,
          child: _menuItem(Icons.person_outline_rounded, 'My Profile'),
        ),
        PopupMenuItem(
          value: 2,
          child: _menuItem(
            Icons.logout_rounded,
            'Logout',
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileNav(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex > 3 ? 0 : _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: const Color(0xFF6B7280),
      selectedLabelStyle: GoogleFonts.publicSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
      unselectedLabelStyle: GoogleFonts.publicSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'DASHBOARD',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics_outlined),
          label: 'ANALYZE',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fact_check_rounded),
          label: 'CHECKLIST',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'MY AUDIT',
        ),
      ],
    );
  }
}
