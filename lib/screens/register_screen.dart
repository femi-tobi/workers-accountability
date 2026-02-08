import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

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
  String? _selectedGender;
  String? _selectedHostel;
  String? _selectedExco;
  String? _selectedDepartment;

  final _authService = AuthService();
  bool _isLoading = false;

  // Data
  List<Map<String, String>> _excos = []; // Dynamic list of {label, value}
  bool _isLoadingExcos = false;

  final List<String> _genders = ['Male', 'Female'];

  final List<String> _workforceDepartments = [
    'Choir',
    'Ushering',
    'Technical',
    'Media',
    'Prayer',
    'Evangelism',
    'Welfare',
    'Sanctuary',
    'Protocol',
    'Children',
    'Drama',
    'Instrumentals',
  ];

  final Map<String, String> _hostelBackendMap = {
    'Peace Hostel': 'PEACE_hostel',
    'Progress Hostel': 'PROGRESS_hostel',
    'Purity Hostel': 'purity_hostel',
    'Patience Hostel': 'patience_hostel',
    'Peculiar Hostel': 'peculiar_hostel',
    'Guest House': 'guest_house',
  };

  @override
  void initState() {
    super.initState();
    _fetchExecutives();
  }

  Future<void> _fetchExecutives() async {
    setState(() => _isLoadingExcos = true);
    // Assuming _authService.getExecutives() now returns List<Map<String, String>>
    final excos = await _authService.getExecutives();
    if (mounted) {
      setState(() {
        _excos = excos;
        _isLoadingExcos = false;
      });
    }
  }

  List<String> get _availableHostels {
    if (_selectedGender == 'Male') {
      return ['Peace Hostel', 'Progress Hostel'];
    } else if (_selectedGender == 'Female') {
      return ['Purity Hostel', 'Patience Hostel', 'Peculiar Hostel', 'Guest House'];
    }
    return [];
  }

  void _register() async {
    setState(() => _isLoading = true);

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in named, email and phone fields')),
      );
      setState(() => _isLoading = false);
      return;
    }

    // Construct user data map matching API expectations
    final userData = {
      'fullName': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'gender': _selectedGender?.toLowerCase(), // 'male', 'female'
      'hostel': _hostelBackendMap[_selectedHostel], // Use backend value from map
      'workforceDepartment': _selectedDepartment?.toLowerCase(),
      'assignedExecutive': _selectedExco, // This is now the ID
      'password': _passwordController.text,
      'confirmPassword': _passwordController.text,
    };

    final result = await _authService.register(userData);

    setState(() => _isLoading = false);

    if (result['success']) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please login.')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
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
             Center( // added center logo
              child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/anchor.png',
                    width: 40,
                    height: 40,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            ),
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

            // Workforce Department Dropdown
            _buildDropdown(
              value: _selectedDepartment,
              hint: 'Select Workforce Department',
              icon: Icons.work_outline,
              items: _workforceDepartments,
              onChanged: (val) {
                setState(() {
                  _selectedDepartment = val;
                });
              },
            ),
            const SizedBox(height: 16),

            // Exco Dropdown (Custom implementation for Map items)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _isLoadingExcos ? Colors.grey[200] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedExco,
                  hint: Row(
                    children: [
                      Icon(Icons.assignment_ind_outlined, color: !_isLoadingExcos ? const Color(0xFF1A237E) : Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _isLoadingExcos ? 'Loading roles...' : 'Select Assigned Exco', 
                        style: GoogleFonts.poppins(color: !_isLoadingExcos ? Colors.black87 : Colors.grey)
                      ),
                    ],
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: !_isLoadingExcos ? const Color(0xFF1A237E) : Colors.grey),
                  items: _excos.map((Map<String, String> item) {
                    return DropdownMenuItem<String>(
                      value: item['value'], // Use ID as value
                      child: Text(
                        item['label']!, // Show Name (Position)
                        style: GoogleFonts.poppins(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: !_isLoadingExcos ? (val) {
                    setState(() {
                      _selectedExco = val;
                    });
                  } : null,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 16),

            _buildTextField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 8),
            Text(
              'Password must contain at least one lowercase letter, one uppercase letter, and one number',
              style: GoogleFonts.manrope(fontSize: 12, color: Colors.red[700]),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 16),
            _buildTextField(controller: _confirmPasswordController, label: 'Confirm Password', icon: Icons.lock_outline, isPassword: true),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1152D4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF1152D4).withOpacity(0.4),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                    'REGISTER',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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
