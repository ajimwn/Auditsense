import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Since you are building for Web (Microsoft Edge), we use localhost!
  static const String baseUrl = 'http://127.0.0.1:8000';

  // The function is named 'fetchAnalysis'
  static Future<Map<String, dynamic>?> fetchAnalysis(String policyText) async {
    try {
      debugPrint('Sending text to analysis engine for detailed processing...');

      final response = await http.post(
        Uri.parse('$baseUrl/analyze'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": policyText}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error: Server responded with ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('================================');
      debugPrint('HIDDEN FLUTTER ERROR: $e');
      debugPrint('================================');
      return null;
    }
  }
}
