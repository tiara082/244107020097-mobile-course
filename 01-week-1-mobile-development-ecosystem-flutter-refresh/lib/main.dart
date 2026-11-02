import 'package:flutter/material.dart';

void main() {
  runApp(const StudentProfileApp());
}

class StudentProfileApp extends StatefulWidget {
  const StudentProfileApp({super.key});

  @override
  State<StudentProfileApp> createState() => _StudentProfileAppState();
}

class _StudentProfileAppState extends State<StudentProfileApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Accent color for minimalist border lines & dividers
    const accentLineColor = Color(0xFF4F46E5); // Minimalist Indigo Line Accent

    return MaterialApp(
      title: 'Student Profile - Week 1',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      // Minimalist Clean White Theme with Colored Border Lines & Dividers
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentLineColor,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: accentLineColor, width: 1.2),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE0E7FF), // Soft Indigo Accent Line for dividers
          thickness: 1,
          space: 1,
        ),
        useMaterial3: true,
      ),
      // Minimalist Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF818CF8),
          brightness: Brightness.dark,
          surface: const Color(0xFF1E293B),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF6366F1), width: 1.2),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF334155),
          thickness: 1,
          space: 1,
        ),
        useMaterial3: true,
      ),
      home: ProfileHomeScreen(
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeToggle: _toggleTheme,
      ),
    );
  }
}

class ProfileHomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const ProfileHomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen> {
  String _name = "Tiara Febrianie";
  String _studentId = "244107020097";
  String _major = "Teknologi Informasi";
  String _class = "TI-3I";
  String _email = "tiarafebrianie308@gmail.com";
  String _hobby = "Mobile App Development";

  int _stateDemoCounter = 0;

  void _incrementDemoCounter() {
    setState(() {
      _stateDemoCounter++;
    });
  }

  void _showEditDialog() {
    final nameController = TextEditingController(text: _name);
    final idController = TextEditingController(text: _studentId);
    final majorController = TextEditingController(text: _major);
    final classController = TextEditingController(text: _class);
    final emailController = TextEditingController(text: _email);
    final hobbyController = TextEditingController(text: _hobby);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Student Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'NIM'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: majorController,
                  decoration: const InputDecoration(labelText: 'Major'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: classController,
                  decoration: const InputDecoration(labelText: 'Class'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: hobbyController,
                  decoration: const InputDecoration(labelText: 'Interest'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text;
                  _studentId = idController.text;
                  _major = majorController.text;
                  _class = classController.text;
                  _email = emailController.text;
                  _hobby = hobbyController.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    const accentLineColor = Color(0xFF4F46E5);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE0E7FF),
            height: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: widget.onThemeToggle,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card with Minimalist Border Outline
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: accentLineColor, width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        child: Text(
                          _name.isNotEmpty ? _name[0].toUpperCase() : 'T',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: accentLineColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NIM: $_studentId',
                            style: const TextStyle(
                              color: accentLineColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Class: $_class | $_major',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showEditDialog,
                      icon: const Icon(Icons.edit_outlined, color: accentLineColor),
                      tooltip: 'Edit Profile',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Profile Details Section
            Row(
              children: [
                Container(width: 4, height: 16, color: accentLineColor),
                const SizedBox(width: 8),
                const Text(
                  'Profile Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: accentLineColor),
                    title: const Text('NIM', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text(_studentId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(indent: 56),
                  ListTile(
                    leading: const Icon(Icons.group_outlined, color: accentLineColor),
                    title: const Text('Class', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text(_class, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(indent: 56),
                  ListTile(
                    leading: const Icon(Icons.school_outlined, color: accentLineColor),
                    title: const Text('Major', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text(_major, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(indent: 56),
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: accentLineColor),
                    title: const Text('Email', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text(_email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(indent: 56),
                  ListTile(
                    leading: const Icon(Icons.interests_outlined, color: accentLineColor),
                    title: const Text('Interest', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    subtitle: Text(_hobby, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hot Reload vs Hot Restart Visualizer Section
            Row(
              children: [
                Container(width: 4, height: 16, color: accentLineColor),
                const SizedBox(width: 8),
                const Text(
                  'Hot Reload vs Hot Restart Demo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'State Counter Visualizer',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hot Reload maintains state. Hot Restart resets state to 0.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Counter: $_stateDemoCounter',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: accentLineColor,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _incrementDemoCounter,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Increment'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: accentLineColor),
                            foregroundColor: accentLineColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Lab Reflections Section
            Row(
              children: [
                Container(width: 4, height: 16, color: accentLineColor),
                const SizedBox(width: 8),
                const Text(
                  'Lab Reflections',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildReflectionCard(
              'Hot Reload vs Hot Restart',
              'Hot Reload injects code changes on the fly while preserving current state. Hot Restart resets state variables and restarts the app from main().',
            ),
            const SizedBox(height: 8),
            _buildReflectionCard(
              'Declarative UI & State',
              'Flutter UI reflects current data state. Calling setState() triggers build() to reconstruct the subtree and repaint changed widgets.',
            ),
            const SizedBox(height: 8),
            _buildReflectionCard(
              'Native vs Cross-Platform',
              'Native development is best for low-level hardware access and heavy graphics, while Flutter provides faster multi-platform development from one codebase.',
            ),
            const SizedBox(height: 8),
            _buildReflectionCard(
              'Version Control Commits',
              'Small, descriptive commits keep changes easy to review, make bug tracing faster, and document incremental development in a portfolio.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard(String title, String content) {
    const accentLineColor = Color(0xFF4F46E5);

    return Card(
      child: ExpansionTile(
        iconColor: accentLineColor,
        collapsedIconColor: accentLineColor,
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
            child: Text(
              content,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
