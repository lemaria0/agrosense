import 'package:flutter/material.dart';
import 'package:sd/ui/login/login_view_model.dart';
import 'package:sd/utils/show_message_error.dart';
import 'package:sd/utils/show_ok_message.dart';
import 'package:sd/utils/results.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.viewModel});

  final LoginViewmodel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewmodel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.1,
              child: Image.asset(
                "assets/logo.png",
                width: 750,
                fit: BoxFit.contain,
              ),
            ),

            Material(
              elevation: 16,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 465,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: Image.asset("assets/logo.png", width: 80, fit: BoxFit.contain)),
                    SizedBox(height: 15),
                    const Text(
                      "Bem-vindo(a) ao AgroSense!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: const Text(
                        "Monitore sensores ambientais em tempo real e acompanhe alertas importantes do seu sistema.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: viewModel.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF4EC835),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                final connectResult = await viewModel.connect();
                                switch (connectResult) {
                                  case Ok():
                                    if (mounted) {
                                      showOkMessage(context, "Conectado com sucesso");
                                    }
                                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                  case Error():
                                    if (mounted) {
                                      showErrorMessage(context, connectResult.errorMessage);
                                    }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4EC835),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Conectar-se",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "© AgroSense • Monitoramento Inteligente",
                      style: TextStyle(fontSize: 12, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}