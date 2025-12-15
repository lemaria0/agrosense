import 'package:flutter/material.dart';
import 'package:sd/data/models/alert_model.dart';
import 'package:sd/data/models/sensor_model.dart';
import 'package:sd/utils/results.dart';

// interface das view models (criei para forçar as mesmas funções que a view usará)
abstract class IHomeViewModel extends ChangeNotifier {
  bool get isLoading;

  // retorna listas de dispositivos e suas informações para cada tipo
  Map<String, List<SensorModel>> get temperatureDevices;
  Map<String, List<SensorModel>> get humidityDevices;
  Map<String, List<SensorModel>> get luminosityDevices;
  Map<String, List<SensorModel>> get acidityDevices;

  // retorna lista de alertas
  List<AlertModel> get alerts;

  // retorna quantidade de alertas não vistos
  int get unseenAlertsCount;

  // retorna se o cliente está conectado ou não
  bool get isConnected;

  Future<Result<void>> connect(); // precisei adicionar a função de conectar pra quando troca de view model => desconecta da atual fonte de dados => troca  de view model => conecta na outra
  Future<Result<void>> init(); // função de inicialização (no caso do mqqt, realiza as inscrições nos tópicos)
  Future<Result<void>> disconnect(); // função de desconexão
  void markAlertsAsSeen(); // zerar número de alertas não vistos
}