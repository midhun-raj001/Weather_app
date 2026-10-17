import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../providers/weather_provider.dart';
import 'notification_service.dart';

class AlertService {
  static Timer? _backgroundTimer;

  static void startChecking(WeatherProvider provider) {
    if (_backgroundTimer != null && _backgroundTimer!.isActive) {
      return; // Timer already running
    }

    debugPrint("Started background weather checking (every 5 mins)");
    _backgroundTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      debugPrint("Performing periodic background weather check...");

      // If location is locked, fetch for the locked location
      // Otherwise, fetch for current location if the app has permission
      if (provider.isLocationLocked && provider.weather != null) {
        await provider.fetchWeatherByCity(provider.weather!.cityName);
      } else {
        await provider.fetchLiveLocationWeather();
      }

      _checkTemperatureLimits(provider);
    });
  }

  static void stopChecking() {
    if (_backgroundTimer != null) {
      _backgroundTimer!.cancel();
      _backgroundTimer = null;
      debugPrint("Stopped background weather checking");
    }
  }

  static void _checkTemperatureLimits(WeatherProvider provider) {
    final weather = provider.weather;
    if (weather == null) return;
    if (!provider.alertsEnabled) return;

    final double currentTemp = weather.temperature;

    if (currentTemp >= provider.highTempLimit) {
      NotificationService.showTemperatureAlert(
        "🔥 High Temperature Alert!",
        "Current temperature (${currentTemp.toStringAsFixed(1)}°C) exceeded your limit of ${provider.highTempLimit.toStringAsFixed(1)}°C.",
      );
    } else if (currentTemp <= provider.lowTempLimit) {
      NotificationService.showTemperatureAlert(
        "🥶 Low Temperature Alert!",
        "Temperature (${currentTemp.toStringAsFixed(1)}°C) dropped below your limit of ${provider.lowTempLimit.toStringAsFixed(1)}°C.",
      );
    }
  }
}
