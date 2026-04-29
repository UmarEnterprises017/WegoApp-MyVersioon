import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wego_marriage/screen/otp_screen.dart';

class NbrScreen extends StatefulWidget {
  const NbrScreen({super.key});

  @override
  State<NbrScreen> createState() => _NbrScreenState();
}

class _NbrScreenState extends State<NbrScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+92';
  String _selectedCountryFlag = 'PK';
  String? _phoneError;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const Color primaryBlue = Color(0xFF4A6CF7);

  final List<Map<String, String>> _countries = [
    {'name': 'India', 'flag': 'IN', 'code': '+91'},
    {'name': 'Pakistan', 'flag': 'PK', 'code': '+92'},
    {'name': 'United States', 'flag': 'US', 'code': '+1'},
    {'name': 'United Kingdom', 'flag': 'GB', 'code': '+44'},
    {'name': 'UAE', 'flag': 'AE', 'code': '+971'},
    {'name': 'Saudi Arabia', 'flag': 'SA', 'code': '+966'},
    {'name': 'China', 'flag': 'CN', 'code': '+86'},
    {'name': 'Bangladesh', 'flag': 'BD', 'code': '+880'},
    {'name': 'Sri Lanka', 'flag': 'LK', 'code': '+94'},
    {'name': 'Nepal', 'flag': 'NP', 'code': '+977'},
    {'name': 'Turkey', 'flag': 'TR', 'code': '+90'},
    {'name': 'Germany', 'flag': 'DE', 'code': '+49'},
    {'name': 'France', 'flag': 'FR', 'code': '+33'},
    {'name': 'Australia', 'flag': 'AU', 'code': '+61'},
    {'name': 'Canada', 'flag': 'CA', 'code': '+1'},
    {'name': 'South Africa', 'flag': 'ZA', 'code': '+27'},
    {'name': 'Malaysia', 'flag': 'MY', 'code': '+60'},
    {'name': 'Singapore', 'flag': 'SG', 'code': '+65'},
    {'name': 'Indonesia', 'flag': 'ID', 'code': '+62'},
    {'name': 'Philippines', 'flag': 'PH', 'code': '+63'},
    {'name': 'Japan', 'flag': 'JP', 'code': '+81'},
    {'name': 'South Korea', 'flag': 'KR', 'code': '+82'},
    {'name': 'Russia', 'flag': 'RU', 'code': '+7'},
    {'name': 'Italy', 'flag': 'IT', 'code': '+39'},
    {'name': 'Spain', 'flag': 'ES', 'code': '+34'},
    {'name': 'Brazil', 'flag': 'BR', 'code': '+55'},
    {'name': 'Mexico', 'flag': 'MX', 'code': '+52'},
    {'name': 'Egypt', 'flag': 'EG', 'code': '+20'},
    {'name': 'Nigeria', 'flag': 'NG', 'code': '+234'},
    {'name': 'Kenya', 'flag': 'KE', 'code': '+254'},
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_clearError);
  }

  void _clearError() {
    if (_phoneError != null) {
      setState(() => _phoneError = null);
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_clearError);
    _phoneController.dispose();
    super.dispose();
  }

  // ─── MAIN FIX: Real Firebase OTP ─────────────────────────────────────────
  Future<void> _handleContinue() async {
    final phone = _phoneController.text.trim();

    setState(() => _phoneError = null);

    if (phone.isEmpty) {
      setState(() => _phoneError = 'Please enter your phone number first');
      return;
    }

    final int expectedLength = _getExpectedLength(_selectedCountryCode);
    final String digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < expectedLength) {
      setState(() =>
      _phoneError = 'Phone number is too short. Enter $expectedLength digits');
      return;
    }

    if (digitsOnly.length > expectedLength) {
      setState(() =>
      _phoneError = 'Phone number is too long. Enter only $expectedLength digits');
      return;
    }

    // Full phone number with country code
    final String fullPhone = '$_selectedCountryCode$digitsOnly';

    setState(() => _isLoading = true);
    _showLoadingDialog();

    // ✅ Real Firebase verifyPhoneNumber call
    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhone,
      timeout: const Duration(seconds: 60),

      // Android pe auto verify ho jaye tou
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (!mounted) return;
        Navigator.pop(context); // loading dialog band karo
        setState(() => _isLoading = false);
        // Auto verified — seedha OTP screen pe jao with credential
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: fullPhone,
              verificationId: '',
              userInfo: {},
              autoCredential: credential,
            ),
          ),
        );
      },

      // OTP bhejne mein error
      verificationFailed: (FirebaseAuthException e) {
        if (!mounted) return;
        Navigator.pop(context); // loading dialog band karo
        setState(() => _isLoading = false);

        String msg;
        switch (e.code) {
          case 'invalid-phone-number':
            msg = 'Invalid phone number format.';
            break;
          case 'too-many-requests':
            msg = 'Too many requests. Try again later.';
            break;
          case 'quota-exceeded':
            msg = 'SMS quota exceeded. Try again tomorrow.';
            break;
          default:
            msg = 'OTP failed: ${e.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      },

      // OTP successfully bhej diya
      codeSent: (String verificationId, int? resendToken) {
        if (!mounted) return;
        Navigator.pop(context); // loading dialog band karo
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to $fullPhone'),
            backgroundColor: Colors.green,
          ),
        );

        // OTP screen pe jao verificationId pass karke
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: fullPhone,
              verificationId: verificationId,
              userInfo: {},
            ),
          ),
        );
      },

      codeAutoRetrievalTimeout: (String verificationId) {
        // Timeout ho gaya — verificationId save karo
      },
    );
  }

  void _showLoadingDialog() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sending OTP...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getExpectedLength(String countryCode) {
    final expectedLengths = {
      '+91': 10,
      '+92': 10,
      '+1': 10,
      '+44': 10,
      '+971': 9,
      '+966': 9,
      '+86': 11,
      '+880': 10,
      '+94': 9,
      '+977': 10,
      '+90': 10,
      '+49': 11,
      '+33': 9,
      '+61': 9,
      '+27': 9,
      '+60': 9,
      '+65': 8,
      '+62': 11,
      '+63': 10,
      '+81': 10,
      '+82': 10,
      '+7': 10,
      '+39': 10,
      '+34': 9,
      '+55': 11,
      '+52': 10,
      '+20': 10,
      '+234': 10,
      '+254': 9,
    };
    return expectedLengths[countryCode] ?? 10;
  }

  void _showCountryPickerDialog() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: isDark ? Colors.white12 : Colors.grey.shade300),
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  final isSelected = country['code'] == _selectedCountryCode;
                  return ListTile(
                    leading: Text(
                      country['flag']!,
                      style: const TextStyle(fontSize: 22),
                    ),
                    title: Text(
                      country['name']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? primaryBlue
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    trailing: Text(
                      country['code']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? primaryBlue
                            : (isDark ? Colors.white60 : Colors.grey[600]),
                      ),
                    ),
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedCountryCode = country['code']!;
                        _selectedCountryFlag = country['flag']!;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: textColor.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'ENTER YOUR\nNUMBER.',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: primaryBlue,
                  height: 1.15,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 48),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _showCountryPickerDialog,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: textColor.withValues(alpha: 0.8),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_selectedCountryFlag  $_selectedCountryCode',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: textColor.withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          style: TextStyle(fontSize: 16, color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white38
                                  : Colors.grey.shade400,
                              fontSize: 16,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: _phoneError != null
                                    ? Colors.red
                                    : primaryBlue.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide:
                              BorderSide(color: primaryBlue, width: 2),
                            ),
                            contentPadding: const EdgeInsets.only(bottom: 8),
                            isDense: true,
                          ),
                        ),
                        if (_phoneError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              _phoneError!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12.5,
                    color: secondaryTextColor,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                      text:
                      'By clicking Continue, you agree with our Terms. Learn how we process your data in our Privacy Policy and Cookies Policy. ',
                    ),
                    TextSpan(
                      text: 'Privacy Policy and Cookies',
                      style: TextStyle(
                        color: textColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}