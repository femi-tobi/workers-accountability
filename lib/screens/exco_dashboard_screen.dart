import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ExcoDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const ExcoDashboardScreen({super.key, required this.user});

  @override
  State<ExcoDashboardScreen> createState() => _ExcoDashboardScreenState();
}

class _ExcoDashboardScreenState extends State<ExcoDashboardScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  // Mock Data for now
  final List<Map<String, dynamic>> _assignedWorkers = [
    {
      'name': 'John Doe',
      'department': 'Media',
      'hostel': 'Peace Hostel',
      'tasksCompleted': 20,
      'totalTasks': 28,
      'status': 'Good',
    },
    {
      'name': 'Jane Smith',
      'department': 'Choir',
      'hostel': 'Purity Hostel',
      'tasksCompleted': 12,
      'totalTasks': 28,
      'status': 'Needs Attention',
    },
    {
      'name': 'Michael Johnson',
      'department': 'Ushering',
      'hostel': 'Progress Hostel',
      'tasksCompleted': 25,
      'totalTasks': 28,
      'status': 'Excellent',
    },
  ];

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    await _authService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        title: Text(
          'Executive Dashboard',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: const Color(0xFF111318)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111318)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 32),
            Text(
              'Assigned Workers',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111318),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assignedWorkers.length,
              itemBuilder: (context, index) {
                final worker = _assignedWorkers[index];
                return _buildWorkerCard(worker, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1152D4),
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/anchor.png'),
          opacity: 0.1,
          fit: BoxFit.contain,
          alignment: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${widget.user['fullName']}',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Position: ${widget.user['excoPosition'] ?? 'Executive'}', // Assuming I filter and find position or pass it
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
           Text(
            'Manage and track your assigned workers here.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker, int index) {
    Color statusColor;
    switch (worker['status']) {
      case 'Excellent':
        statusColor = Colors.green;
        break;
      case 'Good':
        statusColor = Colors.blue;
        break;
      case 'Needs Attention':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1152D4).withOpacity(0.1),
          child: Text(
            worker['name'].substring(0, 1),
            style: const TextStyle(color: Color(0xFF1152D4), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          worker['name'],
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${worker['department']} • ${worker['hostel']}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    worker['status'],
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  '${worker['tasksCompleted']}/${worker['totalTasks']} Tasks',
                  style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // TODO: View Worker Details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing ${worker['name']}\'s details - Coming Soon')),
          );
        },
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2, end: 0);
  }
}
