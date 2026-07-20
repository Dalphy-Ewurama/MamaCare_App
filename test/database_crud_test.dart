import 'package:flutter_test/flutter_test.dart';
import 'package:mamacare/models/antenatal_visit.dart';
import 'package:mamacare/models/vaccination_record.dart';
import 'package:mamacare/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DatabaseService.instance.clearAll();
  });

  test('saves and loads antenatal visits', () async {
    final visit = AntenatalVisit(
      id: 'visit-1',
      title: 'Anomaly Scan',
      date: '2026-08-20',
      notes: 'Bring medical card',
      createdAt: DateTime(2026, 7, 17),
    );

    await DatabaseService.instance.saveAntenatalVisit(visit);
    final visits = await DatabaseService.instance.loadAntenatalVisits();

    expect(visits, hasLength(1));
    expect(visits.first.title, 'Anomaly Scan');
  });

  test('saves and toggles vaccination records', () async {
    final record = VaccinationRecord(
      id: 'vacc-1',
      name: 'BCG',
      dueDate: 'At birth',
      completed: false,
      createdAt: DateTime(2026, 7, 17),
    );

    await DatabaseService.instance.saveVaccinationRecord(record);
    await DatabaseService.instance.toggleVaccinationCompletion('vacc-1');
    final records = await DatabaseService.instance.loadVaccinationRecords();

    expect(records.first.completed, isTrue);
  });
}
