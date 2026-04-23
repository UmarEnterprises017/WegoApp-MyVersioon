import 'package:flutter/material.dart';

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  static const Color primaryRed = Color(0xFFEF4060);
  // static const Color _lightRed = Color(0xFFFFECEF);

  // null = nothing selected
  String? _selectedGender;

  final List<Map<String, dynamic>> _genderOptions = [
    {'label': 'Woman', 'hasArrow': false},
    {'label': 'Man', 'hasArrow': false},
    {'label': 'Choose another', 'hasArrow': true},
  ];

  void _handleContinue() {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an option to continue'),
          backgroundColor: primaryRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
    // TODO: Navigate to next screen
    debugPrint('Selected gender: $_selectedGender');
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: Icon(Icons.arrow_back_ios,
                          color: textColor, size: 18),
                      padding: EdgeInsets.zero,
                    ),
                  ),

                  // Skip Button
                  TextButton(
                    onPressed: () {
                      // TODO: Skip action
                      debugPrint('Skipped');
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: primaryRed,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // "I am a" Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'I am a',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Gender Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: _genderOptions.map((option) {
                  final label = option['label'] as String;
                  final hasArrow = option['hasArrow'] as bool;
                  final isSelected = _selectedGender == label;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildOptionTile(
                      label: label,
                      isSelected: isSelected,
                      hasArrow: hasArrow,
                      textColor: textColor,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          _selectedGender = label;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const Spacer(),

            // Continue Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                    shadowColor: primaryRed.withValues(alpha: 0.4),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required String label,
    required bool isSelected,
    required bool hasArrow,
    required Color textColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? primaryRed : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryRed : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: primaryRed.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            // Right icon: checkmark if selected or arrow, grey check if not
            Icon(
              hasArrow
                  ? Icons.arrow_forward_ios
                  : Icons.check,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white38 : Colors.grey.shade400),
              size: hasArrow ? 16 : 20,
            ),
          ],
        ),
      ),
    );
  }
}