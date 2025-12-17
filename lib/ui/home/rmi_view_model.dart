import 'package:flutter/material.dart';
import 'package:sd/ui/home/i_home_view_model.dart';
import 'package:sd/data/repositories/rmi_repository.dart'; // Nome exato do seu arquivo
import 'package:sd/data/models/sensor_model.dart';
import 'package:sd/data/models/alert_model.dart';
import 'package:sd/data/models/enum/data_type.dart';
import 'package:sd/utils/results.dart';

class RmiViewModel extends ChangeNotifier implements IHomeViewModel {
  RmiViewModel({required IRmiRepository rmiRepository})
    : _rmiRepository = rmiRepository {
    _rmiRepository.addListener(_onRepositoryUpdate);
  }

  final IRmiRepository _rmiRepository;

  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;

  // Mapas para organizar o histórico por ID do dispositivo
  final Map<String, List<SensorModel>> _temperatureDevices = {};
  final Map<String, List<SensorModel>> _humidityDevices = {};
  final Map<String, List<SensorModel>> _luminosityDevices = {};
  final Map<String, List<SensorModel>> _acidityDevices = {};

  @override
  Map<String, List<SensorModel>> get temperatureDevices => _temperatureDevices;
  @override
  Map<String, List<SensorModel>> get humidityDevices => _humidityDevices;
  @override
  Map<String, List<SensorModel>> get luminosityDevices => _luminosityDevices;
  @override
  Map<String, List<SensorModel>> get acidityDevices => _acidityDevices;

  List<AlertModel> _alerts = [];
  @override
  List<AlertModel> get alerts => _alerts;

  bool _isConnected = false;
  @override
  bool get isConnected => _isConnected;

  int _unseenAlertsCount = 0;
  @override
  int get unseenAlertsCount => _unseenAlertsCount;

  @override
  void markAlertsAsSeen() {
    _unseenAlertsCount = 0;
    notifyListeners();
  }

  @override
  Future<Result<void>> init() async {
    return await connect();
  }

  @override
  Future<Result<void>> connect() async {
    try {
      _isLoading = true;
      notifyListeners();
      return await _rmiRepository.connect();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> disconnect() async {
    try {
      _isLoading = true;
      notifyListeners();
      return await _rmiRepository.disconnect();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sincroniza a ViewModel com os dados que chegam no Repository
  void _onRepositoryUpdate() {
    _isConnected = _rmiRepository.isConnected;

    // Processa a lista de AvgData vinda do Repository
    _processSensors(_rmiRepository.sensors);

    // Gerencia Alertas e contador de notificações
    final oldCount = _alerts.length;
    _alerts = _rmiRepository.alerts;

    if (_alerts.length > oldCount) {
      _unseenAlertsCount += (_alerts.length - oldCount);
    }

    notifyListeners();
  }

  void _processSensors(List<SensorModel> sensors) {
    for (final s in sensors) {
      Map<String, List<SensorModel>> targetMap;

      // Mapeamento baseado no DataType (Enum) e no 'type' vindo do Java
      switch (s.type) {
        case DataType.temperature:
          targetMap = _temperatureDevices;
          break;
        case DataType.humidity:
          targetMap = _humidityDevices;
          break;
        case DataType.luminosity:
          targetMap = _luminosityDevices;
          break;
        case DataType.ph:
          targetMap = _acidityDevices;
          break;
        default:
          continue;
      }

      targetMap.putIfAbsent(s.id, () => []);
      final list = targetMap[s.id]!;

      // IMPORTANTE: Usa o 'timestamp' do seu AvgData para evitar duplicados no gráfico
      if (list.any((existing) => existing.timestamp == s.timestamp)) {
        continue;
      }

      list.add(s);

      // Mantém histórico de 7 para visualização desktop
      if (list.length > 7) {
        list.removeAt(0);
      }
    }
  }

  @override
  void dispose() {
    _rmiRepository.removeListener(_onRepositoryUpdate);
    super.dispose();
  }
}
