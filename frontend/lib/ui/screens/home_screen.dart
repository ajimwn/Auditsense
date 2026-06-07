import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/audit_item.dart';
import '../../data/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<List<AuditItem>>? onAnalysisComplete;

  const HomeScreen({super.key, this.onAnalysisComplete});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  PlatformFile? _selectedFile;
  final TextEditingController _textController = TextEditingController();

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        withData: true,
      );

      if (result != null) {
        final file = result.files.single;
        if (file.size > 10 * 1024 * 1024) {
          _showErrorSnackBar("File too large. Maximum size is 10MB.");
          return;
        }
        setState(() {
          _selectedFile = file;
          _textController.clear();
        });
      }
    } catch (e) {
      _showErrorSnackBar("Error picking file.");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _runAnalysis() async {
    final textInput = _textController.text.trim();
    if (_selectedFile == null && textInput.isEmpty) return;

    setState(() => _isLoading = true);

    String textToAnalyze = "";
    if (textInput.isNotEmpty) {
      textToAnalyze = textInput;
    } else if (_selectedFile != null) {
      if (_selectedFile!.extension?.toLowerCase() == 'txt' && _selectedFile!.bytes != null) {
        textToAnalyze = utf8.decode(_selectedFile!.bytes!);
      } else {
        textToAnalyze = "Mock extracted text from ${_selectedFile!.name}. Access control must be strictly enforced.";
      }
    }

    final List<AuditItem>? items = await ApiService.fetchAnalysis(textToAnalyze);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (items != null) {
      if (widget.onAnalysisComplete != null) {
        widget.onAnalysisComplete!(items);
      }
    } else {
      _showErrorSnackBar("Analysis failed. Please check your connection.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analyze Document',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your policy document or paste text to map it against ISO 27001 controls.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 48),

                _buildSectionCard(
                  title: 'Policy Text',
                  icon: Icons.text_fields_rounded,
                  child: TextField(
                    controller: _textController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Paste your policy content here...',
                      fillColor: Color(0xFFF8FAFC),
                    ),
                    onChanged: (val) {
                      if (val.isNotEmpty) setState(() => _selectedFile = null);
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),

                _buildSectionCard(
                  title: 'Upload Document',
                  icon: Icons.upload_file_rounded,
                  child: InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline, width: 2, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 48, color: theme.colorScheme.primary),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFile?.name ?? 'Select PDF, DOCX, or TXT',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text('Maximum file size: 10MB', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runAnalysis,
                    child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                      : const Text('Start Analysis'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
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
            children: [
              Icon(icon, size: 20, color: const Color(0xFF64748B)),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
