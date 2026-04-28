import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class UploadFormScreen extends StatefulWidget {
  const UploadFormScreen({super.key});

  @override
  State<UploadFormScreen> createState() => _UploadFormScreenState();
}

class _UploadFormScreenState extends State<UploadFormScreen> {
  final _api = ApiService();
  final _title = TextEditingController();
  final _description = TextEditingController();
  
  PlatformFile? _pickedFile;
  String? _selectedCategoryId;
  String? _selectedFacultyId;
  String? _selectedProgramId;
  String? _selectedYear;
  
  List<Category> _categories = [];
  List<Faculty> _faculties = [];
  List<Program> _programs = [];
  
  bool _loading = true;
  bool _loadingPrograms = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _api.getCategories(),
        _api.getFaculties(),
      ]);
      setState(() {
        _categories = (results[0] as List).map((e) => e is Category ? e : Category.fromJson(e)).toList();
        _faculties = (results[1] as List).map((e) => e is Faculty ? e : Faculty.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        
        // Fallback if empty
        if (_categories.isEmpty) {
          _categories = [
            const Category(id: '00000000-0000-0000-0000-000000000001', name: 'Textbooks'),
            const Category(id: '00000000-0000-0000-0000-000000000002', name: 'Past Papers'),
            const Category(id: '00000000-0000-0000-0000-000000000003', name: 'Study Guides'),
            const Category(id: '00000000-0000-0000-0000-000000000004', name: 'Notes'),
          ];
        }
        if (_faculties.isEmpty) {
          _faculties = [
            const Faculty(id: '00000000-0000-0000-0000-000000000005', name: 'Faculty of Engineering'),
            const Faculty(id: '00000000-0000-0000-0000-000000000006', name: 'Faculty of Computing & Informatics'),
            const Faculty(id: '00000000-0000-0000-0000-000000000007', name: 'Faculty of Health & Applied Sciences'),
            const Faculty(id: '00000000-0000-0000-0000-000000000008', name: 'Faculty of Management Sciences'),
          ];
        }
        
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading upload form data: $e');
      setState(() {
        // Fallback data for development/demo
        _categories = [
          const Category(id: '00000000-0000-0000-0000-000000000001', name: 'Textbooks'),
          const Category(id: '00000000-0000-0000-0000-000000000002', name: 'Past Papers'),
          const Category(id: '00000000-0000-0000-0000-000000000003', name: 'Study Guides'),
        ];
        _faculties = [
          const Faculty(id: '00000000-0000-0000-0000-000000000005', name: 'Faculty of Engineering'),
          const Faculty(id: '00000000-0000-0000-0000-000000000006', name: 'Faculty of Computing & Informatics'),
        ];
        _loading = false;
      });
    }
  }

  Future<void> _loadPrograms(String facultyId) async {
    setState(() => _loadingPrograms = true);
    try {
      final results = await _api.getPrograms(facultyId);
      setState(() {
        _programs = results.map((e) => Program.fromJson(e)).toList();
        if (_programs.isEmpty) {
          _programs = [
            const Program(id: '10000000-0000-0000-0000-000000000001', name: 'BSc Computer Science'),
            const Program(id: '10000000-0000-0000-0000-000000000002', name: 'BSc Software Engineering'),
          ];
        }
        _loadingPrograms = false;
      });
    } catch (e) {
      debugPrint('Error loading programs: $e');
      setState(() {
        _programs = [
          const Program(id: '10000000-0000-0000-0000-000000000001', name: 'Sample Program 1'),
          const Program(id: '10000000-0000-0000-0000-000000000002', name: 'Sample Program 2'),
        ];
        _loadingPrograms = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
        if (_title.text.isEmpty) {
          _title.text = _pickedFile!.name.split('.').first;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_pickedFile == null || _title.text.isEmpty || _selectedCategoryId == null || _selectedFacultyId == null || _selectedProgramId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF and fill all required fields')),
      );
      return;
    }

    setState(() => _submitting = true);
    final auth = context.read<AuthService>();
    
    try {
      // 1. Upload file to Storage
      final uploadRes = await _api.uploadFile(
        _pickedFile!.bytes!,
        _pickedFile!.name,
        folder: 'pdfs',
      );

      final fileUrl = uploadRes['url'];

      // 2. Create database entry
      await _api.createUpload({
        'title': _title.text,
        'description': _description.text,
        'category_id': _selectedCategoryId,
        'faculty_id': _selectedFacultyId,
        'program_id': _selectedProgramId,
        'year': _selectedYear,
        'author': auth.displayName,
        'file_url': fileUrl,
        'user_id': auth.user?['id'],
      });
      
      if (mounted) {
        context.push('/upload/progress');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Upload Resource', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A0E0C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF Picker Section
            GestureDetector(
              onTap: _submitting ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _pickedFile != null ? const Color(0xFFF0FDF4) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _pickedFile != null ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0), 
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _pickedFile != null ? Symbols.check_circle : Symbols.upload_file, 
                      size: 48, 
                      color: _pickedFile != null ? const Color(0xFF16A34A) : const Color(0xFFFF3D1B)
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _pickedFile?.name ?? 'Select PDF Document', 
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _pickedFile != null 
                        ? '${(_pickedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'
                        : 'Maximum file size: 50MB', 
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _pickFile,
                      style: FilledButton.styleFrom(
                        backgroundColor: _pickedFile != null 
                          ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                          : const Color(0xFFFF3D1B).withValues(alpha: 0.1),
                        foregroundColor: _pickedFile != null ? const Color(0xFF16A34A) : const Color(0xFFFF3D1B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_pickedFile != null ? 'Change File' : 'Browse Files'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Document Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Form Fields
            _buildFieldLabel('Book Name *'),
            TextField(
              controller: _title,
              decoration: _inputDecoration('Enter document title'),
            ),
            
            const SizedBox(height: 20),
            _buildFieldLabel('Uploaded By'),
            TextField(
              enabled: false,
              decoration: _inputDecoration(auth.displayName).copyWith(
                fillColor: const Color(0xFFF1F5F9),
              ),
            ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Academic Year'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedYear,
                        decoration: _inputDecoration('Year'),
                        hint: const Text('Select year'),
                        items: ['1', '2', '3', '4', 'Honours', 'Masters'].map((y) => 
                          DropdownMenuItem(value: y, child: Text('Year $y'))).toList(),
                        onChanged: (val) => setState(() => _selectedYear = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Category *'),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedCategoryId,
                        decoration: _inputDecoration('Category'),
                        hint: const Text('Select category'),
                        items: _categories.map((c) => 
                          DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) => setState(() => _selectedCategoryId = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildFieldLabel('Faculty *'),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedFacultyId,
              decoration: _inputDecoration('Faculty'),
              hint: const Text('Select faculty'),
              items: _faculties.map((f) => 
                DropdownMenuItem(value: f.id, child: Text(f.name, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedFacultyId = val;
                  _selectedProgramId = null;
                  _programs = [];
                });
                if (val != null) _loadPrograms(val);
              },
            ),

            const SizedBox(height: 20),
            _buildFieldLabel('Programme *'),
            DropdownButtonFormField<String>(
              isExpanded: true,
              key: ValueKey(_selectedFacultyId), // Reset when faculty changes
              initialValue: _selectedProgramId,
              decoration: _inputDecoration('Programme'),
              hint: Text(_selectedFacultyId == null 
                  ? 'Select faculty first' 
                  : (_loadingPrograms ? 'Loading programs...' : 'Select programme')),
              items: _programs.map((p) => 
                DropdownMenuItem(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (val) => setState(() => _selectedProgramId = val),
              disabledHint: Text(_selectedFacultyId == null ? 'Select a faculty first' : 'Loading programs...'),
            ),

            const SizedBox(height: 20),
            _buildFieldLabel('Description'),
            TextField(
              controller: _description,
              maxLines: 4,
              decoration: _inputDecoration('Briefly describe the content'),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3D1B),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _submitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit for Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569))),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF3D1B), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
