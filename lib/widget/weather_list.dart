import 'package:flutter/material.dart';
import '../model/weather_forecast.dart';
import 'package:intl/intl.dart';
import '../util/weather_utils.dart';

class WeatherList extends StatelessWidget {
  final Map<String, List<WeatherForecast>> groupedForecasts;
  final String? initTime;
  final Function(WeatherForecast) onForecastTap;

  const WeatherList({
    required this.groupedForecasts,
    required this.initTime,
    required this.onForecastTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: groupedForecasts.keys.map((day) {
          final forecastsForDay = groupedForecasts[day]!;

          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Column(
                    children: forecastsForDay.map((forecast) {
                      return ListTile(
                        leading: Text(
                          getWeatherIcon(forecast.precType ?? ''),
                          style: TextStyle(fontSize: 40),
                        ),
                        title: Text(
                          '${forecast.temp2m}°C',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Icon(Icons.air),
                            SizedBox(width: 5),
                            Text(
                              '${forecast.windDirection} ${forecast.windSpeed} m/s',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        trailing: Text(
                          getFormattedHour(initTime, forecast.timepoint ?? 0),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onTap: () => onForecastTap(forecast),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String getFormattedHour(String? initTime, int timepoint) {
    if (initTime == null) return 'N/A';

    final year = int.parse(initTime.substring(0, 4));
    final month = int.parse(initTime.substring(4, 6));
    final day = int.parse(initTime.substring(6, 8));
    final hour = int.parse(initTime.substring(8, 10));

    final initDateTime = DateTime(year, month, day, hour);
    final forecastDateTime = initDateTime.add(Duration(hours: timepoint));

    return DateFormat('HH:mm').format(forecastDateTime);
  }
}