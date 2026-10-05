import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamacare/models/pregnant_woman.dart';
import 'package:mamacare/services/auth_service.dart';

class AntenatalScreen extends StatefulWidget {
  const AntenatalScreen({super.key});

  @override
  State<AntenatalScreen> createState() => _AntenatalScreenState();
}

class _AntenatalScreenState extends State<AntenatalScreen> {
  DateTime? _scanDate;
  DateTime? _calculatedEDD;
  List<Map<String, dynamic>> _calculatedVisits = [];
  bool _hasInitializedTimeline = false;

  // Calculates everything backward and forward from the historic scan date anchor
  void _generateTimelineFromScan({
    required DateTime scanCalendarDate,
    required int scanWeeks,
    required int scanDays,
    required int currentAgeWeeks,
  }) {
    List<Map<String, dynamic>> schedule = [];
    
    // Total days pregnant at time of scan
    int totalDaysPregnantAtScan = (scanWeeks * 7) + scanDays;
    
    // Human pregnancy is 280 days total (40 weeks)
    int remainingDaysToDelivery = 280 - totalDaysPregnantAtScan;
    
    // 1. Calculate the absolute TRUE Expected Date of Delivery (EDD)
    final DateTime trueEDD = scanCalendarDate.add(Duration(days: remainingDaysToDelivery));
    
    // 2. Find the baseline Conception/LMP Date (Week 0)
    final DateTime conceptionBaseline = scanCalendarDate.subtract(Duration(days: totalDaysPregnantAtScan));

    // 3. Generate milestones based on standard care pathways starting from Week 4 up to Week 40
    List<int> targetVisitWeeks = [8, 12, 16, 20, 24, 28, 32, 36];

    // Add historic first scan entry explicitly
    schedule.add({
      'week': scanWeeks,
      'days': scanDays,
      'date': scanCalendarDate,
      'title': 'First Ultrasound Scan (Confirmed Pregnancy) 🔍',
      'isPast': true,
    });

    for (int week in targetVisitWeeks) {
      // Skip scheduling past targets that happen before the initial medical scan week
      if (week <= scanWeeks) continue; 

      DateTime appointmentDate = conceptionBaseline.add(Duration(days: week * 7));
      
      // FIXED: Only marks past if the patient has completely outgrown that week milestone
      bool isPastVisit = week < currentAgeWeeks;

      String title = 'Routine Antenatal Care Checkup';
      if (week == 8) title = 'Booking & Registration Visit';
      if (week == 20) title = 'Anomaly Scan & Tetanus Shot';
      if (week >= 36) title = 'Weekly Delivery Preparation Check';

      schedule.add({
        'week': week,
        'days': 0,
        'date': appointmentDate,
        'title': title,
        'isPast': isPastVisit,
      });
    }

    // 4. Append final definitive delivery target block
    schedule.add({
      'week': 40,
      'days': 0,
      'date': trueEDD,
      'title': 'Expected Date of Delivery (EDD) 👶',
      'isPast': false,
    });

    // Sort timeline sequentially by calendar milestones
    schedule.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    setState(() {
      _scanDate = scanCalendarDate;
      _calculatedEDD = trueEDD;
      _calculatedVisits = schedule;
      _hasInitializedTimeline = true;
    });
  }

  Future<void> _handleDatePicker(BuildContext context, int currentAgeWeeks, String userEmail) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 21)), // default to ~3 weeks ago
      firstDate: DateTime.now().subtract(const Duration(days: 280)), 
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      // 1. Instantly update the UI timeline view roadmap block layout
      _generateTimelineFromScan(
        scanCalendarDate: picked,
        scanWeeks: 4,
        scanDays: 5,
        currentAgeWeeks: currentAgeWeeks,
      );
      
      // 2. Persist safely to your Sqflite table matching this mother's active profile account
      await AuthService.savePregnancyScanDate(userEmail, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antenatal Care Tracker'),
      ),
      body: FutureBuilder<List<PregnantWoman>>(
        future: AuthService.loadPregnantWomanRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pregnancy records found'));
          }

          final woman = snapshot.data!.first;

          // AUTO-LOAD HOOK: Triggers automatically on view initialization if sqflite data cache contains the scan record
          if (!_hasInitializedTimeline && woman.scanDate != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _generateTimelineFromScan(
                scanCalendarDate: woman.scanDate!,
                scanWeeks: 4,
                scanDays: 5,
                currentAgeWeeks: woman.gestationalAgeWeeks,
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient: ${woman.fullName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                
                // Interactive Setup Button
                ElevatedButton.icon(
                  onPressed: () => _handleDatePicker(context, woman.gestationalAgeWeeks, woman.email),
                  icon: const Icon(Icons.analytics_outlined),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _scanDate != null ? Colors.grey.shade200 : null,
                    foregroundColor: Colors.black87,
                  ),
                  label: Text(_scanDate == null 
                    ? 'Select Date of your 4W 5D Scan' 
                    : 'Scan Date: ${DateFormat('dd MMM yyyy').format(_scanDate!)}'
                  ),
                ),
                
                if (_calculatedEDD != null) ...[
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Predicted True EDD: ${DateFormat('EEEE, dd MMMM yyyy').format(_calculatedEDD!)}',
                      style: TextStyle(color: Colors.pink.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                
                const Divider(height: 40),
                const Text(
                  'Your Personalized Antenatal Roadmap',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                Expanded(
                  child: _calculatedVisits.isEmpty
                      ? const Center(
                          child: Text(
                            'Please select the calendar date when your 4-week scan was performed to generate your roadmap.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _calculatedVisits.length,
                          itemBuilder: (context, index) {
                            final visit = _calculatedVisits[index];
                            final DateTime date = visit['date'];
                            final bool isPast = visit['isPast'] ?? false;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              color: isPast ? Colors.grey.shade100 : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: visit['week'] == 40 
                                      ? Colors.green.shade100 
                                      : (isPast ? Colors.grey.shade300 : Colors.blue.shade100),
                                  child: Text(
                                    'W${visit['week']}',
                                    style: TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold,
                                      color: isPast ? Colors.black38 : Colors.black87
                                    ),
                                  ),
                                ),
                                title: Text(
                                  visit['title'],
                                  style: TextStyle(
                                    decoration: isPast ? TextDecoration.lineThrough : null,
                                    color: isPast ? Colors.black45 : Colors.black87
                                  ),
                                ),
                                subtitle: Text(
                                  'Date: ${DateFormat('dd MMM yyyy (EEEE)').format(date)}',
                                  style: TextStyle(color: isPast ? Colors.black38 : Colors.black54),
                                ),
                                trailing: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: visit['week'] == 40
? const Icon(Icons.child_care, color: Colors.green)
: (isPast
? const Icon(Icons.check_circle, color: Colors.grey, size: 18)
: const Icon(Icons.arrow_forward_ios, size: 12)),
),
),
);
},
),
),
],
),
);
},
),
);
}
}

