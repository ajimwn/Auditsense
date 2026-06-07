import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/audit_item.dart';

class DashboardScreen extends StatelessWidget {
  final List<AuditItem> auditItems;

  const DashboardScreen({super.key, this.auditItems = const []});

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
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.8,
                  children: [
                    _buildStatCard(
                      context,
                      'Compliance Score',
                      '${_calculateOverallCompliance()}%',
                      Icons.analytics_rounded,
                      theme.colorScheme.primary,
                      '+2.4% from last month',
                    ),
                    _buildStatCard(
                      context,
                      'Total Controls',
                      '${auditItems.length}',
                      Icons.rule_folder_rounded,
                      const Color(0xFF0D9488),
                      'Across all domains',
                    ),
                    _buildStatCard(
                      context,
                      'Applicable',
                      '${_countApplicableControls()}',
                      Icons.check_circle_rounded,
                      const Color(0xFF10B981),
                      'Mapped to policies',
                    ),
                    _buildStatCard(
                      context,
                      'Critical Gaps',
                      '${_countCriticalGaps()}',
                      Icons.warning_amber_rounded,
                      const Color(0xFFEF4444),
                      'Requires action',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildRecentAuditsTable(context),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: _buildDomainComplianceChart(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          Text(
            trend,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: trend.contains('Critical') || trend.contains('Requires') ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainComplianceChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compliance by Domain',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderColor: Theme.of(context).colorScheme.primary,
                    entryRadius: 3,
                    dataEntries: [
                      const RadarEntry(value: 80),
                      const RadarEntry(value: 70),
                      const RadarEntry(value: 95),
                      const RadarEntry(value: 60),
                      const RadarEntry(value: 85),
                    ],
                  ),
                ],
                radarBorderData: const BorderSide(color: Color(0xFFE2E8F0)),
                tickBorderData: const BorderSide(color: Color(0xFFE2E8F0)),
                gridBorderData: const BorderSide(color: Color(0xFFE2E8F0)),
                getTitle: (index, angle) {
                  switch (index) {
                    case 0: return const RadarChartTitle(text: 'Org');
                    case 1: return const RadarChartTitle(text: 'People');
                    case 2: return const RadarChartTitle(text: 'Physical');
                    case 3: return const RadarChartTitle(text: 'Tech');
                    case 4: return const RadarChartTitle(text: 'Policy');
                    default: return const RadarChartTitle(text: '');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAuditsTable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Analysis Logs',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 2)),
                ),
                children: [
                  _buildTableHeader('Document Name'),
                  _buildTableHeader('Date'),
                  _buildTableHeader('Score'),
                  _buildTableHeader('Status'),
                ],
              ),
              _buildTableRow('Information_Security_Policy_v2.pdf', 'Oct 24, 2023', '92%', 'Verified'),
              _buildTableRow('Access_Control_Standard.docx', 'Oct 22, 2023', '78%', 'Flagged'),
              _buildTableRow('Vendor_Risk_Management.pdf', 'Oct 20, 2023', '85%', 'Verified'),
              _buildTableRow('Business_Continuity_Plan.pdf', 'Oct 18, 2023', '90%', 'Verified'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String name, String date, String score, String status) {
    final isFlagged = status == 'Flagged';
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.description_outlined, size: 18, color: Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(date, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(score, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isFlagged ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isFlagged ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  int _countApplicableControls() => auditItems.where((item) => item.applicability == 'Applicable').length;

  int _countCriticalGaps() => auditItems.where((item) {
    return item.applicability == 'Applicable' && item.justification.isEmpty;
  }).length;

  int _calculateOverallCompliance() {
    if (auditItems.isEmpty) return 0;
    final applicable = auditItems.where((item) => item.applicability == 'Applicable').length;
    if (applicable == 0) return 0;
    final compliant = auditItems.where((item) => item.applicability == 'Applicable' && item.justification.isNotEmpty).length;
    return ((compliant / applicable) * 100).round();
  }
}
