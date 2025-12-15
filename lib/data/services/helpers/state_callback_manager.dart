typedef ConnectionCallback = void Function(bool connected);

// cuida dos callbacks do estado referente a conexão do cliente ao broker
class ConnectionCallbackManager {
  final List<ConnectionCallback> _callbacks = [];

  // adiciona à lista de ouvintes
  void add(ConnectionCallback callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
  }

    // remove um callback específico
    void remove(ConnectionCallback callback) {
      _callbacks.remove(callback);
    }

  // notifica atualização
  void notify(bool connected) {
    for (final cb in _callbacks) {
      cb(connected);
    }
  }

  // limpa
  void clear() => _callbacks.clear();
}