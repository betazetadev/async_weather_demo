import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../model/weather_forecast.dart';

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

  // Convierte el `initTime` en una fecha y le suma el `timepoint` para obtener la hora exacta del pronóstico
  String getFormattedHour(String? initTime, int timepoint) {
    if (initTime == null) return 'N/A';

    // Parseamos la fecha de inicio del pronóstico
    final year = int.parse(initTime.substring(0, 4));
    final month = int.parse(initTime.substring(4, 6));
    final day = int.parse(initTime.substring(6, 8));
    final hour = int.parse(initTime.substring(8, 10));

    // Creamos un DateTime con la fecha y hora de inicio
    final initDateTime = DateTime(year, month, day, hour);

    // Sumamos el `timepoint` (que está en horas) a la fecha de inicio
    final forecastDateTime = initDateTime.add(Duration(hours: timepoint));

    // Devolvemos la hora formateada
    return DateFormat('HH:mm', 'es_ES').format(forecastDateTime);
  }

  String getFormattedDay(String? initTime, int timepoint) {
    if (initTime == null) return 'N/A';

    // Parseamos la fecha de inicio y sumamos el `timepoint`
    final year = int.parse(initTime.substring(0, 4));
    final month = int.parse(initTime.substring(4, 6));
    final day = int.parse(initTime.substring(6, 8));
    final hour = int.parse(initTime.substring(8, 10));
    final initDateTime = DateTime(year, month, day, hour);
    final forecastDateTime = initDateTime.add(Duration(hours: timepoint));

    // Devolvemos el día formateado
    return DateFormat('EEEE, MMM d', 'es_ES').format(forecastDateTime);
  }

  String getWeatherIcon(String precType) {
    switch (precType) {
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'none':
        return '☀️';
      default:
        return '🌥️';
    }
  }

  void onForecastTap(WeatherForecast forecast) {
    final icon = getWeatherIcon(forecast.precType ?? '');
    final day = getFormattedDay(initTime, forecast.timepoint ?? 0);
    final hour = getFormattedHour(initTime, forecast.timepoint ?? 0);
    final temp = '${forecast.temp2m}°C';
    final wind = '${forecast.windDirection} ${forecast.windSpeed} m/s';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$icon $day $hour - Temp: $temp, Wind: $wind'),
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
        title: Text('Tiempo en A Coruña'),
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 100),
                  SizedBox(height: 20),
                  Text(
                    'Error obteniendo datos',
                    style: TextStyle(
                      fontSize: 24, // Larger font size
                      fontWeight: FontWeight.bold, // Bold text
                    ),
                  ),
                  SizedBox(height: 20), // Add margin to the top of the button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _forceError = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
                      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Text style
                    ),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final forecastData = snapshot.data!;
            final groupedForecasts = groupForecastsByDay(forecastData);
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '${forecastData[0].temp2m}°C',
                        style: TextStyle(
                            fontSize: 80, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        getWeatherIcon(forecastData[0].precType ?? ''),
                        style: TextStyle(fontSize: 100),
                      ),
                    ],
                  ),
                ),
                Expanded(
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
                              // Título con el día
                              Text(
                                day,
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
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
                                      // Mostrar la hora a la derecha
                                      getFormattedHour(
                                          initTime, forecast.timepoint ?? 0),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () => onForecastTap(
                                        forecast), // Callback para mostrar Snackbar
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
