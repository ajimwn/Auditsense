import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/audit_item.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<AuditItem>?> fetchAnalysis(String policyText) async {
    try {
      debugPrint('Sending text to analysis engine...');

      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": policyText}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> resultsList = data.containsKey('results') ? data['results'] : [data];
        
        return resultsList.map((item) => AuditItem.fromMap(item, policyText)).toList();
      } else {
        debugPrint('Server Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Analysis Error: $e');
      return null;
    }
  }
}
