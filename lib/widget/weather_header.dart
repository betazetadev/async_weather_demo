import 'package:flutter/material.dart';
import '../model/weather_forecast.dart';
import '../util/weather_utils.dart';

class WeatherHeader extends StatelessWidget {
  final WeatherForecast forecast;

  const WeatherHeader({required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            '${forecast.temp2m}°C',
            style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
          ),
          Text(
            getWeatherIcon(forecast.precType ?? ''),
            style: TextStyle(fontSize: 100),
          ),
        ],
      ),
    );
  }
}