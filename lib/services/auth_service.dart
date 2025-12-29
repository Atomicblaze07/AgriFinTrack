import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _pinKey = 'user_pin';

  // Save a 4-digit PIN
  Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  // Read saved PIN (or null if not set)
  Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }

  // Check if any PIN exists
  Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  // Validate entered PIN
  Future<bool> validatePin(String input) async {
    final saved = await getPin();
    if (saved == null) return false;
    return saved == input;
  }

  // Optional: clear PIN (for reset)
  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
  }
}
