typedef MessageCallback = void Function(String topic, String payload);

// cuida dos callbacks das mensagens recebidas vindas do broker
class MessagesCallbackManager {
  final Map<String, List<MessageCallback>> _callbacks = {};

  // adiciona à lista de ouvintes
  void add(String topic, MessageCallback callback) {
    _callbacks.putIfAbsent(topic, () => []);
    if (!_callbacks[topic]!.contains(callback)) {
      _callbacks[topic]!.add(callback);
    }
  }

  // notifica atualização
  void notify(String topic, String payload) {
    if (!_callbacks.containsKey(topic)) return;
    for (final cb in _callbacks[topic]!) {
      cb(topic, payload);
    }
  }

  // limpa
  void clear() => _callbacks.clear();
}