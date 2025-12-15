import 'dart:async';
import 'dart:io';
import 'package:sd/data/services/helpers/messages_callback_manager.dart';
import 'package:sd/data/services/helpers/state_callback_manager.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:sd/config/broker_config.dart';
import 'package:sd/utils/results.dart';

// tipo de função usada como callback quando uma mensagem é recebida
typedef MessageCallback = void Function(String topic, String payload);

class BrokerService {
  BrokerService();

  // cliente MQTT responsável por manter a conexão com o broker (existe apenas um cliente durante todo o ciclo de vida do serviço)
  MqttServerClient? _client;
  // gerenciador de callbacks das mensagens recebidas vindas do broker
  final MessagesCallbackManager _messagesCallbacks = MessagesCallbackManager();
  // gerenciador de callbacks de conexão do broker
  final ConnectionCallbackManager _connectionCallbacks = ConnectionCallbackManager();
  // único listener na stream de mensagens do cliente MQTT - o broker envia todas as mensagens por esta stream
  StreamSubscription? _subscription;

  Timer? _autoDisconnectTimer; // timer pra simular uma desconexão
  Timer? _connectionChecker; // timer para checar conexão

  // realiza a conexão com o broker MQTT utilizando as configurações fixas definidas em BrokerConfig
  Future<Result<void>> connect() async {
    try {
      // criação do cliente MQTT apontando para o host do broker
      final client = MqttServerClient(
        BrokerConfig.host,
        BrokerConfig.clientId,
      )
        ..port = BrokerConfig.port // porta segura (TLS)
        ..secure = true            // ativa conexão segura
        ..keepAlivePeriod = 5      // intervalo de keep-alive
        ..logging(on: true)        // log para debug
        ..onDisconnected = () {}
        ..setProtocolV311();       // versão do protocolo MQTT

      // configuração do contexto de segurança (TLS)
      final context = SecurityContext.defaultContext;
      context.setTrustedCertificates(BrokerConfig.caPath);
      client.securityContext = context;

      // armazena o cliente criado
      _client = client;

      // realiza a conexão com autenticação
      await client.connect(
        BrokerConfig.username,
        BrokerConfig.password,
      );

      // verifica se a conexão foi realmente estabelecida
      if (client.connectionStatus?.state != MqttConnectionState.connected) {
        return Result.error(Exception("Falha na conexão")); // caso erro, não avança para a tela de dados
      }

      // após conectar, começa a escutar as mensagens enviadas pelo broker
      // quando feitas as incrições nos tópicos, já serão ouvidas automaticamente
      _listenToMessages();

      // notifica a conexão estabelecida
      _connectionCallbacks.notify(true);

      // começa a checar a conexão de tempos em tempos
      startConnectionChecker();

      // timer para simular uma desconexão após 10 segundos
      /* 
      _autoDisconnectTimer = Timer(const Duration(seconds: 10), () async {
        print("Auto-disconnect após 10 segundos");
        await disconnect();
      });
      */

      return const Result.ok(null);
    } catch (e) {
      return Result.error(Exception("Erro ao conectar"));
    }
  }

  // inscreve o cliente em um tópico MQTT e registra o callback que será executado quando mensagens chegarem nesse tópico
  Future<Result<void>> subscribe({
    required String topic,
    required MessageCallback onMessage,
  }) async {
    // garante que o cliente esteja conectado antes de se inscrever
    if (_client == null || _client!.connectionStatus?.state != MqttConnectionState.connected) {
      return Result.error(Exception("Cliente não conectado"));
    }

    _client!.subscribe(topic, MqttQos.atLeastOnce); // função para inscrição

    print("📡 Subscribed no tópico: $topic"); // debug

    // registra o callback para o tópico informado
    _messagesCallbacks.add(topic, onMessage);

    return const Result.ok(null);
  }

  // cria um único listener para a stream de mensagens do cliente MQTT
  void _listenToMessages() {
    _subscription ??= _client!.updates!.listen((events) {
      if (events.isEmpty) return;

      // obtém o primeiro evento recebido
      final event = events.first;
      final topic = event.topic;

      // extrai a mensagem MQTT recebida
      final message = event.payload as MqttPublishMessage;

      // converte o payload para String
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);

      // notifica todos os callbacks registrados para esse tópico
      _messagesCallbacks.notify(topic, payload);

      // exibe a mensagem recebida no console
      print("📥 [$topic] $payload");
    });
  }

  // publica uma mensagem em um tópico MQTT (não está sendo usada)
  Future<Result<void>> publish({
    required String topic,
    required String message,
  }) async {
    try {
      if (_client == null ||_client!.connectionStatus?.state != MqttConnectionState.connected) {
        return Result.error(Exception("Cliente não conectado"));
      }

      // cria o payload da mensagem
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      // publica a mensagem no tópico informado
      _client!.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        builder.payload!,
      );

      return const Result.ok(null);
    } catch (e) {
      return Result.error(
        Exception("Erro ao publicar"),
      );
    }
  }

  // encerra a conexão com o broker
  Future<Result<void>> disconnect() async {
    try {
      // cancela a escuta da stream de mensagens
      await _subscription?.cancel();
      _subscription = null;

      // remove callbacks de mensagens
      _messagesCallbacks.clear();

      // cancela timers
      _autoDisconnectTimer?.cancel();
      _connectionChecker?.cancel();

      // desconecta do broker
      _client?.disconnect();

      // notifica os listeners de conexão que a conexão foi perdida
      _connectionCallbacks.notify(false);

      // para o cheker de conexão
      stopConnectionChecker();
    return const Result.ok(null);
    } catch (e) {
    // caso ocorra erro durante a desconexão, reporta o erro
    return Result.error(Exception("Erro ao desconectar"));
  }
  }

  // adiciona callback de conexão (repository usa para escutar mudança)
  void addConnectionListener(ConnectionCallback callback) {
    _connectionCallbacks.add(callback);
  }

  // única forma que eu consegui pra notificar caso haja desconexão
  // checa a conexão de 1 em 1 segundo
  void startConnectionChecker() {
    _connectionChecker = Timer.periodic(const Duration(seconds: 5), (_) {
      final connected = _client?.connectionStatus?.state == MqttConnectionState.connected; // usa o próprio estado do cliente para verificar
      _connectionCallbacks.notify(connected); // notifica o repository
    });
  }

  // para o checker de conexão
  void stopConnectionChecker() {
    _connectionChecker?.cancel();
  }
}