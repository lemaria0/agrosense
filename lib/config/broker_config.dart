// configuração do broker (fixo)
class BrokerConfig {
  static const String host = 'z2a78b18.ala.eu-central-1.emqxsl.com';
  static const int port = 8883;
  static const String clientId = 'dart_tls_client';
  static const String username = 'usuario_teste';
  static const String password = 'senha_teste';
  static const String caPath = 'lib/config/emqxsl-ca.crt'; // certificado
}