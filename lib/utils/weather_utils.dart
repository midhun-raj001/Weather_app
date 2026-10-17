import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherUtils {
  static List<Color> getGradient(String condition) {
    if (condition.toLowerCase().contains("snow")) {
      return [Colors.blueGrey.shade200, const Color.fromARGB(137, 51, 51, 51)];
    } else if (condition.toLowerCase().contains("rain")) {
      return [Colors.blueGrey, Colors.blueGrey.shade700];
    } else if (condition.toLowerCase().contains("clear")) {
      return [Colors.orange, Colors.blue];
    } else {
      return [Colors.blue, Colors.lightBlueAccent];
    }
  }

  static bool isNight(WeatherModel? weather) {
    if (weather == null || weather.sunrise == 0 || weather.sunset == 0) return false;

    final nowUtc = DateTime.now().toUtc();
    final cityTime = nowUtc.add(Duration(seconds: weather.timezoneOffset));
    final currentUnix = cityTime.millisecondsSinceEpoch ~/ 1000;

    return currentUnix < weather.sunrise || currentUnix > weather.sunset;
  }

  static String windDirection(int windDeg) {
    const dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
    int index = ((windDeg / 45) % 8).round();
    
    // SAFE ACCESS to prevent index out of range
    if (index >= dirs.length) {
      index = 0;
    }
    
    // Fallback UI or safe check
    if (dirs.isNotEmpty && index < dirs.length) {
      return dirs[index];
    }
    return "N";
  }

  static String mainLottie(String condition) {
    final cond = condition.toLowerCase();

    if (cond.contains("rain")) {
      return "assets/rain.json";
    } else if (cond.contains("thunder")) {
      return "assets/thunder.json";
    } else if (cond.contains("snow")) {
      return "assets/snow.json";
    } else if (cond.contains("clear")) {
      return "assets/clear.json";
    } else {
      return "assets/clouds.json";
    }
  }

  static String backgroundAnimation(String condition) {
    final cond = condition.toLowerCase();

    if (cond.contains("rain")) {
      return "assets/rainy-bg.json";
    } else if (cond.contains("thunder")) {
      return "assets/rain.json";
    } else if (cond.contains("snow")) {
      return "assets/snow-bg.json";
    } else if (cond.contains("clear")) {
      return "assets/clear.json";
    } else {
      return "assets/clouds.json";
    }
  }

  static List<Color> backgroundGradient(WeatherModel weather) {
    if (isNight(weather)) {
      return [Colors.black, Colors.blueGrey.shade900];
    }

    if (weather.condition == "Clear") {
      return [
        const Color.fromARGB(255, 82, 232, 243),
        const Color.fromARGB(255, 255, 240, 105),
      ];
    } else if (weather.condition == "Rain") {
      return [Colors.blueGrey, Colors.blue];
    } else if (weather.condition == "Snow") {
      return [Colors.blueGrey.shade200, Colors.white];
    } else {
      return [Colors.lightBlue, Colors.blueAccent];
    }
  }
}
