import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../utils/weather_utils.dart';
import '../providers/weather_provider.dart';
import '../widgets/hourly_forecast_row.dart';
import '../widgets/temperature_chart.dart';
import '../widgets/weather_search_bar.dart';
import '../services/notification_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(
        context,
        listen: false,
      ).initializeUserPreferences();
    });
  }

  List<double> _getWeeklyTemps(List<dynamic> forecastList) {
    if (forecastList.isEmpty) return [];
    List<double> temps = [];
    for (int i = 0; i < forecastList.length; i++) {
      if (i % 8 == 0) {
        final item = forecastList[i];
        if (item != null &&
            item["main"] != null &&
            item["main"]["temp"] != null) {
          temps.add(item["main"]["temp"].toDouble());
        }
        if (temps.length == 7) break;
      }
    }
    return temps;
  }

  void _showSettings(BuildContext context) {
    final provider = Provider.of<WeatherProvider>(context, listen: false);
    final highController = TextEditingController(
      text: provider.highTempLimit.toString(),
    );
    final lowController = TextEditingController(
      text: provider.lowTempLimit.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Consumer<WeatherProvider>(
            builder: (context, provider, child) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SwitchListTile(
                        title: const Text("Lock Location"),
                        subtitle: Text(
                          provider.isLocationLocked && provider.weather != null
                              ? "Locked to ${provider.weather!.cityName}"
                              : "Always load your current city on startup",
                        ),
                        value: provider.isLocationLocked,
                        onChanged: (val) {
                          provider.toggleLocationLock(val);
                        },
                      ),
                      SwitchListTile(
                        title: const Text("Enable Weather Alerts"),
                        subtitle: const Text(
                          "Receive notifications for temp & rain",
                        ),
                        value: provider.alertsEnabled,
                        onChanged: (val) async {
                          if (val) {
                            bool perm =
                                await NotificationService.requestPermissionAndCheck();
                            if (!perm) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Notification permission required",
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                          }
                          provider.toggleAlerts(val);
                        },
                      ),
                      if (provider.alertsEnabled) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (provider.alertsEnabled) ...[
                              Expanded(
                                child: TextField(
                                  controller: highController,
                                  decoration: const InputDecoration(
                                    labelText: "High Temp Limit (°C)",
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: lowController,
                                  decoration: const InputDecoration(
                                    labelText: "Low Temp Limit (°C)",
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (provider.alertsEnabled) {
                              provider.updateAlertLimits(
                                double.tryParse(highController.text) ??
                                    provider.highTempLimit,
                                double.tryParse(lowController.text) ??
                                    provider.lowTempLimit,
                              );
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Settings saved")),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text("Save Settings"),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          final weather = weatherProvider.weather;

          return Stack(
            children: [
              // Background Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: weather != null
                        ? WeatherUtils.backgroundGradient(weather)
                        : [Colors.blue, Colors.lightBlueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Background Animation
              if (weather != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: WeatherUtils.isNight(weather) ? 0.15 : 0.35,
                    child: Lottie.asset(
                      WeatherUtils.backgroundAnimation(weather.condition),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              SafeArea(
                child: weatherProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  const Expanded(child: WeatherSearchBar()),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.settings,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _showSettings(context),
                                  ),
                                ],
                              ),
                            ),

                            if (weatherProvider.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  weatherProvider.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                  ),
                                ),
                              ),

                            if (weather != null) ...[
                              Text(
                                weather.cityName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(
                                height: 180,
                                child: Lottie.asset(
                                  WeatherUtils.mainLottie(weather.condition),
                                ),
                              ),

                              Text(
                                "${weather.temperature.round()}°C",
                                style: const TextStyle(
                                  fontSize: 60,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                weather.condition,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 24,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "💧 ${weather.humidity}%   💨 ${weather.windSpeed.toStringAsFixed(1)} m/s ${WeatherUtils.windDirection(weather.windDeg)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 20),
                              TemperatureChart(
                                temps: _getWeeklyTemps(
                                  weatherProvider.forecastList,
                                ),
                              ),

                              const SizedBox(height: 10),
                              HourlyForecastRow(
                                forecastList: weatherProvider.forecastList,
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
