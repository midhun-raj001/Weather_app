import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../utils/weather_utils.dart';

class HourlyForecastRow extends StatelessWidget {
  final List<dynamic> forecastList;

  const HourlyForecastRow({super.key, required this.forecastList});

  String getDayName(int index) =>
      DateFormat('EEE').format(DateTime.now().add(Duration(days: index)));

  @override
  Widget build(BuildContext context) {
    print("Weather list length: ${forecastList.length}");

    if (forecastList.isEmpty) return const Center(child: Text("Weather data not available", style: TextStyle(color: Colors.white)));

    List<dynamic> safeList = forecastList.length > 8
        ? forecastList.sublist(0, 8)
        : forecastList;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(safeList.length, (i) {
          final item = safeList[i];
          
          List<dynamic>? weatherData = item["weather"];
          final condition = (weatherData != null && weatherData.isNotEmpty) 
              ? weatherData[0]["main"] 
              : "Unknown";

          return Container(
            width: 90,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getDayName(i),
                  style: const TextStyle(color: Colors.white),
                ),
                Lottie.asset(WeatherUtils.mainLottie(condition), height: 40),
                Text(
                  "${item["main"] != null ? item["main"]["temp"].round() : '--'}°",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
