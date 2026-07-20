import 'package:flutter_test/flutter_test.dart';
import 'package:mamacare/models/pregnant_woman.dart';
import 'package:mamacare/services/auth_service.dart';
import 'package:mamacare/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });


  test('registers a user and allows login', () async {

    final registered = await AuthService.register(
      fullName: 'Amina',
      email: 'amina@example.com',
      password: 'secure123',
      phoneNumber: '0700000000',
      gestationalAgeWeeks: 28,
      expectedDeliveryDate: '2026-12-15',
    );


    expect(registered, isTrue);


    final authenticated = await AuthService.login(
      email: 'amina@example.com',
      password: 'secure123',
    );


    expect(authenticated, isTrue);
  });



  test('stores and loads pregnant woman records', () async {

    final record = PregnantWoman(
      id: '1',
      fullName: 'Hawa',
      email: 'hawa@example.com',
      phoneNumber: '0712345678',
      gestationalAgeWeeks: 24,
      expectedDeliveryDate: '2026-11-01',
      registeredAt: DateTime(2026, 7, 17),
    );


    await DatabaseService.instance
        .savePregnantWomanRecord(record);



    final records =
        await AuthService.loadPregnantWomanRecords();



    expect(records, isNotEmpty);
    expect(records.first.fullName, 'Hawa');

  });

}