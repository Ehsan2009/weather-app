import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/services/cities.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('8b728ee321af5ca97de108965b8b291a');
  Weather? _weather;

  void fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sun.json';

    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/storm.json';
      case 'clear':
        return 'assets/sun.json';
      default:
        return 'assets/sun.json';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey[400],
              ),
              Text(
                _weather?.cityName ?? 'loading city...',
                style: GoogleFonts.abel(
                  textStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Lottie.asset(
                getWeatherAnimation(_weather?.mainCondition),
              ),
              const Spacer(),
              _weather == null
                  ? const CircularProgressIndicator()
                  : Text(
                      '${_weather?.temperature.round()}°C',
                      style: GoogleFonts.abel(
                        textStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.deepPurple,
            context: context,
            builder: (ctx) {
              return ListView.builder(
                itemCount: cities.length,
                itemBuilder: (ctx, index) {
                  return GestureDetector(
                    onTap: () async {
                      final weather =
                          await _weatherService.getWeather(cities[index]);
                      setState(() {
                        _weather = weather;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Card(
                      margin: const EdgeInsets.all(12),
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          cities[index],
                          style: GoogleFonts.abel(
                              textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        child: const Icon(
          Icons.swap_horizontal_circle_sharp,
          size: 40,
          color: Colors.black,
        ),
      ),
    );
  }
}
