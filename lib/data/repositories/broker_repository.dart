import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sd/data/services/broker_service.dart';
import 'package:sd/data/models/sensor_model.dart';
import 'package:sd/data/models/alert_model.dart';
import 'package:sd/utils/results.dart';

abstract class IBrokerRepository extends ChangeNotifier {
  get isConnected => null; // envia o estado de conexão
  get sensors => null; // envia os sensores
  get alerts => null; // e os alertas por meio de getters (gambiarra mas funciona)

  // resto das funções
  Future<Result<void>> connect(); // conecta ao broker
  Future<Result<void>> disconnect(); // desconecta ao broker
  Future<Result<List<SensorModel>>> subscribeToInformations(); // se inscreve nos tópicos de informação
  Future<Result<List<AlertModel>>> subscribeToAlerts(); // se inscreve nos tópicos de alertas
}

class BrokerRepository extends IBrokerRepository {
  BrokerRepository({required BrokerService brokerService})
    : _brokerService = brokerService {
    _brokerService.addConnectionListener(_onConnectionChanged); // adiciona o listener de conexão (service controla)
  }

  final BrokerService _brokerService; // utiliza o service

  final List<SensorModel> _currentSensors = []; // armazena uma lista para sensores
  final List<AlertModel> _currentAlerts = []; // armazena uma lista para alertas
  bool _isConnected = false; // armazena o estado de conexão do cliente em relação broker

  // getters
  @override
  List<SensorModel> get sensors => List.unmodifiable(_currentSensors);
  @override
  List<AlertModel> get alerts => List.unmodifiable(_currentAlerts);
  @override
  bool get isConnected => _isConnected;

  @override
  Future<Result<void>> connect() async {
    try {
      final connectResult = await _brokerService.connect(); // se conecta
      switch (connectResult) {
        case Ok():
          return const Result.ok(null); // retorna ok
        case Error(error: final e):
          return Result.error(e); // retorna erro
      }
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> disconnect() async {
    try {
      final connectResult = await _brokerService.disconnect(); // se desconecta
      switch (connectResult) {
        case Ok():
          return const Result.ok(null); // retorna ok
        case Error(error: final e):
          return Result.error(e); // retorna erro
      }
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<List<SensorModel>>> subscribeToInformations() async {
    try {
      // lista de tópicos relacionados às informações dos sensores
      final topics = [
        "estufa/visao/temperatura",
        "estufa/visao/umidade",
        "estufa/visao/iluminacao",
        "estufa/visao/ph",
      ];

      // realiza a inscrição em cada tópico
      for (final topic in topics) {
        final result = await _brokerService.subscribe(
          topic: topic,
          onMessage: (topic, payload) async { // callback chamado sempre que uma nova mensagem chegar
            try {
              final json = jsonDecode(payload); // converte o payload (JSON em String) para Map
              
              final sensor = SensorModel.fromMap(json); // cria o SenSorModel a partir do JSON
              
              _updateSensor(sensor); // atualiza o estado interno do repository
              
              notifyListeners(); // notifica os ouvintes
            } catch (e) {
              print("Erro convertendo JSON"); // evita quebra do fluxo em caso de erro de conversão
            }
          },
        );

        // se houver erro ao se inscrever em um tópico, interrompe o processo
        if (result case Error(error: final e)) {
          return Result.error(e);
        }
      }

      // retorna o estado atual dos sensores como snapshot inicial
      return Result.ok(List.of(_currentSensors));
    } catch (e) {
      return Result.error(Exception(e.toString())); // tratamento de erro inesperado
    }
  }

  @override
  Future<Result<List<AlertModel>>> subscribeToAlerts() async {
    try {
      // lista de tópicos relacionados às alertas dos sensores
      final topics = [
        "estufa/alerta/temperatura",
        "estufa/alerta/umidade",
        "estufa/alerta/iluminacao",
        "estufa/alerta/ph",
      ];

      // realiza a inscrição em cada tópico
      for (final topic in topics) {
        final result = await _brokerService.subscribe(
          topic: topic,
          onMessage: (topic, payload) async { // callback chamado sempre que uma nova mensagem chegar
            try {
              final json = jsonDecode(payload); // converte o payload (JSON em String) para Map

              final alert = AlertModel.fromMap(json); // cria o AlertModel a partir do JSON

              _updateAlert(alert); // atualiza o estado interno do repository
              
              notifyListeners(); // notifica os ouvintes
            } catch (e) {
              print("Erro convertendo JSON: $e"); // evita quebra do fluxo em caso de erro de conversão
            }
          },
        );

        // se houver erro ao se inscrever em um tópico, interrompe o processo
        if (result case Error(error: final e)) {
          return Result.error(e);
        }
      }

      // retorna o estado atual dos sensores como snapshot inicial
      return Result.ok(List.of(_currentAlerts));
    } catch (e) {
      return Result.error(Exception(e.toString())); // tratamento de erro inesperado
    }
  }

  // atualiza ou adiciona um sensor na lista de sensores atuais
  void _updateSensor(SensorModel sensor) {
    // procura um sensor com o mesmo ID na lista
    final index = _currentSensors.indexWhere(
      (s) => s.id == sensor.id,
    );

    // se o sensor já existir, substitui pelo novo valor
    if (index >= 0) {
      _currentSensors[index] = sensor;
    } 
    // caso contrário, adiciona o sensor à lista
    else {
      _currentSensors.add(sensor);
    }
  }

  void _updateAlert(AlertModel alert) {
    // filtra alertas do mesmo tipo
    final sameTypeAlerts = _currentAlerts.where((a) => a.type == alert.type).toList();

    // se já existem 5 alertas desse tipo, remove o mais antigo
    if (sameTypeAlerts.length >= 5) {
      // considera que o mais antigo é o primeiro inserido
      final oldestAlert = sameTypeAlerts.first;
      _currentAlerts.remove(oldestAlert);
    }

    // adiciona o novo alerta
    _currentAlerts.add(alert);
  }

  // atualiza o estado de conexão
  void _onConnectionChanged(bool connected) {
    _isConnected = connected;
    notifyListeners(); // notifica os ouvintes
  }
}