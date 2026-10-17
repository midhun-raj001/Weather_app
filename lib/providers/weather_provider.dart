import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../services/alert_service.dart';
import '../services/preferences_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherApiService _apiService = WeatherApiService();
  final UserService _userService = UserService();

  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  List<dynamic> _forecastList = [];
  List<dynamic> get forecastList => _forecastList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<dynamic> _citySuggestions = [];
  List<dynamic> get citySuggestions => _citySuggestions;

  bool _isLocationLocked = false;
  bool get isLocationLocked => _isLocationLocked;

  bool _alertsEnabled = false;
  bool get alertsEnabled => _alertsEnabled;

  double _highTempLimit = 35.0;
  double get highTempLimit => _highTempLimit;

  double _lowTempLimit = 15.0;
  double get lowTempLimit => _lowTempLimit;

  DateTime? _lastRainAlertTime;

  Future<void> initializeUserPreferences() async {
    try {
      // LOAD SETTINGS SYNC OR FAST FROM LOCAL
      _isLocationLocked = await PreferencesService.getLocationLockStatus();
      _alertsEnabled = await PreferencesService.getAlertsEnabled();
      _highTempLimit = await PreferencesService.getHighTempLimit();
      _lowTempLimit = await PreferencesService.getLowTempLimit();
      final lockedLocation = await PreferencesService.getLockedLocation();

      if (_alertsEnabled) {
        AlertService.startChecking(this);
      }

      // Load user profile specifically FOR SMS sync
      final profile = await _userService.getUserProfile();

      if (_isLocationLocked &&
          lockedLocation != null &&
          lockedLocation.isNotEmpty) {
        await fetchWeatherByCity(lockedLocation);
        return;
      }
      await fetchWeatherByCity("Chennai");
    } catch (e) {
      debugPrint("Error loading preferences: $e");
      await fetchWeatherByCity("Chennai");
    }
  }

  Future<void> toggleLocationLock(bool locked) async {
    try {
      _isLocationLocked = locked;
      String loc = "";
      if (locked && _weather != null) {
        loc = _weather!.cityName;
      }
      await PreferencesService.saveLocationLock(locked, loc);
      notifyListeners();
    } catch (e) {
      debugPrint("Error toggling location lock: $e");
    }
  }

  Future<void> updateAlertLimits(double high, double low) async {
    _highTempLimit = high;
    _lowTempLimit = low;
    await PreferencesService.saveAlertsPrefs(
      _alertsEnabled,
      _highTempLimit,
      _lowTempLimit,
    );
    notifyListeners();
  }

  Future<void> toggleAlerts(bool enabled) async {
    _alertsEnabled = enabled;
    await PreferencesService.saveAlertsPrefs(
      _alertsEnabled,
      _highTempLimit,
      _lowTempLimit,
    );
    if (_alertsEnabled) {
      AlertService.startChecking(this);
    } else {
      AlertService.stopChecking();
    }
    notifyListeners();
  }

  Future<void> _postProcessWeather() async {
    if (_weather == null) return;

    try {
      // 1. Rain Alert
      if (_alertsEnabled) {
        final cond = _weather!.condition.toLowerCase();
        final id = _weather!.weatherId;

        // 2xx: Thunderstorm, 3xx: Drizzle, 5xx: Rain
        final bool isRaining =
            (id >= 200 && id < 600) ||
            cond.contains('rain') ||
            cond.contains('drizzle') ||
            cond.contains('thunder');

        if (isRaining) {
          // Send alert if it's the first time or if enough time has passed
          final bool shouldAlert =
              _lastRainAlertTime == null ||
              DateTime.now().difference(_lastRainAlertTime!).inSeconds >= 10;

          if (shouldAlert) {
            debugPrint(
              "WeatherProvider: Rain detected (ID: $id)! Triggering rain alert...",
            );
            NotificationService.showRainAlert();
            _lastRainAlertTime = DateTime.now();
          } else {
            debugPrint(
              "WeatherProvider: Rain detected but throttled. Last alert was at $_lastRainAlertTime",
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error post-processing weather: $e");
    }
  }

  Future<void> fetchWeatherByCity(String city) async {
    _setLoading(true);
    try {
      _weather = await _apiService.getWeatherByCity(city);
      if (_weather != null) {
        // Start processing alerts immediately after current weather is fetched
        // Don't await here to avoid delaying forecast fetching, but start it
        _postProcessWeather();

        // Fetch forecast in parallel/sequentially (but after triggering alerts)
        _forecastList = await _apiService.getForecastByCity(_weather!.cityName);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch weather for $city';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchWeatherByLatLon(double lat, double lon) async {
    _setLoading(true);
    try {
      _weather = await _apiService.getWeatherByLatLon(lat, lon);
      if (_weather != null) {
        // Start processing alerts immediately
        _postProcessWeather();

        _forecastList = await _apiService.getForecastByLatLon(lat, lon);
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to fetch weather data';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchLiveLocationWeather() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _errorMessage = 'Location services are disabled.';
      notifyListeners();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _errorMessage = 'Location permissions are denied.';
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _errorMessage = 'Location permissions are permanently denied.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await fetchWeatherByLatLon(position.latitude, position.longitude);
    } catch (e) {
      _errorMessage = 'Failed to get current location';
      _setLoading(false);
    }
  }

  Future<void> searchCitySuggestions(String input) async {
    if (input.isEmpty) {
      _citySuggestions = [];
      notifyListeners();
      return;
    }

    try {
      _citySuggestions = await _apiService.fetchCitySuggestions(input);
      notifyListeners();
    } catch (e) {
      _citySuggestions = [];
      notifyListeners();
    }
  }

  void clearSuggestions() {
    _citySuggestions = [];
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
