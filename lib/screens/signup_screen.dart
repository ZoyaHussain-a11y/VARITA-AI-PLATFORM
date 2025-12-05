import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtr = TextEditingController();
  final _passCtr = TextEditingController();
  final _confirmCtr = TextEditingController();
  final _codeCtr = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtr.dispose();
    _passCtr.dispose();
    _confirmCtr.dispose();
    _codeCtr.dispose();
    super.dispose();
  }

  void _trySignup() async {
    if (_passCtr.text != _confirmCtr.text) {
      setState(() {
        _error = 'Passwords do not match';
      });
      return;
    }

    if (_emailCtr.text.isEmpty || !_emailCtr.text.contains('@')) {
      setState(() {
        _error = 'Please enter a valid email';
      });
      return;
    }

    if (_passCtr.text.length < 6) {
      setState(() {
        _error = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Simulate signup delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _loading = false);

    // Navigate to HomeScreen (placeholder)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Home Screen')),
        ),
      ),
    );
  }

  void _sendCode() {
    if (_emailCtr.text.isEmpty || !_emailCtr.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email first')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification code sent to your email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VERITA AI'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/verita_logo.png.jpeg',
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.medical_services, size: 80, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'VERITA AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Only email registration is supported in your region. One VERITA AI account is all you need to access all VERITA AI services.',
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Email
              TextField(
                controller: _emailCtr,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passCtr,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextField(
                controller: _confirmCtr,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Verification code
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeCtr,
                      decoration: InputDecoration(
                        hintText: 'Verification Code',
                        prefixIcon: const Icon(Icons.tag),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: _sendCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Blue color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Send Code'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'By signing up, you consent to VERITA AI Terms of Use and Privacy Policy.',
                style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_error != null) const SizedBox(height: 16),

              // Create Account button (Blue)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _trySignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_loading ? 'Creating Account...' : 'Create Account'),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: _loading ? null : () => Navigator.of(context).pop(),
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
