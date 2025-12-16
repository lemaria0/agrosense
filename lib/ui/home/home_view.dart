import 'package:flutter/material.dart';
import 'package:sd/data/models/enum/comunication_mode.dart';
import 'package:sd/ui/home/i_home_view_model.dart';
import 'package:sd/ui/home/widgets/side_menu.dart';
import 'package:sd/ui/home/widgets/mode_buttom.dart';
import 'package:sd/ui/pages/temperature_page.dart';
import 'package:sd/ui/pages/humidity_page.dart';
import 'package:sd/ui/pages/acidity_page.dart';
import 'package:sd/ui/pages/luminosity_page.dart';
import 'package:sd/ui/pages/alerts_page.dart';
import 'package:sd/utils/show_message_error.dart';
import 'package:sd/utils/show_ok_message.dart';
import 'package:sd/utils/results.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.mqttViewModel,
    // required this.rmiViewModel,
  });

  final IHomeViewModel mqttViewModel;
  // final IHomeViewModel rmiViewModel;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late IHomeViewModel currentViewModel;
  bool _wasConnected = false; // controla estado anterior de conexão

  CommunicationMode mode = CommunicationMode.mqtt; // controla de onde estão vindo os dados atualmente
  int selectedIndex = 0; //página atual
  bool _manualDisconnect = false; // flag diferente pra quando eu troco de view model

  @override
  void initState() {
    super.initState();

    currentViewModel = widget.mqttViewModel; // inicialmente os dados vem do mqtt
    _wasConnected = currentViewModel.isConnected;
    currentViewModel.addListener(_onViewModelChanged); // adiciona listener para caso haja desconexão

    _init();
  }

  Future<void> _init() async {
    final result = await currentViewModel.init();

    switch (result) {
      case Ok():
        break;
      case Error():
        if (mounted) showErrorMessage(context, result.errorMessage);
    }
  }

  void _onViewModelChanged() async {
    // quando a view model muda o estado, ele vai ver se a conexão foi perdida
    final isConnectedNow = currentViewModel.isConnected;

    if (_wasConnected && !isConnectedNow) { // se estava conectado e perdeu a conexão
      if (!_manualDisconnect) { // se não é quando troca de view model
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          showErrorMessage(context, "Conexão perdida"); // mostra a mensagem de erro "Conexão perdida"
          final connectResult = await currentViewModel.connect(); // tenta reconectar
          switch(connectResult) {
            case Ok():
            _init();
              showOkMessage(context, "Conexão reestabelecida"); // mostra a "Conexão reestabelecida"
            case Error():
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // move para login
          }
        });
      }
    }

    _wasConnected = isConnectedNow;
  }

  // troca de view model de acordo com a fonte de dados selecionada
  void _switchViewModel(IHomeViewModel newViewModel) async {
  _manualDisconnect = true;

  // remove listener e desconecta VM antiga
  await currentViewModel.disconnect();
  currentViewModel.removeListener(_onViewModelChanged);

  // troca de VM
  currentViewModel = newViewModel;
  _wasConnected = currentViewModel.isConnected;
  currentViewModel.addListener(_onViewModelChanged);

  showOkMessage(context, "Fonte de dados atualizada");

  // conecta nova VM
  await currentViewModel.connect();
  _init();

  _manualDisconnect = false;
}

  Widget buildCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return TemperaturePage(devices: currentViewModel.temperatureDevices);
      case 1:
        return HumidityPage(devices: currentViewModel.humidityDevices);
      case 2:
        return AcidityPage(devices: currentViewModel.acidityDevices);
      case 3:
        return LuminosityPage(devices: currentViewModel.luminosityDevices);
      case 4:
        return AlertsPage(alerts: currentViewModel.alerts);
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: currentViewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F5F9),
          body: currentViewModel.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4E82F0)), // carregamento
                )
              : Row(
                  children: [
                    SideMenu(
                      selectedIndex: selectedIndex,
                      unseenAlertsCount: currentViewModel.unseenAlertsCount,
                      onSelect: (i) {
                        setState(() {
                          selectedIndex = i;
                          if (i == 4) {
                            currentViewModel.markAlertsAsSeen();
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(context),
                          Expanded(
                            child: Container(
                              color: const Color(0xFFF7F8FC),
                              child: buildCurrentPage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFFE74C3C),
            onPressed: () async {
              _manualDisconnect = true;
              final disconnectResult = await currentViewModel.disconnect(); // desconecta
              switch (disconnectResult) {
                case Ok():
                  if (mounted) showOkMessage(context, "Desconectado com sucesso"); // mensagem de sucesso
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // redireciona para login
                case Error():
                  if (mounted) showErrorMessage(context, disconnectResult.errorMessage); // mensagem de erro
              }
            },
            child: const Icon(Icons.logout, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset("assets/logo.png", height: 50),
              const SizedBox(width: 15),
              Text(
                "Painel",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: mode == CommunicationMode.mqtt
                      ? const Color(0xFF4E82F0)
                      : const Color(0xFF4EC835),
                ),
              ),
              const Text(
                " Geral",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ModeButton(
            mode: mode,
            onModeChanged: (value) async {
              setState(() => mode = value);

              _manualDisconnect = true; // marca que a desconexão é manual
              await currentViewModel.disconnect(); // desconecta

              _switchViewModel(
                value == CommunicationMode.mqtt
                    ? widget.mqttViewModel
                    // : widget.rmiViewModel
                    : widget.mqttViewModel, // ao criar a outra view model, apagar essa linha e descomentar a de cima
              );
            },
          ),
        ],
      ),
    );
  }
}