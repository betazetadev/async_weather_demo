import 'package:async_weather_demo/widget/error_display.dart';
import 'package:async_weather_demo/widget/weather_header.dart';
import 'package:async_weather_demo/widget/weather_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../model/weather_forecast.dart';
import '../util/weather_utils.dart';

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  static const double latitude = 43.3619292;
  static const double longitude = -8.453883;
  String? initTime; // Guardamos la fecha de inicio aquí
  bool _forceError = false;

  Future<List<WeatherForecast>> fetchWeatherData() async {
    await initializeDateFormatting('es_ES', null);
    if (_forceError) {
      throw Exception('Forced error');
    }
    final response = await http.get(Uri.parse(
        'https://www.7timer.info/bin/astro.php?lon=$longitude&lat=$latitude&ac=0&unit=metric&output=json&tzshift=0'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      initTime =
      data['init']; // Guardamos el init (fecha de inicio del pronóstico)
      return (data['dataseries'] as List)
          .map((json) => WeatherForecast.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  String getFormattedDay(String? initTime, int timepoint) {
    if (initTime == null) return 'N/A';

    final year = int.parse(initTime.substring(0, 4));
    final month = int.parse(initTime.substring(4, 6));
    final day = int.parse(initTime.substring(6, 8));
    final hour = int.parse(initTime.substring(8, 10));
    final initDateTime = DateTime(year, month, day, hour);
    final forecastDateTime = initDateTime.add(Duration(hours: timepoint));

    return DateFormat('EEEE, MMM d').format(forecastDateTime);
  }

  void onForecastTap(WeatherForecast forecast) {
    final icon = getWeatherIcon(forecast.precType ?? '');
    final day = getFormattedDay(initTime, forecast.timepoint ?? 0);
    final temp = '${forecast.temp2m}°C';
    final wind = '${forecast.windDirection} ${forecast.windSpeed} m/s';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text('$icon $day - '),
            Icon(Icons.thermostat, color: Colors.white),
            Text(' $temp - '),
            Icon(Icons.air, color: Colors.white,),
            Text(' $wind'),
          ],
        ),
      ),
    );
  }

  Map<String, List<WeatherForecast>> groupForecastsByDay(
      List<WeatherForecast> forecastData) {
    final Map<String, List<WeatherForecast>> groupedData = {};
    for (var forecast in forecastData) {
      final day = getFormattedDay(initTime, forecast.timepoint ?? 0);
      if (groupedData.containsKey(day)) {
        groupedData[day]!.add(forecast);
      } else {
        groupedData[day] = [forecast];
      }
    }
    return groupedData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather in A Coruña'),
        actions: [
          IconButton(
            icon: Icon(Icons.error),
            onPressed: () {
              setState(() {
                _forceError = !_forceError;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: FutureBuilder<List<WeatherForecast>>(
        future: fetchWeatherData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorDisplay(onRetry: () {
              setState(() {
                _forceError = !_forceError;
              });
            });
          } else if (snapshot.hasData) {
            final forecastData = snapshot.data!;
            final groupedForecasts = groupForecastsByDay(forecastData);
            return Column(
              children: [
                WeatherHeader(forecast: forecastData[0]),
                WeatherList(
                  groupedForecasts: groupedForecasts,
                  initTime: initTime,
                  onForecastTap: onForecastTap,
                ),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}