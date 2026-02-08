import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

class WorkerDetailScreen extends StatefulWidget {
  final String workerId;
  final String workerName;

  const WorkerDetailScreen({
    super.key,
    required this.workerId,
    required this.workerName,
  });

  @override
  State<WorkerDetailScreen> createState() => _WorkerDetailScreenState();
}

class _WorkerDetailScreenState extends State<WorkerDetailScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  Map<String, dynamic> _details = {};
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    try {
      final details = await _authService.getWorkerDetails(widget.workerId);
      final history = await _authService.getWorkerHistory(widget.workerId);

      if (mounted) {
        setState(() {
          _details = details;
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        title: Text(
          widget.workerName,
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: const Color(0xFF111318)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF111318)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 32),
                  Text(
                    'Discipline History',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111318),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHistoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBDFE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF1152D4).withOpacity(0.1),
            child: Text(
              widget.workerName.substring(0, 1).toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1152D4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _details['department'] ?? 'Department',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111318),
                  ),
                ),
                Text(
                  _details['hostel'] ?? 'Hostel',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: const Color(0xFF616F89),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatsGrid() {
    // Calculate stats from history if detailed stats aren't directly available
    int totalWeeks = _history.length;
    int perfectWeeks = _history.where((w) => w['score'] == 100).length; // Assuming score logic or similar
    // This is placeholder logic, adjust based on actual API response structure
    
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Weeks Tracked', value: '$totalWeeks')),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(label: 'Perfect Weeks', value: '$perfectWeeks', color: Colors.green)),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No history available',
            style: GoogleFonts.manrope(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final week = _history[index];
        final startDate = DateTime.parse(week['weekStartDate']);
        final endDate = DateTime.parse(week['weekEndDate']);
        final dateFormat = DateFormat('MMM d');
        final percent = (week['completionRate'] ?? 0.0) * 100;

        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFDBDFE6))),
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Week ${week['weekNumber']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: percent >= 80 ? const Color(0xFFDCFCE7) : (percent >= 50 ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2)),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${percent.toStringAsFixed(0)}%',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  color: percent >= 80 ? const Color(0xFF15803D) : (percent >= 50 ? const Color(0xFFB45309) : const Color(0xFFB91C1C)),
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _WeeklyTable(data: week),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, this.color = const Color(0xFF1152D4)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBDFE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: const Color(0xFF616F89),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const _WeeklyTable({required this.data});

  @override
  Widget build(BuildContext context) {
    final disciplines = data['disciplines'] as List? ?? [];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final rows = ['Prayer', 'Bible Study', 'Fasting', 'Evangelism'];
    final apiKeys = ['prayer', 'bible_study', 'fasting', 'evangelism'];
    final dayKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    return Column(
      children: [
        // Header
        Row(
          children: [
            const Expanded(flex: 3, child: SizedBox()),
            ...days.map((d) => Expanded(
              child: Center(
                child: Text(d, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            )),
          ],
        ),
        const SizedBox(height: 8),
        // Rows
        ...List.generate(rows.length, (rowIndex) {
          final label = rows[rowIndex];
          final apiKey = apiKeys[rowIndex];
          
          // Find discipline data
          final disciplineData = disciplines.firstWhere(
            (d) => d['discipline'] == apiKey,
            orElse: () => {},
          );

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    label,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                  ),
                ),
                ...List.generate(7, (dayIndex) {
                  final dayKey = dayKeys[dayIndex];
                  final isCompleted = disciplineData[dayKey] == true;

                  return Expanded(
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted ? const Color(0xFF1152D4) : Colors.transparent,
                          border: Border.all(
                            color: isCompleted ? const Color(0xFF1152D4) : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }
}
