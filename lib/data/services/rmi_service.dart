import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sd/utils/results.dart';

class RmiService {
  // URLs dos servidores Javalin configurados
  final String _hubUrl = "http://localhost:4567/api/v1/averages";
  final String _alertsUrl = "http://localhost:4568/api/v1/alerts";

  Timer? _pollingTimer;
  bool _isConnected = false;

  // Controllers para transmitir os dados para a UI (Equivalente aos callbacks do MQTT)
  final _metricsController = StreamController<List<dynamic>>.broadcast();
  final _alertsController = StreamController<List<dynamic>>.broadcast();
  final _statusController = StreamController<bool>.broadcast();

  // Getters para as telas (Widgets) escutarem
  Stream<List<dynamic>> get metricsStream => _metricsController.stream;
  Stream<List<dynamic>> get alertsStream => _alertsController.stream;
  Stream<bool> get statusStream => _statusController.stream;

  /// Testa a conexão inicial e inicia a busca de dados
  Future<Result<void>> connect() async {
    try {
      final response = await http
          .get(Uri.parse(_hubUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _isConnected = true;
        _statusController.add(true);
        startPolling(); // Inicia o ciclo de requisições automáticas
        return const Result.ok(null);
      }
      return Result.error(Exception("Servidor Agregador (Hub) offline."));
    } catch (e) {
      _isConnected = false;
      _statusController.add(false);
      return Result.error(
        Exception(
          "Falha ao conectar: Verifique se os servidores Java estão rodando.",
        ),
      );
    }
  }

  /// Inicia o ciclo de Pull (Requisitar dados periodicamente)
  void startPolling() {
    _pollingTimer?.cancel();
    // Faz a primeira busca imediatamente
    _fetchAllData();

    // Define o intervalo
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _fetchAllData();
    });
  }

  /// Busca dados de métricas e alertas simultaneamente
  Future<void> _fetchAllData() async {
    if (!_isConnected) return;

    try {
      final results = await Future.wait([
        http.get(Uri.parse(_hubUrl)),
        http.get(Uri.parse(_alertsUrl)),
      ]);

      // Processando Métricas
      if (results[0].statusCode == 200) {
        final decodedMetrics = jsonDecode(results[0].body);
        if (decodedMetrics is List) {
          _metricsController.add(decodedMetrics);
        } else if (decodedMetrics is Map) {
          // Se o Java enviou um único objeto ou um Map de objetos,
          // transformamos em lista para o Repository não quebrar
          _metricsController.add([decodedMetrics]);
        }
      }

      // Processando Alertas
      if (results[1].statusCode == 200) {
        final decodedAlerts = jsonDecode(results[1].body);
        if (decodedAlerts is List) {
          _alertsController.add(decodedAlerts);
        } else if (decodedAlerts is Map) {
          _alertsController.add([decodedAlerts]);
        }
      }
    } catch (e) {
      print("Erro durante o Polling: $e");
    }
  }

  /// Para o serviço e limpa os recursos
  void disconnect() {
    _isConnected = false;
    _pollingTimer?.cancel();
    _statusController.add(false);
    // Não fechamos os controllers aqui para evitar erros se a tela ainda estiver aberta
  }
}// criar aqui o RmiService