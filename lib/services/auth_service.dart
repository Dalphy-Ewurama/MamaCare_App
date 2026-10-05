import 'package:shared_preferences/shared_preferences.dart';
import '../models/pregnant_woman.dart';
import 'database_service.dart';

class AuthService {
  AuthService._();

  static const _userKey = 'auth_user';

  // REGISTER
  static Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required int gestationalAgeWeeks,
    required String expectedDeliveryDate,
  }) async {
    final record = PregnantWoman(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      gestationalAgeWeeks: gestationalAgeWeeks,
      expectedDeliveryDate: expectedDeliveryDate,
      registeredAt: DateTime.now(),
    );

    final success = await DatabaseService.instance.registerUser(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      gestationalAgeWeeks: gestationalAgeWeeks,
      expectedDeliveryDate: expectedDeliveryDate,
    );

    if (!success) {
      return false;
    }

    await DatabaseService.instance.savePregnantWomanRecord(record);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, email);

    return true;
  }

  // LOGIN
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final success = await DatabaseService.instance.loginUser(
      email: email,
      password: password,
    );

    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, email);
    }

    return success;
  }

  // CHECK LOGIN STATUS
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey) != null;
  }

  // GET CURRENT USER
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return await DatabaseService.instance.getCurrentUser();
  }

  // LOAD PREGNANCY RECORDS
  static Future<List<PregnantWoman>> loadPregnantWomanRecords() async {
    return await DatabaseService.instance.loadPregnantWomanRecords();
  }

  // SAVE PREGNANCY SCAN DATE
  static Future<bool> savePregnancyScanDate(String email, DateTime scanDate) async {
    try {
      return await DatabaseService.instance.updateScanDate(email, scanDate);
    } catch (e) {
      return false;
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await DatabaseService.instance.logout();
  }
}
