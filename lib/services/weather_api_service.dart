import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';
import 'package:flutter/foundation.dart';

class WeatherApiService {
  String get _apiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  Future<WeatherModel?> getWeatherByCity(String city) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric'));
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error getting weather by city: $e');
    }
    return null;
  }

  Future<List<dynamic>> getForecastByCity(String city) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$_apiKey&units=metric'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['list'] ?? [];
      }
    } catch (e) {
      debugPrint('Error getting forecast by city: $e');
    }
    return [];
  }

  Future<WeatherModel?> getWeatherByLatLon(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'));
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint('Error getting weather by lat/lon: $e');
    }
    return null;
  }

  Future<List<dynamic>> getForecastByLatLon(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['list'] ?? [];
      }
    } catch (e) {
      debugPrint('Error getting forecast by lat/lon: $e');
    }
    return [];
  }

  Future<List<dynamic>> fetchCitySuggestions(String input) async {
    try {
      final response = await http.get(Uri.parse(
          'http://api.openweathermap.org/geo/1.0/direct?q=$input&limit=5&appid=$_apiKey'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) ?? [];
      }
    } catch (e) {
      debugPrint('Error getting city suggestions: $e');
    }
    return [];
  }
}
