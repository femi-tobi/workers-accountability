import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? _currentWeekDisciplines;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    
    // Parallel fetching for performance
    final results = await Future.wait([
      _authService.getProfile(),
      _authService.getDashboardStats(),
      _authService.getCurrentWeekDisciplines(),
    ]);

    if (mounted) {
      setState(() {
        // Profile
        if (results[0]['success']) {
          _user = results[0]['data'];
        }
        
        // Dashboard Stats
        if (results[1]['success']) {
          _dashboardStats = results[1]['data'];
        }

        // Current Week Disciplines
        if (results[2]['success']) {
          _currentWeekDisciplines = results[2]['data'];
        }
        
        _isLoading = false;
      });
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
  Widget build(BuildContext context) {
    // Determine if we are on wide screen
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8), // background-light
      body: Row(
        children: [
          if (isDesktop) _Sidebar(user: _user, onLogout: _handleLogout, isLoading: _isLoading),
          Expanded(
            child: Column(
              children: [
                _Header(showMenu: !isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryCards(stats: _dashboardStats),
                        const SizedBox(height: 32),
                        _AccountabilityTable(
                          initialData: _currentWeekDisciplines,
                          authService: _authService,
                          onSaveSuccess: _loadAllData,
                        ),
                        const SizedBox(height: 32),
                        _BottomSection(initialData: _currentWeekDisciplines),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : Drawer(child: _Sidebar(user: _user, onLogout: _handleLogout, isLoading: _isLoading)),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final Map<String, dynamic>? user;
  final VoidCallback onLogout;
  final bool isLoading;

  const _Sidebar({this.user, required this.onLogout, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1152D4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/anchor.png',
                    width: 24,
                    height: 24,
                    color: Colors.white, // Keep it white if it's a solid shape, or remove if it's full color
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anchor Uni',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF111318),
                      ),
                    ),
                    Text(
                      'Worker Portal',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFF616F89),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', isActive: true),
          _NavItem(icon: Icons.auto_stories_outlined, label: 'Spiritual Goals'),
          _NavItem(icon: Icons.history_outlined, label: 'History'),
          _NavItem(icon: Icons.library_books_outlined, label: 'Resources'),
          _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
          const Spacer(),
          const Divider(color: Color(0xFFDBDFE6)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026024d'),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading ? 'Loading...' : (user?['fullName'] ?? 'User'),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF111318),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isLoading ? '...' : (user?['workforceDepartment']?.toString().toUpperCase() ?? 'WORKER'),
                        style: GoogleFonts.manrope(
                            fontSize: 12, color: const Color(0xFF616F89)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFF616F89), size: 20),
                  onPressed: onLogout,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({required this.icon, required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0F2F4) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? const Border(left: BorderSide(color: Color(0xFF1152D4), width: 4))
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF1152D4) : const Color(0xFF616F89),
        ),
        title: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? const Color(0xFF1152D4) : const Color(0xFF616F89),
          ),
        ),
        onTap: () {},
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}



class _Header extends StatelessWidget {
  final bool showMenu;
  const _Header({required this.showMenu});

  String _getWeekRange() {
    final now = DateTime.now();
    // Find the closest Monday (or today if it's Monday)
    // subtract (weekday - 1) days. weekday is 1 for Mon, 7 for Sun.
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final dateFormat = DateFormat('MMM d');
    return '${dateFormat.format(startOfWeek)} - ${dateFormat.format(endOfWeek)}, ${now.year}';
  }

  String _getWeekNumber() {
    final now = DateTime.now();
    // Calculate week number
    int dayOfYear = int.parse(DateFormat("D").format(now));
    int weekNum = ((dayOfYear - now.weekday + 10) / 7).floor();
    return 'Week $weekNum of ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFDBDFE6))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showMenu)
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              if (showMenu) const SizedBox(width: 8),
              Text(
                'Worker Accountability Dashboard',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111318),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'ACTIVE WEEK',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Color(0xFF616F89)),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Container(width: 1, height: 32, color: const Color(0xFFE5E7EB)),
              const SizedBox(width: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getWeekRange(),
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111318),
                    ),
                  ),
                  Text(
                    _getWeekNumber(),
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color(0xFF616F89),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final Map<String, dynamic>? stats;
  const _SummaryCards({this.stats});

  @override
  Widget build(BuildContext context) {
    // defaults
    final completed = stats?['tasksCompleted'] ?? 0;
    final total = stats?['totalTasks'] ?? 28;
    final streak = stats?['currentStreak'] ?? 0;
    final rate = stats?['completionRate'] ?? 0;
    
    // Responsive grid
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1100 ? 3 : (width > 700 ? 2 : 1);

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 2.0,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _CardItem(
          icon: Icons.task_alt,
          iconColor: const Color(0xFF1152D4),
          iconBg: const Color(0xFF1152D4).withOpacity(0.1),
          title: 'Tasks Completed',
          value: '$completed / $total',
          content: Container(
            height: 6,
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(100),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: total > 0 ? (completed / total).clamp(0.0, 1.0) : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1152D4),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
        _CardItem(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          iconBg: const Color(0xFFFFEDD5),
          title: 'Current Streak',
          value: '$streak Days',
          subContent: const Text(
            'Keep it up!',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        _CardItem(
          icon: Icons.query_stats,
          iconColor: Colors.green,
          iconBg: const Color(0xFFDCFCE7),
          title: 'Completion Rate',
          value: '$rate%',
          subContent: const Text(
            'Goal: 85%+',
            style: TextStyle(fontSize: 12, color: Color(0xFF616F89)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}

class _CardItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final Widget? content;
  final Widget? subContent;

  const _CardItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    this.content,
    this.subContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: const Color(0xFF616F89),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF111318),
                  ),
                ),
                if (content != null) content!,
                if (subContent != null) ...[const SizedBox(height: 4), subContent!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountabilityTable extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final AuthService authService;
  final VoidCallback? onSaveSuccess;

  const _AccountabilityTable({
    this.initialData, 
    required this.authService,
    this.onSaveSuccess,
  });

  @override
  State<_AccountabilityTable> createState() => _AccountabilityTableState();
}

class _AccountabilityTableState extends State<_AccountabilityTable> {
  final List<String> _rowTitles = ['Prayer', 'Bible Study', 'Fasting', 'Evangelism'];
  final List<String> _rowSubtitles = ['1 hour minimum', 'Personal deep study', 'Weekly requirement', 'Soul winning'];
  final List<String> _apiKeys = ['prayer', 'bible_study', 'fasting', 'evangelism'];
  // Sunday is index 6 in UI (Mon=0), but standard DateTime.weekday is Mon=1..Sun=7. 
  // API likely uses boolean keys: monday, tuesday...
  final List<String> _dayKeys = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

  // N/A Logic: Fasting & Evangelism only need 1 day. 
  // We won't enforce N/A visually to keep it flexible as per previous request to remove constraints,
  // but we will interpret unchecked as false for API.

  late List<List<bool>> _statusData;
  late List<List<bool>> _lockedData;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(covariant _AccountabilityTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      _initializeData();
    }
  }

  void _initializeData() {
    // Default to all false
    _statusData = List.generate(4, (_) => List.filled(7, false));
    _lockedData = List.generate(4, (_) => List.filled(7, false));

    if (widget.initialData != null && widget.initialData!['disciplines'] != null) {
      final disciplines = widget.initialData!['disciplines'] as List;
      for (var d in disciplines) {
        // Find row index by discipline name (key)
        // API returns "discipline": "prayer"
        final key = d['discipline'];
        final rowIndex = _apiKeys.indexOf(key);
        
        if (rowIndex != -1) {
          // Map days
          for (int i = 0; i < 7; i++) {
            final dayKey = _dayKeys[i];
            // API returns boolean or null. Treat null as false.
            if (d[dayKey] == true) {
              _statusData[rowIndex][i] = true;
              _lockedData[rowIndex][i] = true;
            }
          }
        }
      }
    }
  }

  Future<void> _saveProgress() async {
    setState(() => _isSaving = true);
    
    // Construct payload
    List<Map<String, dynamic>> disciplinesPayload = [];
    for (int i = 0; i < 4; i++) {
      Map<String, dynamic> row = {
        'discipline': _apiKeys[i],
      };
      for (int j = 0; j < 7; j++) {
        row[_dayKeys[j]] = _statusData[i][j];
      }
      disciplinesPayload.add(row);
    }
    
    final result = await widget.authService.saveDisciplineProgress(disciplinesPayload);
    
    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Progress saved')),
      );

      if (result['success'] == true) {
        widget.onSaveSuccess?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBDFE6)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Discipline Tracker',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111318),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                         // TODO: Implement Previous Weeks Modal
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Previous Weeks feature coming soon')),
                         );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF1152D4).withOpacity(0.1),
                        foregroundColor: const Color(0xFF1152D4),
                      ),
                      child: const Text('View Previous Weeks'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveProgress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1152D4),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSaving 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Progress'),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFDBDFE6)),
          LayoutBuilder(
            builder: (context, constraints) {
              // Calculate column spacing to fit width if on desktop
              double spacing = 24.0; 
              if (constraints.maxWidth > 900) {
                 spacing = (constraints.maxWidth - 300) / 8; 
                 if (spacing < 24.0) spacing = 24.0;
              }

              // Calculate today (0=Mon, 6=Sun)
              final todayIndex = DateTime.now().weekday - 1;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                   constraints: BoxConstraints(minWidth: constraints.maxWidth),
                   child: DataTable(
                    columnSpacing: spacing,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                    columns: [
                      const DataColumn(label: Text('SPIRITUAL DISCIPLINE')),
                      DataColumn(label: Text(todayIndex == 0 ? 'MON (Today)' : 'MON')),
                      DataColumn(label: Text(todayIndex == 1 ? 'TUE (Today)' : 'TUE')),
                      DataColumn(label: Text(todayIndex == 2 ? 'WED (Today)' : 'WED')),
                      DataColumn(label: Text(todayIndex == 3 ? 'THU (Today)' : 'THU')),
                      DataColumn(label: Text(todayIndex == 4 ? 'FRI (Today)' : 'FRI')),
                      DataColumn(label: Text(todayIndex == 5 ? 'SAT (Today)' : 'SAT')),
                      DataColumn(label: Text(todayIndex == 6 ? 'SUN (Today)' : 'SUN')),
                    ],
                    rows: List.generate(4, (index) {
                      return _buildRow(
                        index,
                        _rowTitles[index], 
                        _rowSubtitles[index], 
                        _statusData[index], 
                        todayIndex,
                      );
                    }),
                  ),
                ),
              );
            }
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  DataRow _buildRow(int rowIndex, String title, String subtitle, List<bool> status, int todayIndex) {
    List<DataCell> cells = [
      DataCell(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
            Text(subtitle, style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF616F89))),
          ],
        ),
      ),
    ];

    for (int i = 0; i < 7; i++) {
        Widget cellContent;
        bool isLocked = _lockedData[rowIndex][i];
        bool isToday = i == todayIndex;
        
        // Interactive Checkbox for all cells
        // Disabled if locked OR if it's not today
        bool isDisabled = isLocked || !isToday;

        cellContent = Checkbox(
          value: status[i],
          onChanged: isDisabled ? null : (val) {
            setState(() {
              _statusData[rowIndex][i] = val ?? false;
            });
          },
          activeColor: const Color(0xFF1152D4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        );
        
      cells.add(DataCell(Center(child: cellContent)));
    }

    return DataRow(cells: cells);
  }
}


