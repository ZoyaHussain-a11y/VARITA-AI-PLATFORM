import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'signup_screen.dart';
import 'doctor_dashboard.dart';
import 'verification_screen.dart';
import 'forgot_password_screen.dart';
import 'patient_dashboard.dart';

const Color kPrimaryColor = Color(0xFFC2185B);
const Color kAccentColor = Color(0xFFE91E63);
const Color kPatientColor = Color(0xFF279FF4);
const Color kBackgroundColor = Color(0xFFF7F7F7);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailCtr = TextEditingController();
  final TextEditingController _passCtr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _userType = 'Doctor';

  // Define different credentials for Doctor and Patient
  final Map<String, Map<String, String>> _credentials = {
    'Doctor': {
      'email': 'dr.ali@verita.ai',
      'password': 'doctor123',
      'verificationCode': '123456',
    },
    'Patient': {
      'email': 'patient.john@verita.ai',
      'password': 'patient123',
      'verificationCode': '654321',
    },
  };

  @override
  void initState() {
    super.initState();
    // Pre-fill with doctor credentials by default using post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillCredentials();
    });
  }

  void _prefillCredentials() {
    final creds = _credentials[_userType];
    if (creds != null) {
      setState(() {
        _emailCtr.text = creds['email']!;
        _passCtr.text = creds['password']!;
      });
    }
  }

  void _updateUserType(String newUserType) {
    setState(() {
      _userType = newUserType;
    });
    _prefillCredentials();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = _userType == 'Doctor'
        ? kPrimaryColor
        : kPatientColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          /// LOGO
                          Center(
                            child: Image.asset(
                              'assets/images/verita_logo.png.jpeg',
                              height: 80,
                              width: 80,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.medical_services,
                                    size: 80,
                                    color: kPrimaryColor,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "VERITA AI",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "The modern AI healthcare platform",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          /// Doctor/Patient Slider Toggle
                          _buildUserTypeToggle(activeColor),
                          const SizedBox(height: 32),

                          /// EMAIL/PHONE FIELD
                          _buildTextField(
                            controller: _emailCtr,
                            hintText: "Phone number / email address",
                            icon: Icons.phone_iphone_outlined,
                            focusedColor: activeColor,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter phone or email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          /// PASSWORD FIELD
                          _buildPasswordField(activeColor),
                          const SizedBox(height: 16),

                          /// TERMS CHECKBOX
                          _buildTermsAndPolicyRow(activeColor),
                          const SizedBox(height: 24),

                          /// SIGN IN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activeColor,
                                elevation: 8,
                                shadowColor: activeColor.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      "Log in",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          /// Forgot + Signup Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Forgot password?",
                                  style: TextStyle(color: activeColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign up",
                                  style: TextStyle(
                                    color: activeColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          /// OR DIVIDER
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey[300]!),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Text(
                                  "OR",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey[300]!),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          /// CONTINUE WITH GOOGLE
                          _buildGoogleLoginButton(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserTypeToggle(Color activeColor) {
    return Container(
      width: 300,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _userType == 'Doctor'
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Container(
              width: 150,
              height: 55,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _updateUserType('Doctor'),
                  child: Container(
                    height: 55,
                    alignment: Alignment.center,
                    child: Text(
                      'Doctor',
                      style: TextStyle(
                        color: _userType == 'Doctor'
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _updateUserType('Patient'),
                  child: Container(
                    height: 55,
                    alignment: Alignment.center,
                    child: Text(
                      'Patient',
                      style: TextStyle(
                        color: _userType == 'Patient'
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color focusedColor,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusedColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField(Color activeColor) {
    return TextFormField(
      controller: _passCtr,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        hintText: "Password",
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600], size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: activeColor, width: 2),
        ),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter password";
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
    );
  }

  Widget _buildTermsAndPolicyRow(Color activeColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (v) {
              setState(() {
                _agreeToTerms = v ?? false;
              });
            },
            activeColor: activeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.5,
              ),
              children: [
                const TextSpan(
                  text:
                      "I confirm that I have read, consent and agree to VERITA AI ",
                ),
                TextSpan(
                  text: "Terms of Use",
                  style: TextStyle(
                    color: activeColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Add terms of use navigation
                    },
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy.",
                  style: TextStyle(
                    color: activeColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Add privacy policy navigation
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Google login clicked")));
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/google.png.png",
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              "Log in with Google",
              style: TextStyle(
                fontSize: 17,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please agree to Terms & Privacy Policy"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userCreds = _credentials[_userType];

    if (userCreds != null &&
        _emailCtr.text == userCreds['email'] &&
        _passCtr.text == userCreds['password']) {
      setState(() {
        _isLoading = true;
      });

      await _sendVerificationCode(userCreds['verificationCode']!);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerificationScreen(
            email: _emailCtr.text,
            userType: _userType,
            expectedCode: userCreds['verificationCode']!,
            onVerificationSuccess: _onVerificationSuccess,
          ),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _userType == 'Doctor'
                ? "Invalid Doctor credentials (Use: dr.ali@verita.ai / doctor123)"
                : "Invalid Patient credentials (Use: patient.john@verita.ai / patient123)",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendVerificationCode(String verificationCode) async {
    await Future.delayed(const Duration(seconds: 1));

    print(
      'Verification code $verificationCode sent to ${_emailCtr.text} for ${_userType}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_userType} verification code sent to ${_emailCtr.text}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onVerificationSuccess() {
    if (_userType == 'Doctor') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
      );
    } else if (_userType == 'Patient') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PatientDashboardScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailCtr.dispose();
    _passCtr.dispose();
    super.dispose();
  }
}
