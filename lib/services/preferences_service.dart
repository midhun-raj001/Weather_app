import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class PreferencesService {
  static const String keyIsLocationLocked = 'isLocationLocked';
  static const String keyLockedLocation = 'lockedLocation';
  static const String keyPhoneNumber = 'phoneNumber';
  static const String keyAlertsEnabled = 'alertsEnabled';
  static const String keyHighTempLimit = 'highTempLimit';
  static const String keyLowTempLimit = 'lowTempLimit';
  static const String keySmsAlertsEnabled = 'smsAlertsEnabled';

  static Future<void> saveLocationLock(bool isLocked, String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyIsLocationLocked, isLocked);
      await prefs.setString(keyLockedLocation, location);
    } catch (e) {
      debugPrint("Error saving location lock to SharedPreferences: $e");
    }
  }

  static Future<bool> getLocationLockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLocationLocked) ?? false;
  }

  static Future<String?> getLockedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyLockedLocation);
  }

  static Future<void> saveAlertsPrefs(bool enabled, double high, double low) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyAlertsEnabled, enabled);
    await prefs.setDouble(keyHighTempLimit, high);
    await prefs.setDouble(keyLowTempLimit, low);
  }

  static Future<bool> getAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyAlertsEnabled) ?? false;
  }

  static Future<double> getHighTempLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyHighTempLimit) ?? 35.0;
  }

  static Future<double> getLowTempLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(keyLowTempLimit) ?? 15.0;
  }
  
  static Future<void> saveSmsAlertsPrefs(bool enabled, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keySmsAlertsEnabled, enabled);
    await prefs.setString(keyPhoneNumber, phoneNumber);
  }

  static Future<bool> getSmsAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keySmsAlertsEnabled) ?? false;
  }

  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPhoneNumber);
  }
}
