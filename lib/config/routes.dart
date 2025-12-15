import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pages
import 'package:sd/ui/home/home_view.dart';
import 'package:sd/ui/login/login_view.dart';

// View Models
import 'package:sd/ui/home/mqtt_view_model.dart';
import 'package:sd/ui/login/login_view_model.dart';

// Repositories
import 'package:sd/data/repositories/broker_repository.dart';

Map<String, Widget Function(BuildContext)> appRoutes = {
  '/login': (context) => LoginView(
    viewModel: LoginViewmodel(brokerRepository: context.read<BrokerRepository>()),
  ),
  '/home': (context) => HomeView(
    mqttViewModel: MqttViewModel(brokerRepository: context.read<BrokerRepository>()),
    // rmiViewModel: RmiViewModel(rmiRepository: context.read<RmiRepository>()),
  ),
};