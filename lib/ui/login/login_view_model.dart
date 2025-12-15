import 'package:flutter/material.dart';
import 'package:sd/data/repositories/broker_repository.dart';
import 'package:sd/utils/results.dart';

class LoginViewmodel extends ChangeNotifier {
  LoginViewmodel({
    required IBrokerRepository brokerRepository,
  }) : _brokerRepository = brokerRepository;

  final IBrokerRepository _brokerRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<Result<void>> connect() async { 
    try {
      _isLoading = true;

      final connectResult = await _brokerRepository.connect(); // incialmente a conexão é feita somente para o mqtt, quando troca na home que a conexão é feita
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
}