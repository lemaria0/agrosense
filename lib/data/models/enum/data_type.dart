// tipos de dado (temperatura, humidade, luminosidade e acidez)
enum DataType {
  temperature,
  humidity,
  luminosity,
  ph;

  static DataType fromString(String value) {
    final normalized = value.trim().toLowerCase();

    return DataType.values.firstWhere(
      (e) => e.name == normalized,
      orElse: () => DataType.temperature,
    );
  }
}