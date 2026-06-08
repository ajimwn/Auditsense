import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/audit_item.dart';
import '../models/iso_standards.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  /// Sends text or files to the backend for multi-clause analysis.
  /// Fixed: No longer sends binary data as raw strings to avoid gibberish.
  static Future<List<AuditItem>?> fetchAnalysis(String policyText, {List<dynamic>? files}) async {
    try {
      debugPrint('Initiating multi-clause Analysis Engine...');

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/analyze'));

      if (files != null && files.isNotEmpty) {
        // Handle actual file uploads for clean extraction
        for (var file in files) {
          if (file.bytes != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'file',
              file.bytes!,
              filename: file.name,
            ));
          }
        }
      } else {
        // Handle raw pasted text
        request.fields['text'] = policyText;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final List<dynamic> resultsList = jsonDecode(response.body);
        final List<AuditItem> fullList = ISOStandards.getAnnexA2022();
        
        for (var rawItem in resultsList) {
          final String matchedClause = rawItem['match'] ?? '';
          final int confidence = (rawItem['confidence'] as num?)?.toInt() ?? 0;
          
          final int index = fullList.indexWhere((item) => item.isoClause == matchedClause);
          
          if (index != -1) {
            fullList[index].policyText = rawItem['evidence'] ?? '';
            fullList[index].justification = rawItem['justification'] ?? '';
            fullList[index].confidence = confidence;
            fullList[index].isAutomatedMatch = true;
            
            // Map statuses based on Semantic Mapper confidence
            if (confidence >= 80) {
              fullList[index].status = 'Implemented';
            } else if (confidence >= 50) {
              fullList[index].status = 'In Progress';
            } else {
              fullList[index].status = 'Not Implemented';
            }
          }
        }

        debugPrint('Analysis complete. Successfully mapped ${resultsList.length} controls.');
        return fullList;
      } else {
        debugPrint('Server Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Analysis Engine Exception: $e');
      return null;
    }
  }
}
