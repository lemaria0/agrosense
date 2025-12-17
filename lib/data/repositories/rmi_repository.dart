import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sd/data/services/rmi_service.dart';
import 'package:sd/data/models/sensor_model.dart';
import 'package:sd/data/models/alert_model.dart';
import 'package:sd/utils/results.dart';

abstract class IRmiRepository extends ChangeNotifier {
  bool get isConnected;
  List<SensorModel> get sensors;
  List<AlertModel> get alerts;

  Future<Result<void>> connect();
  Future<Result<void>> disconnect();

  // No RMI/Pull, estas funções apenas confirmam o início do fluxo
  Future<Result<List<SensorModel>>> startMetricsFlow();
  Future<Result<List<AlertModel>>> startAlertsFlow();
}

class RmiRepository extends IRmiRepository {
  final RmiService _rmiService;

  List<SensorModel> _currentSensors = [];
  List<AlertModel> _currentAlerts = [];
  bool _isConnected = false;

  // Subscriptions para limpar a memória depois
  StreamSubscription? _metricsSub;
  StreamSubscription? _alertsSub;
  StreamSubscription? _statusSub;

  RmiRepository({required RmiService rmiService}) : _rmiService = rmiService {
    _initListeners();
  }

  // Configura a escuta automática das Streams do Service
  void _initListeners() {
    _statusSub = _rmiService.statusStream.listen((connected) {
      _isConnected = connected;
      notifyListeners();
    });

    _metricsSub = _rmiService.metricsStream.listen((jsonList) {
      _updateSensorsFromList(jsonList);
    });

    _alertsSub = _rmiService.alertsStream.listen((jsonList) {
      _updateAlertsFromList(jsonList);
    });
  }

  @override
  List<SensorModel> get sensors => List.unmodifiable(_currentSensors);
  @override
  List<AlertModel> get alerts => List.unmodifiable(_currentAlerts);
  @override
  bool get isConnected => _isConnected;

  @override
  Future<Result<void>> connect() async {
    return await _rmiService.connect();
  }

  @override
  Future<Result<void>> disconnect() async {
    _rmiService.disconnect();
    _currentSensors.clear();
    _currentAlerts.clear();
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  Future<Result<List<SensorModel>>> startMetricsFlow() async {
    // No RMI, os dados já começam a vir no connect(),
    // então apenas retornamos o que temos agora.
    return Result.ok(_currentSensors);
  }

  @override
  Future<Result<List<AlertModel>>> startAlertsFlow() async {
    return Result.ok(_currentAlerts);
  }

  // Converte a lista vinda do Hub (AvgData) para seus SensorModels
  void _updateSensorsFromList(List<dynamic> jsonList) {
    try {
      _currentSensors = jsonList
          .map((item) => SensorModel.fromMap(item))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Erro ao processar sensores RMI: $e");
    }
  }

  // Converte o histórico de alertas vindo do rmi-alerts para AlertModels
  void _updateAlertsFromList(List<dynamic> jsonList) {
    try {
      _currentAlerts = jsonList
          .map((item) => AlertModel.fromMap(item))
          .toList();
      notifyListeners();
    } catch (e) {
      print("Erro ao processar alertas RMI: $e");
    }
  }

  @override
  void dispose() {
    _metricsSub?.cancel();
    _alertsSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }
}
