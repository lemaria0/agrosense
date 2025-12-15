import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Routes
import 'package:sd/config/routes.dart';

// Services
import 'package:sd/data/services/broker_service.dart';

// Repositories
import 'package:sd/data/repositories/broker_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => BrokerService()),
        // Provider(create: (context) => RmiService()),
        ChangeNotifierProvider(
          create: (context) => BrokerRepository(
            brokerService: context.read(),
          ),
        ),
        /*
        ChangeNotifierProvider(
          create: (context) => RmiRepository(
            rmiService: context.read(),
          ),
        ),
        */
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/login',
            routes: appRoutes,
          );
        },
      ),
    );
  }
}