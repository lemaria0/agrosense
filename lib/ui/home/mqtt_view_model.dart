import 'package:flutter/material.dart';
import 'package:sd/ui/home/i_home_view_model.dart';
import 'package:sd/data/repositories/broker_repository.dart';
import 'package:sd/data/models/sensor_model.dart';
import 'package:sd/data/models/alert_model.dart';
import 'package:sd/data/models/enum/data_type.dart';
import 'package:sd/utils/results.dart';

class MqttViewModel extends ChangeNotifier implements IHomeViewModel {
  MqttViewModel({required IBrokerRepository brokerRepository})
      : _brokerRepository = brokerRepository {
    _brokerRepository.addListener(_onRepositoryUpdate); // escuta alterações no repository (sensores, alertas, conexão)
  }

  // repository responsável pela comunicação MQTT
  final IBrokerRepository _brokerRepository;

  // se está carregando
  bool _isLoading = false;
  @override
  bool get isLoading => _isLoading;

  // sensores de temperatura organizados por ID do dispositivo
  // cada dispositivo mantém uma lista com os últimos valores recebidos
  final Map<String, List<SensorModel>> _temperatureDevices = {};
  @override
  Map<String, List<SensorModel>> get temperatureDevices => _temperatureDevices;

  // sensores de umidade organizados por dispositivo
  final Map<String, List<SensorModel>> _humidityDevices = {};
  @override
  Map<String, List<SensorModel>> get humidityDevices => _humidityDevices;

  // sensores de luminosidade organizados por dispositivo
  final Map<String, List<SensorModel>> _luminosityDevices = {};
  @override
  Map<String, List<SensorModel>> get luminosityDevices => _luminosityDevices;

  // sensores de pH (acidez) organizados por dispositivo
  final Map<String, List<SensorModel>> _acidityDevices = {};
  @override
  Map<String, List<SensorModel>> get acidityDevices => _acidityDevices;

  // lista de alertas recebidos do broker
  List<AlertModel> _alerts = [];
  @override
  List<AlertModel> get alerts => _alerts;

  // estado de conexão com o broker
  bool _isConnected = false;
  @override
  bool get isConnected => _isConnected;

  // quantidade de alertas ainda não visualizados pelo usuário
  int _unseenAlertsCount = 0;
  @override
  int get unseenAlertsCount => _unseenAlertsCount;

  // marca todos os alertas como vistos
  @override
  void markAlertsAsSeen() {
    _unseenAlertsCount = 0;
    notifyListeners();
  }

  // realiza a inscrição nos tópicos de sensores
  // realiza a inscrição nos tópicos de alertas
  // processa o estado inicial retornado pelo repository
  @override
  Future<Result<void>> init() async {
    try {
      _isLoading = true; // carregamento

      // inscrição nos tópicos de sensores
      final informationsResult = await _brokerRepository.subscribeToInformations();

      switch (informationsResult) {
        case Ok(value: final informations):
          // processa o snapshot inicial dos sensores
          _processSensors(informations);
        case Error(error: final e):
          return Result.error(e);
      }

      // inscrição nos tópicos de alertas
      final alertsResult = await _brokerRepository.subscribeToAlerts();

      switch (alertsResult) {
        case Ok(value: final alerts):
          // snapshot inicial de alertas
          _alerts = alerts;
        case Error(error: final e):
          return Result.error(e);
      }

      return const Result.ok(null);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> connect() async { 
    try {
      _isLoading = true;

      final connectResult = await _brokerRepository.connect(); // para quando a conexão é reestabelecida
      switch(connectResult){
        case Ok():
          return const Result.ok(null);
        case Error(error: final e):
          return Result.error(e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> disconnect() async {
    try {
      _isLoading = true; // carregamento

      // desconectar do broker
      final disconnectResult = await _brokerRepository.disconnect();

      switch (disconnectResult) {
        case Ok():
          return const Result.ok(null);
        case Error(error: final e):
          return Result.error(e);
      }

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // callback chamado sempre que o repository notifica mudanças
  void _onRepositoryUpdate() {
    // atualiza o estado de conexão
    _isConnected = _brokerRepository.isConnected;

    // atualiza os sensores a partir do estado atual do repository
    final allSensors = _brokerRepository.sensors;
    _processSensors(allSensors);

    // atualiza os alertas
    final oldCount = _alerts.length;
    _alerts = _brokerRepository.alerts;

    // atualiza a contagem de alertas não vistos
    if (_alerts.length > oldCount) {
      _unseenAlertsCount += (_alerts.length - oldCount);
    }

    notifyListeners();
  }

  // organiza os sensores por tipo e dispositivo, mantendo apenas os últimos 5 valores de cada sensor
  void _processSensors(List<SensorModel> sensors) {
    for (final s in sensors) {
      // define qual mapa será usado com base no tipo do sensor
      Map<String, List<SensorModel>> targetMap;

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
      }

      // cria a lista do dispositivo caso ainda não exista
      targetMap.putIfAbsent(s.id, () => []);

      final list = targetMap[s.id]!;

      // evita duplicar sensores com o mesmo timestamp
      final alreadyExists = list.any((x) => x.timestamp == s.timestamp);
      if (alreadyExists) continue;

      // adiciona o novo valor
      list.add(s);

      // mantém apenas os últimos 7 registros (é o valor adequado pra tela)
      if (list.length > 7) {
        list.removeAt(0);
      }
    }
  }

  /// remove o listener do repository ao destruir o ViewModel
  @override
  void dispose() {
    _brokerRepository.removeListener(_onRepositoryUpdate);
    super.dispose();
  }
}