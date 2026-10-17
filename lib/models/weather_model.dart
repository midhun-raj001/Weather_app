class WeatherModel {
  final String cityName;
  final int weatherId;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final int sunrise;
  final int sunset;
  final int timezoneOffset;

  WeatherModel({
    required this.cityName,
    required this.weatherId,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    this.sunrise = 0,
    this.sunset = 0,
    this.timezoneOffset = 0,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      weatherId: json['weather']?[0]?['id'] ?? 800,
      temperature: (json['main']['temp'] ?? 0.0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0.0).toDouble(),
      condition: json['weather']?[0]?['main'] ?? 'Clear',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0.0).toDouble(),
      windDeg: json['wind']['deg'] ?? 0,
      sunrise: (json['sys']?['sunrise'] ?? 0),
      sunset: (json['sys']?['sunset'] ?? 0),
      timezoneOffset: json['timezone'] ?? 0,
    );
  }
}
