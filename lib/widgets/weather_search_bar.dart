import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherSearchBar extends StatefulWidget {
  const WeatherSearchBar({super.key});

  @override
  State<WeatherSearchBar> createState() => _WeatherSearchBarState();
}

class _WeatherSearchBarState extends State<WeatherSearchBar> {
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);

    return Column(
      children: [
        TextField(
          controller: _cityController,
          onChanged: weatherProvider.searchCitySuggestions,
          onSubmitted: (value) {
            weatherProvider.fetchWeatherByCity(value);
            weatherProvider.clearSuggestions();
          },
          decoration: InputDecoration(
            hintText: "Search city",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                weatherProvider.fetchLiveLocationWeather();
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (weatherProvider.citySuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: weatherProvider.citySuggestions.length,
              itemBuilder: (_, i) {
                final c = weatherProvider.citySuggestions[i];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text("${c["name"]}, ${c["country"]}"),
                  subtitle: Text(
                    "Lat: ${c["lat"]}, Lon: ${c["lon"]}",
                  ),
                  onTap: () {
                    _cityController.text = c["name"];
                    weatherProvider.fetchWeatherByLatLon(c["lat"], c["lon"]);
                    weatherProvider.clearSuggestions();
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
