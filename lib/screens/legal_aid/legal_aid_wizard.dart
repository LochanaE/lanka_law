import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';

class LegalAidWizardScreen extends StatefulWidget {
  const LegalAidWizardScreen({super.key});

  @override
  State<LegalAidWizardScreen> createState() => _LegalAidWizardScreenState();
}

class _LegalAidWizardScreenState extends State<LegalAidWizardScreen> {
  int _currentStep = 0;
  
  String? _selectedCaseType;
  String? _selectedDistrict;
  bool? _needsFreeAid;
  String? _urgency;

  final List<String> _caseTypes = ['Family', 'Property', 'Labour', 'Traffic', 'Criminal', 'Human Rights'];
  final List<String> _districts = ['Colombo', 'Kandy', 'Galle', 'Jaffna', 'Gampaha', 'Matara', 'Kurunegala'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Help Wizard",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStep(),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Expanded(
            flex: _currentStep + 1,
            child: Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
          ),
          Expanded(
            flex: 4 - (_currentStep),
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildCaseTypeStep();
      case 1:
        return _buildDistrictStep();
      case 2:
        return _buildFreeAidStep();
      case 3:
        return _buildUrgencyStep();
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildCaseTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("What type of legal help do you need?", "Select the category that best fits your situation."),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _caseTypes.map((type) => _buildChoiceChip(type, _selectedCaseType == type, () {
            setState(() => _selectedCaseType = type);
          })).toList(),
        ),
      ],
    );
  }

  Widget _buildDistrictStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Where are you located?", "We'll find help nearest to you."),
        const SizedBox(height: 30),
        Expanded(
          child: ListView.separated(
            itemCount: _districts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final district = _districts[index];
              return ListTile(
                title: Text(district, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                trailing: _selectedDistrict == district ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor) : null,
                onTap: () => setState(() => _selectedDistrict = district),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFreeAidStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("Do you require free legal aid?", "Free aid is usually available for low-income individuals."),
        const SizedBox(height: 30),
        _buildBigOption("Yes, I need free aid", "I have limited financial resources", Icons.volunteer_activism_rounded, _needsFreeAid == true, () {
          setState(() => _needsFreeAid = true);
        }),
        const SizedBox(height: 15),
        _buildBigOption("No, I can pay/Not sure", "I can afford subsidized or standard fees", Icons.payments_rounded, _needsFreeAid == false, () {
          setState(() => _needsFreeAid = false);
        }),
      ],
    );
  }

  Widget _buildUrgencyStep() {
    final urgencyOptions = [
      {"label": "Urgent today", "sub": "Required immediate action", "icon": Icons.speed_rounded},
      {"label": "Soon", "sub": "Within the next few days", "icon": Icons.calendar_today_rounded},
      {"label": "Not urgent", "sub": "When a professional is available", "icon": Icons.watch_later_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader("How urgent is your situation?", "This helps us prioritize providers for you."),
        const SizedBox(height: 30),
        ...urgencyOptions.map((opt) => Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: _buildBigOption(opt['label'] as String, opt['sub'] as String, opt['icon'] as IconData, _urgency == opt['label'], () {
            setState(() => _urgency = opt['label'] as String);
          }),
        )),
      ],
    );
  }

  Widget _buildStepHeader(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        const SizedBox(height: 8),
        Text(sub, style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildBigOption(String title, String sub, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(icon, color: isSelected ? Colors.white : AppTheme.textLight, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor)),
                  Text(sub, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    bool canProceed = false;
    if (_currentStep == 0) canProceed = _selectedCaseType != null;
    if (_currentStep == 1) canProceed = _selectedDistrict != null;
    if (_currentStep == 2) canProceed = _needsFreeAid != null;
    if (_currentStep == 3) canProceed = _urgency != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Previous"),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_currentStep == 3 ? "Show Results" : "Next"),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      // Navigate to results with filters
      Navigator.pushReplacementNamed(context, '/legal_aid_results', arguments: _selectedCaseType);
    }
  }
}
