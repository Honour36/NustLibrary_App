import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  final ApiService _api = ApiService();
  
  int _currentStep = 0;
  final int _totalSteps = 5;

  List<Map<String, dynamic>> _faculties = [];
  List<Map<String, dynamic>> _programs = [];
  
  String? _selectedFacultyId;
  String? _selectedProgramId;
  String? _selectedYear;
  final TextEditingController _feedbackController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFaculties();
  }

  Future<void> _loadFaculties() async {
    setState(() => _isLoading = true);
    try {
      _faculties = await _api.getFaculties();
    } catch (e) {
      debugPrint('Error loading faculties: $e');
      // Fallback/Mock for development if API fails - Matching NUST Faculties
      _faculties = [
        {'id': 'f1', 'name': 'Faculty of Engineering'},
        {'id': 'f2', 'name': 'Faculty of Computing & Informatics'},
        {'id': 'f3', 'name': 'Faculty of Health & Applied Sciences'},
        {'id': 'f4', 'name': 'Faculty of Management Sciences'},
        {'id': 'f5', 'name': 'Faculty of Applied Science'},
        {'id': 'f6', 'name': 'Faculty of Business and Economic Sciences'},
      ];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPrograms(String facultyId) async {
    setState(() => _isLoading = true);
    try {
      _programs = await _api.getPrograms(facultyId);
    } catch (e) {
      debugPrint('Error loading programs: $e');
      // Fallback/Mock for development
      _programs = [
        {'id': 'p1', 'name': 'BSc Honours in Computer Science'},
        {'id': 'p2', 'name': 'BSc Honours in Software Engineering'},
        {'id': 'p3', 'name': 'BSc Honours in Informatics'},
        {'id': 'p4', 'name': 'BSc Honours in Cyber Security'},
      ];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _complete() async {
    final auth = context.read<AuthService>();
    setState(() => _isLoading = true);
    try {
      await _api.submitOnboardingCompletion(
        userId: auth.user!['id'],
        facultyId: _selectedFacultyId!,
        programId: _selectedProgramId!,
        year: _selectedYear!,
        feedback: _feedbackController.text,
      );
      await auth.completeOnboarding();
      if (mounted) context.go('/');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to complete onboarding: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNav(),
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFacultyStep(),
                  _buildProgramStep(),
                  _buildYearStep(),
                  _buildFeedbackStep(),
                  _buildAllSetStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _currentStep > 0 && _currentStep < _totalSteps - 1
                ? IconButton(
                    icon: const Icon(Symbols.arrow_back_ios_new, color: Color(0xFF1A0E0C), size: 20),
                    onPressed: _previousPage,
                  )
                : const SizedBox(width: 48),
          ),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (_currentStep + 1) / _totalSteps,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
            colors: [Color(0xFFFF3D1B), Color(0xFFFF6B4A)],
            ),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildFacultyStep() {
    return _buildStepLayout(
      image: 'assets/images/Research paper-amico.svg',
      title: 'Choose your Faculty',
      subtitle: 'Which department will you be calling home?',
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: _selectedFacultyId,
        decoration: _inputDecoration('Faculty', Symbols.school),
        items: _faculties.map((f) {
          return DropdownMenuItem<String>(
            value: f['id'].toString(),
            child: Text(f['name'].toString(), overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            _selectedFacultyId = val;
            _selectedProgramId = null;
            _programs = [];
          });
          if (val != null) _loadPrograms(val);
        },
        hint: const Text('Select Faculty'),
      ),
      onContinue: _selectedFacultyId != null ? _nextPage : null,
    );
  }

  Widget _buildProgramStep() {
    return _buildStepLayout(
      image: 'assets/images/Learning-pana.svg',
      title: 'Select your Program',
      subtitle: 'Tell us exactly what you are studying.',
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        key: ValueKey(_selectedFacultyId),
        initialValue: _selectedProgramId,
        decoration: _inputDecoration('Program', Symbols.book_5),
        items: _programs.map((p) {
          return DropdownMenuItem<String>(
            value: p['id'].toString(),
            child: Text(p['name'].toString(), overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedProgramId = val),
        hint: const Text('Select Program'),
        disabledHint: const Text('Select a faculty first'),
      ),
      onContinue: _selectedProgramId != null ? _nextPage : null,
    );
  }

  Widget _buildYearStep() {
    final years = ['Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Postgraduate'];
    return _buildStepLayout(
      image: 'assets/images/Bibliophile-bro.svg',
      title: 'Current Year',
      subtitle: 'How far along are you in your journey?',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: years.map((year) {
          final isSelected = _selectedYear == year;
          return InkWell(
            onTap: () => setState(() => _selectedYear = year),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF3D1B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF3D1B) : const Color(0xFFE2E8F0),
                  width: 2,
                ),
                boxShadow: isSelected 
                  ? [BoxShadow(color: const Color(0xFFFF3D1B).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                  : [],
              ),
              child: Text(
                year,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1A0E0C),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      onContinue: _selectedYear != null ? _nextPage : null,
    );
  }

  Widget _buildFeedbackStep() {
    return _buildStepLayout(
      image: 'assets/images/Collab-bro.svg',
      title: 'The Ceremonial Hall',
      subtitle: 'Quick question: What do you think of the ceremonial hall?',
      child: TextField(
        controller: _feedbackController,
        maxLines: 4,
        onChanged: (val) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Share your thoughts...',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFFF3D1B), width: 2),
          ),
        ),
      ),
      onContinue: _feedbackController.text.trim().isNotEmpty ? _nextPage : null,
    );
  }

  Widget _buildAllSetStep() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Symbols.check_circle, size: 80, color: Color(0xFF22C55E), fill: 1),
          ),
          const SizedBox(height: 40),
          const Text(
            "You're all set!",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A0E0C)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome to the NUST Library. Your personal study shelf is ready and waiting.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 18, height: 1.5),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton(
              onPressed: _isLoading ? null : _complete,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF3D1B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('Enter Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLayout({
    required String image,
    required String title,
    required String subtitle,
    required Widget child,
    VoidCallback? onContinue,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SvgPicture.asset(
              image,
              height: 220,
              placeholderBuilder: (context) => Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Symbols.image, size: 48, color: Color(0xFF94A3B8)),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A0E0C), letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 32),
          child,
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF3D1B),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFFF3D1B), size: 24),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFFF3D1B), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
    );
  }
}
