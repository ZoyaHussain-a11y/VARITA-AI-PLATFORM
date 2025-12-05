import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String userType;
  final String expectedCode;
  final VoidCallback onVerificationSuccess;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.userType,
    required this.expectedCode,
    required this.onVerificationSuccess,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _codeCtr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with the expected code for demo purposes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _codeCtr.text = widget.expectedCode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = widget.userType == 'Doctor'
        ? const Color(0xFFC2185B)
        : const Color(0xFF279FF4);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userType} Verification'),
        backgroundColor: activeColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Icon(
                widget.userType == 'Doctor'
                    ? Icons.medical_services
                    : Icons.person_outline,
                size: 64,
                color: activeColor,
              ),
              const SizedBox(height: 16),

              Text(
                '${widget.userType} Secure Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'We sent a 6-digit verification code to your ${widget.userType.toLowerCase()} account:',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),

              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: activeColor.withOpacity(0.3)),
                ),
                child: Text(
                  'Account Type: ${widget.userType}',
                  style: TextStyle(
                    fontSize: 14,
                    color: activeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Verification Code Input
              TextFormField(
                controller: _codeCtr,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter 6-digit code',
                  prefixIcon: Icon(Icons.lock_outline, color: activeColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: activeColor, width: 2),
                  ),
                  hintText: 'Demo code: ${widget.expectedCode}',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the verification code';
                  }
                  if (value.length != 6) {
                    return 'Code must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Demo Code Hint
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo: Use code ${widget.expectedCode} for ${widget.userType} verification',
                        style: TextStyle(color: Colors.blue[800], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Verify & Continue as ${widget.userType}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Back to Login
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Back to Login',
                    style: TextStyle(color: activeColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isVerifying = false;
    });

    if (_codeCtr.text == widget.expectedCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ ${widget.userType} verification successful!"),
          backgroundColor: Colors.green,
        ),
      );

      widget.onVerificationSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Invalid verification code"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
