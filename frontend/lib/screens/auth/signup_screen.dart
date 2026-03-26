import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../providers/auth_provider.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _mentorCodeController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String _admissionType = 'Regular';
  int _selectedSemester = 1;
  DateTime? _dateOfBirth;
  DateTime? _dateOfJoining;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _mentorCodeController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate
          ? (DateTime.now().subtract(const Duration(days: 365 * 18)))
          : DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.blue.shade900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _dateOfBirth = picked;
        } else {
          _dateOfJoining = picked;
        }
      });
    }
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        Map<String, dynamic> additionalData = {
          'full_name': _fullNameController.text.trim(),
          'department': _departmentController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
        };

        additionalData.addAll({
          'studentId': _studentIdController.text.trim(),
          'admissionType': _admissionType,
          'currentSemester': _selectedSemester,
          'dateOfBirth':
              (_dateOfBirth ?? DateTime.now()).toIso8601String().split('T')[0],
          'dateOfJoining': (_dateOfJoining ?? DateTime.now())
              .toIso8601String()
              .split('T')[0],
          'mentorCode': _mentorCodeController.text.trim(),
        });

        final success = await authProvider.sendRegistrationOTP(_emailController.text.trim());

        if (success && mounted) {
          setState(() => _isLoading = false);
          _showOTPDialog(context, authProvider, additionalData);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to request OTP: ${e.toString()}')),
          );
        }
        setState(() => _isLoading = false);
      }
    }
  }

  void _showOTPDialog(BuildContext context, AuthProvider authProvider, Map<String, dynamic> additionalData) {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Verify Email', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter the 6-digit code sent to your email.', textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                          if (otpController.text.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
                            );
                            return;
                          }

                          setDialogState(() => isVerifying = true);

                          try {
                            final success = await authProvider.signUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              otp: otpController.text.trim(),
                              additionalData: additionalData,
                            );

                            if (success && mounted) {
                              Navigator.pop(context); // Close dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Account created successfully! Please login.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context); // Go back to Login screen
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Registration failed: ${e.toString()}')),
                              );
                            }
                            setDialogState(() => isVerifying = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isVerifying
                      ? const SizedBox(
                          height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Verify & Register'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Positioned(
                top: -50,
                left: -50,
                child: _buildCircle(200, Colors.black.withOpacity(0.02))),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Account\nRegistration',
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.0,
                          letterSpacing: -1.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'ESTABLISH YOUR PROFESSIONAL IDENTITY',
                      style: TextStyle(
                          color: Colors.black38,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 40),

                    // Registration Form Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            _buildSectionTitle('PERSONAL INFO'),
                            _buildTextField(
                              controller: _phoneNumberController,
                              label: 'PHONE NUMBER',
                              hint: '+91 98765 43210',
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                                controller: _fullNameController,
                                label: 'FULL NAME',
                                hint: 'Alex Johnson',
                                icon: Icons.person_outline_rounded),
                            const SizedBox(height: 20),
                            _buildTextField(
                                controller: _emailController,
                                label: 'COLLEGE EMAIL',
                                hint: 'alex@pvppcoe.ac.in',
                                icon: Icons.alternate_email_rounded,
                                validator: (v) {
                                  if (v == null || v.isEmpty)
                                    return 'Email required';
                                  if (!v
                                      .toLowerCase()
                                      .endsWith('@pvppcoe.ac.in'))
                                    return 'Use college email';
                                  return null;
                                }),
                            const SizedBox(height: 20),
                            _buildSectionTitle('LINK MENTOR'),
                            _buildTextField(
                                controller: _mentorCodeController,
                                label: 'MENTOR CODE',
                                hint: 'MTR-CSE-101',
                                icon: Icons.qr_code_rounded),
                            const SizedBox(height: 20),
                            _buildSectionTitle('ACADEMIC INFO'),
                            _buildTextField(
                                controller: _studentIdController,
                                label: 'STUDENT ID',
                                hint: 'STU-2024-001',
                                icon: Icons.badge_outlined),
                            const SizedBox(height: 20),
                            _buildSectionTitle('ADMISSION'),
                            _buildAdmissionToggle(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('SEMESTER'),
                            _buildSemesterDropdown(),
                            const SizedBox(height: 24),
                            _buildDatePickerRow('DATE OF BIRTH', _dateOfBirth,
                                () => _selectDate(context, true)),
                            const SizedBox(height: 20),
                            _buildDatePickerRow(
                                'DATE OF JOINING',
                                _dateOfJoining,
                                () => _selectDate(context, false)),
                            const SizedBox(height: 20),
                            _buildSectionTitle('DEPARTMENT'),
                            _buildTextField(
                                controller: _departmentController,
                                label: 'DEPARTMENT',
                                hint: 'Computer Science',
                                icon: Icons.domain_rounded),
                            const SizedBox(height: 32),
                            _buildSectionTitle('CREDENTIALS'),
                            _buildTextField(
                                controller: _passwordController,
                                label: 'PASSWORD',
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                isPassword: true),
                            const SizedBox(height: 20),
                            _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'CONFIRM',
                                hint: '••••••••',
                                icon: Icons.lock_reset_rounded,
                                isPassword: true),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 5,
                                  shadowColor: Colors.black26,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('CREATE ACCOUNT',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                            letterSpacing: 1.5)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.black38,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: keyboardType,
      style: const TextStyle(
          color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon, color: Colors.black, size: 18),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.1)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.black54,
                    size: 18),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      validator: validator ??
          (v) => (v == null || v.isEmpty) ? '$label required' : null,
    );
  }

  Widget _buildAdmissionToggle() {
    return Row(
      children: ['Regular', 'DSE'].map((type) {
        bool isSelected = _admissionType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _admissionType = type;
              if (type == 'DSE' && _selectedSemester < 3) {
                _selectedSemester = 3;
              } else if (type == 'Regular' && _selectedSemester > 8) {
                _selectedSemester = 1;
              }
            }),
            child: Container(
              margin: EdgeInsets.only(
                  right: type == 'Regular' ? 8 : 0,
                  left: type == 'DSE' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSemesterDropdown() {
    int startSem = _admissionType == 'DSE' ? 3 : 1;
    List<int> semesterOptions =
        List.generate(8 - startSem + 1, (i) => startSem + i);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedSemester < startSem ? startSem : _selectedSemester,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.black),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w700, fontSize: 15),
          items: semesterOptions.map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('Semester $value'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() => _selectedSemester = newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDatePickerRow(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  date != null
                      ? DateFormat('MMMM dd, yyyy').format(date)
                      : 'Select Date',
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const Icon(Icons.calendar_today_rounded,
                color: Colors.black87, size: 18),
          ],
        ),
      ),
    );
  }
}
