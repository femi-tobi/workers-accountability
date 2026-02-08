import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if we are on wide screen
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8), // background-light
      body: Row(
        children: [
          if (isDesktop) const _Sidebar(),
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
                        const _SummaryCards(),
                        const SizedBox(height: 32),
                        const _AccountabilityTable(),
                        const SizedBox(height: 32),
                        const _BottomSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : const Drawer(child: _Sidebar()),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

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
                  child: const Icon(Icons.anchor, color: Colors.white),
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
                        'John Doe',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF111318),
                        ),
                      ),
                      Text(
                        'Senior Lecturer',
                        style: GoogleFonts.manrope(
                            fontSize: 12, color: const Color(0xFF616F89)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.logout, color: Color(0xFF616F89), size: 20),
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
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    // Responsive grid
    double width = MediaQuery.of(context).size.width;
    int crossAxisCount = width > 1100 ? 3 : (width > 700 ? 2 : 1);

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 2.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _CardItem(
          icon: Icons.task_alt,
          iconColor: const Color(0xFF1152D4),
          iconBg: const Color(0xFF1152D4).withOpacity(0.1),
          title: 'Tasks Completed',
          value: '18 / 28',
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
              widthFactor: 0.64,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1152D4),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
        const _CardItem(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          iconBg: Color(0xFFFFEDD5),
          title: 'Current Streak',
          value: '5 Days',
          subContent: Text(
            '+2 days from last week',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
        const _CardItem(
          icon: Icons.query_stats,
          iconColor: Colors.green,
          iconBg: Color(0xFFDCFCE7),
          title: 'Completion Rate',
          value: '64%',
          subContent: Text(
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
      padding: const EdgeInsets.all(24),
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

class _AccountabilityTable extends StatelessWidget {
  const _AccountabilityTable();

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
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF1152D4).withOpacity(0.1),
                        foregroundColor: const Color(0xFF1152D4),
                      ),
                      child: const Text('View Previous Weeks'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1152D4),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Progress'),
                    ),
                  ],
                )
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFDBDFE6)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF9FAFB)),
              columns: const [
                DataColumn(label: Text('SPIRITUAL DISCIPLINE')),
                DataColumn(label: Text('MON')),
                DataColumn(label: Text('TUE')),
                DataColumn(label: Text('WED')),
                DataColumn(label: Text('THU')),
                DataColumn(label: Text('FRI (Today)')),
                DataColumn(label: Text('SAT')),
                DataColumn(label: Text('SUN')),
              ],
              rows: [
                _buildRow('Prayer', '1 hour minimum', [true, true, true, true, null, false, false]),
                _buildRow('Bible Study', 'Personal deep study', [true, false, true, true, null, false, false]),
                _buildRow('Fasting', 'Weekly requirement', [null, null, true, null, null, false, null], isNA: [0, 1, 3, 4, 6]),
                _buildRow('Evangelism', 'Soul winning', [false, true, false, true, null, false, false]),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  DataRow _buildRow(String title, String subtitle, List<bool?> status, {List<int> isNA = const []}) {
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
        if (isNA.contains(i)) {
             cellContent = Text('N/A', style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey));
        } else if (status[i] == true) {
            cellContent = const Icon(Icons.check_circle, color: Colors.green);
        } else if (status[i] == false) {
             cellContent = const Icon(Icons.cancel, color: Colors.redAccent);
        } else {
             // Null means today/input or future
             if (i == 4) { // Friday (Today) placeholder logic
                 cellContent = Checkbox(value: false, onChanged: (v) {}, activeColor: const Color(0xFF1152D4));
             } else {
                 cellContent = Container(
                     width: 24, height: 24,
                     decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(4),
                         border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none)// DASHED BORDER SIMPLIFIED
                     ),
                     child: const Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 20));
             }
        }
        
      cells.add(DataCell(Center(child: cellContent)));
    }

    return DataRow(cells: cells);
  }
}


class _BottomSection extends StatelessWidget {
  const _BottomSection();

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
                  const Expanded(flex: 2, child: _Reflections()),
                  const SizedBox(width: 32),
                  const Expanded(flex: 1, child: _AcademicTasks()),
                ] else ...[
                  const _Reflections(),
                  const SizedBox(height: 32),
                  const _AcademicTasks(),
                ]
              ],
            );
      }
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

class _Reflections extends StatelessWidget {
  const _Reflections();

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
                  onPressed: () {},
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Submit Reflection'),
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