class _BottomSection extends StatelessWidget {
  final Map<String, dynamic>? initialData;
  const _BottomSection({this.initialData});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 800;
        return Flex(
              direction: isWide ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWide) ...[
                  Expanded(flex: 2, child: _Reflections(initialData: initialData)),
                  const SizedBox(width: 32),
                  const Expanded(flex: 1, child: _AcademicTasks()),
                ] else ...[
                  _Reflections(initialData: initialData),
                  const SizedBox(height: 32),
                  const _AcademicTasks(),
                ]
              ],
            );
      }
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

class _Reflections extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const _Reflections({this.initialData});

  @override
  State<_Reflections> createState() => _ReflectionsState();
}

class _ReflectionsState extends State<_Reflections> {
  final _controller = TextEditingController();
  final _authService = AuthService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _setInitialData();
  }

  @override
  void didUpdateWidget(covariant _Reflections oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialData != oldWidget.initialData) {
      _setInitialData();
    }
  }

  void _setInitialData() {
    if (widget.initialData != null && widget.initialData!['reflection'] != null) {
      _controller.text = widget.initialData!['reflection'];
    }
  }

  Future<void> _submitReflection() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reflection')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final result = await _authService.saveReflection(_controller.text.trim());
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Reflection & Remarks',
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDBDFE6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Reflections / Prayer Requests',
                style: GoogleFonts.manrope(
                  fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF616F89)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'How has your spiritual journey been this week? Share any challenges or victories...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFDBDFE6)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitReflection,
                  icon: _isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, size: 16),
                  label: Text(_isSaving ? 'Saving...' : 'Submit Reflection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1152D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AcademicTasks extends StatefulWidget {
  const _AcademicTasks();

  @override
  State<_AcademicTasks> createState() => _AcademicTasksState();
}

