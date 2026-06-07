import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/data/models/audit_item.dart';
import 'package:frontend/core/utils/export_helper.dart';

class AuditChecklistScreen extends StatefulWidget {
  final List<AuditItem> auditItems;
  final ValueChanged<List<AuditItem>> onItemsChanged;

  const AuditChecklistScreen({
    super.key,
    required this.auditItems,
    required this.onItemsChanged,
  });

  @override
  State<AuditChecklistScreen> createState() => _AuditChecklistScreenState();
}

class _AuditChecklistScreenState extends State<AuditChecklistScreen> {
  late List<AuditItem> _auditItems;

  @override
  void initState() {
    super.initState();
    _auditItems = List.from(widget.auditItems);
  }

  @override
  void didUpdateWidget(AuditChecklistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.auditItems != oldWidget.auditItems) {
      _auditItems = List.from(widget.auditItems);
    }
  }

  void _notifyParent() {
    widget.onItemsChanged(_auditItems);
  }

  Map<String, List<AuditItem>> _groupedItemsByTheme() {
    final grouped = <String, List<AuditItem>>{};
    for (final item in _auditItems) {
      grouped.putIfAbsent(item.theme, () => []).add(item);
    }
    return grouped;
  }

  void _updateStatus(int index, String status) {
    setState(() {
      _auditItems[index].status = status;
    });
    _notifyParent();
  }

  void _updateApplicability(int index, String applicability) {
    setState(() {
      _auditItems[index].applicability = applicability;
    });
    _notifyParent();
  }

  void _updateJustification(int index, String justification) {
    setState(() {
      _auditItems[index].justification = justification;
    });
    _notifyParent();
  }

  void _exportChecklist() {
    final rows = <List<dynamic>>[
      ['ID', 'Policy Text', 'ISO Clause', 'Theme', 'Applicability', 'Justification', 'Confidence', 'Status', 'Notes'],
      ..._auditItems.map((item) => [
        item.id,
        item.policyText,
        item.isoClause,
        item.theme,
        item.applicability,
        item.justification,
        item.confidence,
        item.status ?? '',
        item.notes,
      ]),
    ];

    final csvContent = createCsvContent(rows);
    try {
      downloadCsv('audit_checklist_soa_report.csv', csvContent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audit Checklist exported successfully.'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export failed.'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = _groupedItemsByTheme();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compliance Checklist',
                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Review and justify mapping results for Statement of Applicability.',
                      style: GoogleFonts.inter(color: theme.colorScheme.secondary, fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _exportChecklist,
                  icon: const Icon(Icons.download_rounded, size: 20),
                  label: const Text('Export Report'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _auditItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('No controls mapped yet.', style: GoogleFonts.inter(color: theme.colorScheme.secondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final themeTitle = grouped.keys.elementAt(index);
                      final items = grouped[themeTitle]!;
                      return _buildThemeSection(themeTitle, items);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(String title, List<AuditItem> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          childrenPadding: const EdgeInsets.all(24),
          children: items.map((item) => _buildControlItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildControlItem(AuditItem item) {
    final index = _auditItems.indexOf(item);
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.isoClause,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.policyText,
                      style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: const Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              _buildConfidenceBadge(item.confidence),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Applicability', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: item.applicability,
                      items: ['Applicable', 'Not Applicable']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      onChanged: (val) => _updateApplicability(index, val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Audit Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatusChip(
                          label: 'Compliant',
                          selected: item.status == 'Compliant',
                          color: const Color(0xFF10B981),
                          onTap: () => _updateStatus(index, 'Compliant'),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: 'Gap',
                          selected: item.status == 'Gap',
                          color: const Color(0xFFEF4444),
                          onTap: () => _updateStatus(index, 'Gap'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Justification & Evidence', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: item.justification,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Enter justification for compliance or exclusion...',
              fillColor: Colors.white,
            ),
            onChanged: (val) => _updateJustification(index, val),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge(int confidence) {
    Color color = confidence > 80 ? const Color(0xFF10B981) : (confidence > 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        '$confidence% Match',
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
