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