import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/audit_item.dart';
import '../../data/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(List<AuditItem>, String)? onAnalysisComplete;

  const HomeScreen({super.key, this.onAnalysisComplete});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  List<PlatformFile> _selectedFiles = [];
  final TextEditingController _textController = TextEditingController();

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'txt'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (!_selectedFiles.any((f) => f.name == file.name)) {
              _selectedFiles.add(file);
            }
          }
          _textController.clear();
        });
      }
    } catch (e) {
      _showErrorSnackBar("Error picking files.");
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.publicSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFBC204B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  void _runAnalysis() async {
    final textInput = _textController.text.trim();
    if (_selectedFiles.isEmpty && textInput.isEmpty) return;

    setState(() => _isLoading = true);

    // Fixed: Pass actual file bytes to ApiService for clean backend extraction
    final List<AuditItem>? items = await ApiService.fetchAnalysis(
      textInput,
      files: _selectedFiles,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (items != null) {
      if (widget.onAnalysisComplete != null) {
        // Use text input as originalText for history, or placeholder if files used
        String logText = textInput.isNotEmpty
            ? textInput
            : "[Uploaded Documents: ${_selectedFiles.map((f) => f.name).join(', ')}]";
        widget.onAnalysisComplete!(items, logText);
      }
    } else {
      _showErrorSnackBar(
        "Analysis Engine failed. Please verify system connectivity.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload your policy documents or paste text to match them against ISO 27001 controls.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 32),

                _buildUploadSection(theme, isMobile),
                const SizedBox(height: 32),
                _buildTextSection(theme, isMobile),

                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading ||
                            (_selectedFiles.isEmpty &&
                                _textController.text.isEmpty)
                        ? null
                        : _runAnalysis,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.analytics_outlined),
                              const SizedBox(width: 12),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'START ANALYSIS'.toUpperCase(),
                                  style: const TextStyle(letterSpacing: 1.5),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection(ThemeData theme, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('POLICY DOCUMENTS', style: theme.textTheme.labelLarge),
        const SizedBox(height: 16),
        InkWell(
          onTap: _pickFiles,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: isMobile ? 160 : 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: theme.colorScheme.outline, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.upload_file_rounded,
                  size: isMobile ? 32 : 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Drag and drop or click to upload files',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Supported: PDF, DOCX, TXT',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('SELECTED FILES', style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file_outlined,
                      size: 16,
                      color: Color(0xFF00338D),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFiles[index].name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _removeFile(index),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTextSection(ThemeData theme, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('PASTE TEXT', style: theme.textTheme.labelLarge),
            const SizedBox(width: 8),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          maxLines: isMobile ? 6 : 8,
          style: theme.textTheme.bodyMedium,
          decoration: const InputDecoration(
            hintText: 'Paste specific policy clauses here...',
            fillColor: Colors.white,
          ),
          onChanged: (val) {
            if (val.isNotEmpty && _selectedFiles.isNotEmpty) {
              setState(() => _selectedFiles = []);
            }
            setState(() {});
          },
        ),
      ],
    );
  }
}
