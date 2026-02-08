import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'worker_detail_screen.dart';

class ExcoDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const ExcoDashboardScreen({super.key, required this.user});

  @override
  State<ExcoDashboardScreen> createState() => _ExcoDashboardScreenState();
}

class _ExcoDashboardScreenState extends State<ExcoDashboardScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  late TabController _tabController;
  
  // Data State
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _workers = [];
  List<dynamic> _reflections = [];
  List<dynamic> _filteredWorkers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchDashboardData();
    _searchController.addListener(_filterWorkers);
  }

  void _filterWorkers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredWorkers = _workers.where((w) {
        final workerData = w['worker'] ?? {};
        final name = (workerData['fullName'] ?? '').toString().toLowerCase();
        final dept = (workerData['workforceDepartment'] ?? '').toString().toLowerCase();
        return name.contains(query) || dept.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Diagnostic call
      final workersList = await _authService.getExecutiveWorkers(); 
      final stats = await _authService.getExecutiveDashboardStats();
      final workers = await _authService.getExecutiveWorkersProgress();
      final reflections = await _authService.getExecutiveReflections();

      // Check if data is valid, if not, use mock
      if (stats.isEmpty && workers.isEmpty && reflections.isEmpty) {
        throw Exception('API returned empty data');
      }

      if (mounted) {
        setState(() {
          _stats = stats;
          _workers = workers;
          _filteredWorkers = workers;
          
          // Aggregate reflections from workers list if they exist there
          final List<dynamic> workerReflections = [];
          for (var w in workers) {
            if (w['reflection'] != null && (w['reflection'] as String).isNotEmpty) {
               final workerProfile = w['worker'] ?? {};
               workerReflections.add({
                 'workerName': workerProfile['fullName'] ?? 'Unknown',
                 'date': w['reflectionSubmittedAt'] ?? DateTime.now().toIso8601String(),
                 'content': w['reflection'],
               });
            }
          }
          
          // Combine with direct reflections endpoint, avoiding duplicates if possible (simple concatenation for now)
          _reflections = [...reflections, ...workerReflections];
          
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Dashboard Load Error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error loading dashboard: $e'),
             duration: const Duration(seconds: 5),
             action: SnackBarAction(label: 'Retry', onPressed: _fetchDashboardData),
           ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
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
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Executive Portal',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: const Color(0xFF111318), fontSize: 18),
            ),
             Text(
              widget.user['fullName'] ?? 'Executive',
              style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF616F89)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111318)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1152D4),
          unselectedLabelColor: const Color(0xFF616F89),
          indicatorColor: const Color(0xFF1152D4),
          labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Workers'),
            Tab(text: 'Reflections'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildWorkersTab(),
                _buildReflectionsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 32),
          Text(
            'Recent Low Performers',
            style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
          ),
           const SizedBox(height: 16),
          _buildLowPerformersList(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    // Correctly parsing values from _stats, defaulting to 0 if null or not a number
    final totalWorkers = _stats['totalWorkers'] ?? 0;
    final avgCompletion = (_stats['averageCompletionRate'] ?? 0); 
    // Format avgCompletion to percentage string if it's a double (0.85 -> 85%) or int (64 -> 64%)
    String avgCompletionStr = (avgCompletion is double) 
        ? '${(avgCompletion * 100).toStringAsFixed(1)}%' 
        : '$avgCompletion%';
    
    final submittedReflections = _stats['workersWithReflection'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          label: 'Total Workers',
          value: totalWorkers.toString(),
          icon: Icons.people_outline,
          color: Colors.blue,
        ),
        _StatCard(
          label: 'Avg Completion',
          value: avgCompletionStr,
          icon: Icons.show_chart,
          color: Colors.green,
        ),
        _StatCard(
          label: 'Reflections',
          value: submittedReflections.toString(),
          icon: Icons.chat_bubble_outline,
          color: Colors.orange,
        ),
        _StatCard(
          label: 'Pending Review',
          value: '0', // Placeholder
          icon: Icons.pending_actions,
          color: Colors.red,
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildLowPerformersList() {
    // Filter logic: completion rate < 50%
    final lowPerformers = _workers.where((w) {
      final rate = (w['completionRate'] ?? 0).toDouble();
      return rate < 50; // Assuming 0-100 scale based on sample response
    }).toList();

    if (lowPerformers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text('All workers are performing well!', style: GoogleFonts.manrope(color: Colors.green))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lowPerformers.length,
      itemBuilder: (context, index) {
        final workerData = lowPerformers[index];
        final workerProfile = workerData['worker'] ?? {};
        final name = workerProfile['fullName'] ?? 'Unknown User';
        final rate = workerData['completionRate'] ?? 0;

        return Card(
           child: ListTile(
             leading: const Icon(Icons.warning, color: Colors.red),
             title: Text(name, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
             subtitle: Text('$rate% Completion'),
             trailing: const Icon(Icons.chevron_right),
             onTap: () => _navigateToWorkerDetail(workerData),
           ),
        );
      },
    );
  }

  Widget _buildWorkersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search workers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredWorkers.length,
            itemBuilder: (context, index) {
              final workerData = _filteredWorkers[index];
              final workerProfile = workerData['worker'] ?? {};
              
              final name = workerProfile['fullName'] ?? 'Unknown';
              final dept = workerProfile['workforceDepartment'] ?? 'No Dept';
              
              final rate = (workerData['completionRate'] ?? 0).toDouble();
              Color statusColor = rate >= 80 ? Colors.green : (rate >= 50 ? Colors.orange : Colors.red);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFDBDFE6)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1152D4).withOpacity(0.1),
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Color(0xFF1152D4), fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(name, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                  subtitle: Text(dept),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${rate.toStringAsFixed(0)}%',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: statusColor, fontSize: 16),
                      ),
                      Text('Completion', style: GoogleFonts.manrope(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  onTap: () => _navigateToWorkerDetail(workerData),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionsTab() {
    if (_reflections.isEmpty) {
      return Center(child: Text('No reflections submitted this week.', style: GoogleFonts.manrope(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reflections.length,
      itemBuilder: (context, index) {
        final reflection = _reflections[index];
        // Sample implies standard reflection object, but let's be safe
        // If reflection has nested worker object, handle it, otherwise defaults
        final workerName = reflection['workerName'] ?? (reflection['worker']?['fullName']) ?? 'Unknown';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 16, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      workerName,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d').format(DateTime.parse(reflection['date'] ?? DateTime.now().toIso8601String())),
                      style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reflection['content'] ?? '',
                  style: GoogleFonts.manrope(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _navigateToWorkerDetail(Map<String, dynamic> workerData) {
     final workerProfile = workerData['worker'] ?? {};
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => WorkerDetailScreen(
           workerId: workerProfile['_id'] ?? workerProfile['id'] ?? '', 
           workerName: workerProfile['fullName'] ?? 'Worker',
         ),
       ),
     );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBDFE6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111318)),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF616F89)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
