class WeatherForecast {
  final int? timepoint;
  final int? cloudcover;
  final int? temp2m;
  final String? windDirection;
  final int? windSpeed;
  final String? precType;

  WeatherForecast({
    this.timepoint,
    this.cloudcover,
    this.temp2m,
    this.windDirection,
    this.windSpeed,
    this.precType,
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      timepoint: json['timepoint'],
      cloudcover: json['cloudcover'],
      temp2m: json['temp2m'],
      windDirection: json['wind10m']['direction'],
      windSpeed: json['wind10m']['speed'],
      precType: json['prec_type'],
    );
  }
}
