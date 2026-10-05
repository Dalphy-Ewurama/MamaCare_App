import 'package:flutter_test/flutter_test.dart';
import 'package:mamacare/models/vaccination_record.dart';
import 'package:mamacare/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Initialize standard background test suite FFI database factories
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Mamacare Database CRUD Integration Testing', () {
    const testEmail = 'testmother@mamacare.com';

    setUp(() async {
      // Clear out older instances before starting fresh test passes
      await DatabaseService.instance.clearAll();
    });

    test('Should successfully write and retrieve updated vaccination entries with notes', () async {
      // FIXED: Added required notes parameter argument here to fix constructor error
      final mockVax = VaccinationRecord(
        id: '${testEmail}_vax_test_id',
        name: 'Tetanus Toxoid Booster (TT1)',
        dueDate: '2026-11-20',
        completed: false,
        notes: 'Initial clinical milestone timeline reminder estimation.',
        createdAt: DateTime.now(),
      );

      // Save record down using your updated models structure layout
      await DatabaseService.instance.saveVaccinationRecord(mockVax);

      // FIXED: Used updated loadUserVaccinationRecords instead of deprecated undefined methods
      var records = await DatabaseService.instance.loadUserVaccinationRecords(testEmail);
      expect(records.length, 1);
      expect(records.first.completed, false);

      // FIXED: Used updateVaccinationDetails instead of old toggleVaccinationCompletion signature
      await DatabaseService.instance.updateVaccinationDetails(
        id: mockVax.id,
        confirmedDueDate: '2026-11-22',
        clinicianNotes: 'Confirmed and administered at health center by midwife.',
        isCompleted: true,
      );

      // Verify updates persisted seamlessly inside the backend table columns
      records = await DatabaseService.instance.loadUserVaccinationRecords(testEmail);
      expect(records.first.completed, true);
      expect(records.first.dueDate, '2026-11-22');
      expect(records.first.notes, 'Confirmed and administered at health center by midwife.');
    });
  });
}
