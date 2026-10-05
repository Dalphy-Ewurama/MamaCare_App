import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mamacare/models/vaccination_record.dart';
import 'package:mamacare/services/auth_service.dart';
import 'package:mamacare/services/database_service.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  late Future<List<VaccinationRecord>> _vaccinationsFuture;
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  void _fetchRecords() {
    setState(() {
      _vaccinationsFuture = AuthService.loadPregnantWomanRecords().then((women) {
        if (women.isNotEmpty) {
          _userEmail = women.first.email;
          return DatabaseService.instance.loadUserVaccinationRecords(_userEmail);
        }
        return [];
      });
    });
  }

  void _openEditDialog(VaccinationRecord record) {
    final notesController = TextEditingController(text: record.notes);
    DateTime selectedDate = DateTime.parse(record.dueDate);
    bool status = record.completed;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(record.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text("Mark Administered"),
                  value: status,
                  // FIXED: Replaced deprecated activeColor parameter
                  activeTrackColor: const Color(0xFF2E6B65),
                  onChanged: (val) => setDialogState(() => status = val),
                ),
                ListTile(
                  title: const Text("Administration Date"),
                  subtitle: Text(DateFormat('dd MMMM yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 280)),
                      lastDate: DateTime.now().add(const Duration(days: 280)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: "Clinician / Facility Notes",
                    hintText: "e.g., Administered by Midwife at Ridge Hospital",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E6B65)),
              onPressed: () async {
                await DatabaseService.instance.updateVaccinationDetails(
                  id: record.id,
                  confirmedDueDate: DateFormat('yyyy-MM-dd').format(selectedDate),
                  clinicianNotes: notesController.text,
                  isCompleted: status,
                );
                
                // FIXED: Checked mounted property to guard BuildContext across the await statement safely
                if (!context.mounted) return;
                Navigator.pop(context);
                _fetchRecords();
              },
              child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maternal Immunization Log"),
        backgroundColor: const Color(0xFF2E6B65),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.amber.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber.shade900, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Disclaimer: Dates are estimated intervals. Always prioritize the instructions written inside your physical Maternal Health Record book by your doctor or midwife.",
                    style: TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<VaccinationRecord>>(
              future: _vaccinationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Please select a pregnancy scan date under Antenatal row parameters to map immunizations."),
                  );
                }

                final list = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final parsedDate = DateTime.parse(item.dueDate);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: item.completed ? Colors.green.shade100 : Colors.teal.shade50,
                          child: Icon(
                            item.completed ? Icons.gpp_good : Icons.vaccines,
                            color: item.completed ? Colors.green : const Color(0xFF2E6B65),
                          ),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Due Date: ${DateFormat('EEE, dd MMM yyyy').format(parsedDate)}"),
                            if (item.notes.isNotEmpty)
                              Padding(
                                // FIXED: Swapped invalid padding property type constructor 
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "Notes: ${item.notes}",
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_note, color: Colors.blueGrey),
                          onPressed: () => _openEditDialog(item),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
