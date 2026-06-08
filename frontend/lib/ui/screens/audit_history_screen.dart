import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/audit_item.dart';

class AuditHistoryItem {
  final String id;
  final DateTime date;
  final int controlCount;
  final int complianceScore;
  final List<AuditItem> results;
  final String originalText; // Added to support re-analysis

  AuditHistoryItem({
    required this.id,
    required this.date,
    required this.controlCount,
    required this.complianceScore,
    required this.results,
    required this.originalText,
  });
}

class AuditHistoryScreen extends StatelessWidget {
  final List<AuditHistoryItem> history;
  final Function(List<AuditItem>) onLoadAudit;
  final Function(String) onReanalyze; // Added re-analyze callback

  const AuditHistoryScreen({
    super.key,
    required this.history,
    required this.onLoadAudit,
    required this.onReanalyze,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'View and resume your past audit sessions.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: 48),

            if (history.isEmpty)
              _buildEmptyState(theme)
            else
              _buildAuditList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(80),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 32),
            Text('Audit Repository Empty', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text('Your verified audit sessions will be securely archived here for lifecycle management.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditList(ThemeData theme) {
    return Column(
      children: history.map((item) {
        final implemented = item.results.where((i) => i.status == 'Implemented').length;
        final inProgress = item.results.where((i) => i.status == 'In Progress').length;
        final notImplemented = item.results.where((i) => i.status == 'Not Implemented').length;

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D5DB)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: const Color(0xFF00338D).withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.verified_user_outlined, color: Color(0xFF00338D), size: 32),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AUDIT ID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: theme.colorScheme.primary, letterSpacing: 2)),
                          const SizedBox(height: 6),
                          Text(item.id, style: theme.textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _infoBadge(Icons.calendar_today_rounded, '${item.date.day}/${item.date.month}/${item.date.year}'),
                              const SizedBox(width: 24),
                              _infoBadge(Icons.inventory_2_outlined, '${item.controlCount} Total Controls'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item.complianceScore}%', style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w900, color: const Color(0xFF00338D))),
                        const Text('FINAL SCORE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                      ],
                    ),
                    const SizedBox(width: 48),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => onLoadAudit(item.results),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00338D),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('VIEW / UPDATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => onReanalyze(item.originalText),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            side: const BorderSide(color: Color(0xFF00338D)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('RE-ANALYZE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: Color(0xFF00338D))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                color: const Color(0xFFF9FAFB),
                child: Row(
                  children: [
                    _statusSummaryBadge('IMPLEMENTED', implemented, const Color(0xFF00A36C)),
                    const SizedBox(width: 32),
                    _statusSummaryBadge('IN PROGRESS', inProgress, const Color(0xFFE9A115)),
                    const SizedBox(width: 32),
                    _statusSummaryBadge('NON-COMPLIANT', notImplemented, const Color(0xFFBC204B)),
                    const Spacer(),
                    const Text('AUDITED BY JOHN AUDITOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                  ],
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _infoBadge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _statusSummaryBadge(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Text('$count', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5)),
      ],
    );
  }
}
