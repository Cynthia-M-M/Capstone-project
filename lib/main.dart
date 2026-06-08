import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Environment missing, running in demo mode.");
  }
  runApp(const UjimaSaccoApp());
}

class UjimaSaccoApp extends StatelessWidget {
  const UjimaSaccoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ujima Core Architecture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A148C),
          primary: const Color(0xFF4A148C),
          secondary: const Color(0xFFFFB300),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A148C),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const MainNavigator(),
    );
  }
}

/// ---------------------------------------------------------
/// THE MAIN NAVIGATOR (Handles the Bottom Tabs)
/// ---------------------------------------------------------
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // We pass a callback to the Home tab so its shortcut button can switch tabs
  void _navigateToAssessment() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // IndexedStack keeps the state of the form alive when switching tabs
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeTab(onStartAssessment: _navigateToAssessment),
          const AssessmentTab(),
          const CaseHistoryTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: const Color(0xFFFFB300).withOpacity(0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Command Center'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Ethical Engine'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Case Ledger'),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------
/// TAB 1: THE HOME DASHBOARD
/// ---------------------------------------------------------
class HomeTab extends StatelessWidget {
  final VoidCallback onStartAssessment;
  const HomeTab({super.key, required this.onStartAssessment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('UJIMA SACCO', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [
          Padding(
            padding: EdgeInsets.all(12.0),
            child: CircleAvatar(backgroundColor: Color(0xFFFFB300), child: Icon(Icons.person, color: Colors.white, size: 20)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Welcome back, Officer.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212121))),
          const Text("Nairobi Central Branch | DPA 2022 Verified", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          // Shortcut Action Card
          Card(
            color: const Color(0xFF4A148C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield, color: Color(0xFFFFB300), size: 32),
                  const SizedBox(height: 16),
                  const Text("New Escalation Pending", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("The Guardian Agent has flagged 1 application requiring human contextual review.", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB300), foregroundColor: const Color(0xFF4A148C)),
                      onPressed: onStartAssessment, // Triggers the tab switch
                      child: const Text("Launch Ethical Assessment"),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          const Text("System Metrics (Today)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard("Auto-Approved", "142", Icons.check_circle, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard("Escalated", "12", Icons.warning, Colors.orange)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String count, IconData icon, Color color) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------
/// TAB 2: THE ETHICAL ASSESSMENT ENGINE (Your existing code)
/// ---------------------------------------------------------
class AssessmentTab extends StatefulWidget {
  const AssessmentTab({super.key});

  @override
  State<AssessmentTab> createState() => _AssessmentTabState();
}

class _AssessmentTabState extends State<AssessmentTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController marketController = TextEditingController(text: 'Wakulima Market, Marikiti, Githurai Market');
  final TextEditingController vendorController = TextEditingController(text: 'Tomato and Onion');
  
  bool isLoading = false;
  
  Map<String, String> structuredBriefing = {
    'Vendor Profile': 'Awaiting system execution...',
    'Market Context': 'Awaiting telemetry...',
    'Request': 'Awaiting parameters...',
    'Risk Flag': 'Awaiting verification...',
    'Opportunity': 'Awaiting recommendations...'
  };

  String _extractSection(String rawText, String sectionName) {
    if (!rawText.contains(sectionName)) return "No data recorded for $sectionName.";
    try {
      final lines = rawText.split('\n');
      final startIndex = lines.indexWhere((line) => line.contains(sectionName));
      if (startIndex == -1) return "Data partition match fault.";
      
      List<String> content = [];
      for (int i = startIndex; i < lines.length; i++) {
        final currentLine = lines[i];
        if (i != startIndex && (currentLine.startsWith('Vendor Profile:') || 
                                currentLine.startsWith('Market Context:') || 
                                currentLine.startsWith('Request:') || 
                                currentLine.startsWith('Risk Flag:') || 
                                currentLine.startsWith('Opportunity:'))) {
          break;
        }
        if (i != startIndex) {
          content.add(currentLine.replaceAll(RegExp(r'[\*\#\-\>]'), '').trim());
        }
      }
      return content.where((s) => s.isNotEmpty).join('\n');
    } catch (e) {
      return "Error decoding segment.";
    }
  }

  Future<void> kickoffAgent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      structuredBriefing = {
        'Vendor Profile': 'Evaluating...', 'Market Context': 'Evaluating...', 
        'Request': 'Evaluating...', 'Risk Flag': 'Evaluating...', 'Opportunity': 'Evaluating...'
      };
    });

    final String token = dotenv.env['CREWAI_SECRET_TOKEN'] ?? '';
    const String apiUrl = 'https://mama-mboga-market-intelligence-ethical-loan-d7a2b1da.crewai.com';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "market_locations": marketController.text.trim(),
          "vendor_type": vendorController.text.trim(),
          "database_location": "AWS Africa (Cape Town) Region - af-south-1",
          "vendor_name": "Mama Akinyi (Anonymized ID: NBI-GITH-883)"
        }),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String rawResult = data['output'] ?? data['result'] ?? data['response'] ?? '';
        
        if (rawResult.isNotEmpty) {
          setState(() {
            structuredBriefing['Vendor Profile'] = _extractSection(rawResult, 'Vendor Profile');
            structuredBriefing['Market Context'] = _extractSection(rawResult, 'Market Context');
            structuredBriefing['Request'] = _extractSection(rawResult, 'Request');
            structuredBriefing['Risk Flag'] = _extractSection(rawResult, 'Risk Flag');
            structuredBriefing['Opportunity'] = _extractSection(rawResult, 'Opportunity');
          });
        } else {
          _injectMVPData();
        }
      } else {
        _injectMVPData();
      }
    } catch (e) {
      _injectMVPData();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _injectMVPData() {
    setState(() {
      structuredBriefing['Vendor Profile'] = "Mama Akinyi (ID: NBI-GITH-883). 42 years old, primary caretaker of 3. Operates a high-velocity perishable goods stall (Tomatoes/Onions) in Githurai Market. Consistent M-Pesa till history for 14 months.";
      structuredBriefing['Market Context'] = "Scout Agent reports a critical 18% price surge in wholesale tomato crates at Wakulima and Marikiti markets over the last 48 hours due to long-rains transport bottlenecks from the Rift Valley.";
      structuredBriefing['Request'] = "KES 15,000 working capital loan to secure early morning wholesale inventory before price surges further.";
      structuredBriefing['Risk Flag'] = "Automated systems flagged a 45% drop in daily revenue this week. However, Guardian Agent identifies this is NOT due to poor business practices, but a direct correlation to the systemic wholesale supply shock. The vendor is preserving capital.";
      structuredBriefing['Opportunity'] = "Do not deny. Approve KES 12,000 immediately to ensure inventory security. Implement a 3-day grace period on daily micro-repayments to allow retail prices in Githurai to adjust to the new wholesale reality.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('HUNTER AGENT NODE', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Execution Parameters", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const Divider(height: 20),
                    TextFormField(
                      controller: marketController,
                      decoration: const InputDecoration(labelText: 'Market Scope', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: vendorController,
                      decoration: const InputDecoration(labelText: 'Vendor Profile Target', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : kickoffAgent,
                        icon: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.rocket_launch, color: Colors.white),
                        label: Text(isLoading ? 'Processing...' : 'Execute Assessment', style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A148C)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()))
            else
              Column(
                children: structuredBriefing.entries.map((entry) {
                  return Card(
                    color: Colors.white,
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Align(alignment: Alignment.centerLeft, child: Text(entry.value, style: const TextStyle(height: 1.4))),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------
/// TAB 3: THE CASE LEDGER (History Mockup)
/// ---------------------------------------------------------
class CaseHistoryTab extends StatelessWidget {
  const CaseHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('CASE LEDGER', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHistoryTile("Mama Akinyi", "Githurai Market", "Approved with Grace Period", Colors.green),
          _buildHistoryTile("Baba Njoroge", "Marikiti", "Restructured Repayment", Colors.blue),
          _buildHistoryTile("Grace Mutuku", "Wakulima Market", "Pending Escalation Review", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String name, String location, String status, Color statusColor) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: statusColor.withOpacity(0.2), child: Icon(Icons.folder, color: statusColor)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location),
        trailing: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}