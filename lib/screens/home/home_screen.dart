import 'package:flutter/material.dart';
import 'package:mamacare/models/pregnant_woman.dart';
import 'package:mamacare/screens/auth/login_screen.dart';
import 'package:mamacare/services/auth_service.dart';
import 'package:mamacare/services/notification_service.dart';
import '../../app_theme.dart';
import 'package:mamacare/screens/antenatal/antenatal_screen.dart';
import 'package:mamacare/screens/vaccination/vaccination_screen.dart';
import '../danger_signs/danger_signs_screen.dart';
import '../facility/facility_locator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final List<String> tips = [
  "Drink plenty of water.",
  "Take your iron tablets.",
  "Attend every antenatal visit.",
  "Eat fruits every day.",
  "Sleep at least 8 hours.",
];

class _FeatureCard extends StatelessWidget {

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;


  const _FeatureCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0,3),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            CircleAvatar(
              radius: 25,
              backgroundColor: color.withValues(alpha:0.15),

              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(height:12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:14,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>?> _userFuture;
  late Future<List<PregnantWoman>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    NotificationService.showReminder(
      title: 'MamaCare Reminder',
      body: 'Keep your antenatal appointments and stay hydrated today.',
    );

    _userFuture = AuthService.getCurrentUser();
    _recordsFuture = AuthService.loadPregnantWomanRecords();
  }

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "MamaCare",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        backgroundColor: const Color(0xFF2E6B65),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Good Morning 👋",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            FutureBuilder<Map<String, dynamic>?>(
              future: _userFuture,
              builder: (context, snapshot) {
                final name = snapshot.data?['fullName'] ?? 'Mother';
                return Text(
                  "Welcome, $name ❤️",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E6B65),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<PregnantWoman>>(
              future: _recordsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Color(0xFF2E6B65)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffF78DA7), Color(0xffFF8A65)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "No pregnancy record available",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                final woman = snapshot.data!.first;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffF78DA7), Color(0xffFF8A65)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffF78DA7).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pregnancy Progress",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Week ${woman.gestationalAgeWeeks}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Expected Delivery:\n${woman.expectedDeliveryDate}",
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                       const Icon(
                      Icons.pregnant_woman,
                      color: Colors.white,
                      size: 55,
                     ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: const Icon(Icons.lightbulb, color: Color(0xffFF8A65), size: 28),
                title: const Text("Today's Tip", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  tips[DateTime.now().day % tips.length],
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 28),

const Text(
  "Quick Services",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2E6B65),
  ),
),

const SizedBox(height: 12),

GridView.count(
  crossAxisCount: 2,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  children: [

    _FeatureCard(
      title: "Antenatal Visits",
      icon: Icons.medical_services,
      color: const Color(0xFF2E6B65),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AntenatalScreen(),
          ),
        );
      },
    ),


    _FeatureCard(
      title: "Vaccination Records",
      icon: Icons.vaccines,
      color: Colors.orange,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const VaccinationScreen(),
          ),
        );
      },
    ),


    _FeatureCard(
      title: "Danger Signs",
      icon: Icons.warning,
      color: Colors.redAccent,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DangerSignsScreen(),
          ),
        );
      },
    ),


    _FeatureCard(
      title: "Facility Locator",
      icon: Icons.local_hospital,
      color: Colors.blue,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FacilityLocatorScreen(),
          ),
        );
      },
    ),

  ],
),

const SizedBox(height: 28),
            const SizedBox(height: 28),
            const Text(
              "Pregnancy Records",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E6B65),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<PregnantWoman>>(
              future: _recordsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: const ListTile(
                      leading: Icon(Icons.folder_open, color: Colors.grey),
                      title: Text("No records yet"),
                      subtitle: Text("Your registered pregnancy details will appear here."),
                    ),
                  );
                }

                final records = snapshot.data!;
                return Column(
                  children: [
                    for (var record in records)
                      Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xffE8F5E9),
                            child: Icon(Icons.person, color: Color(0xFF2E6B65)),
                          ),
                          title: Text(record.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text("Week ${record.gestationalAgeWeeks} • Expected Delivery: ${record.expectedDeliveryDate}",
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            ),
                            ),
                            ),
                            ],
                            );
                            },
                            ),
                            ],
                            ),
                            ),
                            );
                            }
                            }