class _AcademicTasksState extends State<_AcademicTasks> {
  // Initial Mock Data
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Finalize Lecture Notes',
      'subtitle': 'CSC 401: Distributed Systems',
      'completed': false,
    },
    {
      'title': 'Grade Mid-term Scripts',
      'subtitle': 'Completed',
      'completed': true,
    },
    {
      'title': 'Departmental Meeting',
      'subtitle': '2:00 PM - Faculty Board Room',
      'completed': false,
    },
  ];

  void _addNewTask(String title, String subtitle) {
    setState(() {
      _tasks.add({
        'title': title,
        'subtitle': subtitle,
        'completed': false,
      });
    });
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Task', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'e.g. Grade Scripts',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subtitleController,
              decoration: InputDecoration(
                labelText: 'Subtitle / Context',
                hintText: 'e.g. CSC 201',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addNewTask(titleController.text, subtitleController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1152D4),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Academic Tasks",
          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDBDFE6)),
          ),
          child: Column(
            children: [
              ..._tasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _TaskItem(
                  title: task['title'],
                  subtitle: task['subtitle'],
                  completed: task['completed'],
                  onChanged: (val) {
                    setState(() {
                      task['completed'] = val;
                    });
                  },
                ),
              )).toList(),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _showAddTaskDialog,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add New Task'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF616F89),
                  side: const BorderSide(color: Color(0xFFDBDFE6), style: BorderStyle.solid),
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool completed;
  final Function(bool?)? onChanged;

  const _TaskItem({
    required this.title, 
    required this.subtitle, 
    required this.completed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
            Checkbox(
              value: completed, 
              onChanged: onChanged,
              activeColor: const Color(0xFF1152D4),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: completed ? TextDecoration.lineThrough : null,
                      color: completed ? const Color(0xFF616F89) : const Color(0xFF111318),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: completed ? Colors.green : const Color(0xFF616F89),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}
