class AuditItem {
  final String id;
  final String policyText;
  final String isoClause;
  final String theme;
  final int confidence;
  String? status;
  String applicability;
  String justification;
  String notes;

  AuditItem({
    required this.id,
    required this.policyText,
    required this.isoClause,
    required this.theme,
    required this.confidence,
    this.status,
    this.applicability = 'Applicable',
    this.justification = '',
    this.notes = '',
  });

  factory AuditItem.fromMap(Map<String, dynamic> map, String textToAnalyze) {
    return AuditItem(
      id: DateTime.now().millisecondsSinceEpoch.toString() + map.hashCode.toString(),
      policyText: textToAnalyze,
      isoClause: map['match'] ?? 'Unknown Clause',
      theme: map['theme'] ?? 'General Security',
      confidence: (map['confidence'] as num?)?.toInt() ?? 0,
      notes: map['description'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'policy_text': policyText,
      'iso_clause': isoClause,
      'theme': theme,
      'applicability': applicability,
      'justification': justification,
      'confidence': confidence,
      'status': status,
      'notes': notes,
    };
  }
}
