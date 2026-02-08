import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Selections
  String? _selectedExco;
  String? _selectedGender;
  String? _selectedHostel;

  // Data
  final List<String> _excos = [
    'President',
    'Vice President',
    'General Secretary',
    'Financial Secretary',
    'Social Director',
    'PRO',
    'Welfare Director',
    'Academic Director',
  ];

  final List<String> _genders = ['Male', 'Female'];

  List<String> get _availableHostels {
    if (_selectedGender == 'Male') {
      return ['Peace Hostel', 'Progress Hostel'];
    } else if (_selectedGender == 'Female') {
      return ['Purity Hostel', 'Patience Hostel', 'Peculiar Hostel', 'Guest House'];
    }
    return [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A237E)),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Account',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A237E),
              ),
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
            const SizedBox(height: 10),
            Text(
              'Sign up to get started',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 30),

            _buildTextField(controller: _nameController, label: 'Full Name', icon: Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, inputType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(controller: _phoneController, label: 'Phone Number', icon: Icons.phone_outlined, inputType: TextInputType.phone),
            const SizedBox(height: 16),
            
            // Gender Dropdown
            _buildDropdown(
              value: _selectedGender,
              hint: 'Select Gender',
              icon: Icons.people_outline,
              items: _genders,
              onChanged: (val) {
                setState(() {
                  _selectedGender = val;
                  _selectedHostel = null; // Reset hostel when gender changes
                });
              },
            ),
            const SizedBox(height: 16),

            // Hostel Dropdown (Dependent on Gender)
            _buildDropdown(
              value: _selectedHostel,
              hint: 'Select Hostel',
              icon: Icons.home_work_outlined,
              items: _availableHostels,
              onChanged: (val) {
                setState(() {
                  _selectedHostel = val;
                });
              },
              enabled: _selectedGender != null,
            ),
            const SizedBox(height: 16),

            _buildTextField(controller: _departmentController, label: 'Workforce Department', icon: Icons.work_outline),
            const SizedBox(height: 16),

            // Exco Dropdown
            _buildDropdown(
              value: _selectedExco,
              hint: 'Select Assigned Exco',
              icon: Icons.assignment_ind_outlined,
              items: _excos,
              onChanged: (val) {
                setState(() {
                  _selectedExco = val;
                });
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 16),
            _buildTextField(controller: _confirmPasswordController, label: 'Confirm Password', icon: Icons.lock_outline, isPassword: true),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement Registration Logic
                  if (_passwordController.text != _confirmPasswordController.text) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Passwords do not match')),
                    );
                    return;
                  }
                  
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'REGISTER',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label, 
    required IconData icon, 
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A237E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: enabled ? Colors.grey[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, color: enabled ? const Color(0xFF1A237E) : Colors.grey),
              const SizedBox(width: 12),
              Text(hint, style: GoogleFonts.poppins(color: enabled ? Colors.black87 : Colors.grey)),
            ],
          ),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: enabled ? const Color(0xFF1A237E) : Colors.grey),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
